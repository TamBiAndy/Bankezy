//
//  CreattAccViewModel.swift
//  Bankezy
//
//  Created by Andy on 26/11/2024.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt
import Moya


struct CreatAccResponse: Decodable {
    let status: String?
    let message: String?
    let data: Data?
    
    struct Data: Decodable {
        let id: String?
        let email: String?
        let phone: String?
        let creatAt: String?
        let token: String?
    }
}

extension CreattAccViewModel {
    struct Input {
        let email: Observable<String?>
        let password: Observable<String?>
        let phoneNumber: Observable<String?>
        let createTapped: Observable<Void>
    }
    
    struct Output {
        let emailIsValid: Driver<Validation>
        let phoneNumberIsValid: Driver<Validation>
        let isSuccess: Driver<Bool>
        let error: Driver<Error>
    }
    
    enum Validation {
        case valid
        case error
        case none
    }
    
    enum PasswordValidateError {
        case empty
        case tooShort
    }
    
    enum APIError: Error {
        case invalidResponse
        case serverError
    }
}

class CreattAccViewModel {
    let provider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.delayedStub(2))
    
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        
        let emailIsValidDriver = input.email
            .flatMapLatest { email in
                return self.validate(email: email)
            }
            .asDriver(onErrorJustReturn: .error)
        
        let phoneNumberIsValidDriver = input.phoneNumber
            .flatMapLatest { phoneNumber in
                return self.validate(phoneNumber: phoneNumber)
            }
            .asDriver(onErrorJustReturn: .error)
        
        // Result
//        let regiserObv = input.createTapped
//            .withLatestFrom(input.email.unwrap())
//            .withLatestFrom(input.password.unwrap()) { ($0, $1) }
//            .withLatestFrom(input.phoneNumber.unwrap()) { ($0, $1) }
//            .flatMapLatest { combined, phoneNumber in
//                let (email, password) = combined
//
//                return self.provider.rx.request(.creatAcc(email: email, password: password, phone: phoneNumber))
//                    .map { response -> Result<Bool, ErrorModel> in
//                        if (200...299).contains(response.statusCode) {
//                            return .success(true)
//                        } else {
//                            let errorModel = try JSONDecoder().decode(ErrorModel.self, from: response.data)
//                            
//                            return .failure(errorModel)
//                        }
//                    }
//            }
//            .share()
//        
//        let isSuccessDriver = regiserObv
//            .map { try $0.get() }
//            .asDriver(onErrorJustReturn: false)
//        
//        let errorDriver: Driver<ErrorModel> = regiserObv
//            .compactMap {
//                switch $0 {
//                case .success:
//                    return nil
//                case .failure(let errorModel):
//                    return errorModel
//                }
//            }
//            .asDriver(onErrorDriveWith: .empty())
        
        // Error Tracker
        let isSuccessDriver = input.createTapped
            .withLatestFrom(input.email.unwrap())
            .withLatestFrom(input.password.unwrap()) { ($0, $1) }
            .withLatestFrom(input.phoneNumber.unwrap()) { ($0, $1) }
            .flatMapLatest { combined, phoneNumber in
                let (email, password) = combined
                
//                return self.register(email: email, password: password, phoneNumber: phoneNumber)

                return self.provider.rx.request(.creatAcc(email: email, password: password, phone: phoneNumber))
                    .map { response in
                        if (200...299).contains(response.statusCode) {
                            return true
                        } else {
                            let errorModel = try JSONDecoder().decode(ErrorModel.self, from: response.data)
                            
                            throw errorModel
                        }
                    }
                    .trackError(errorTracker)
            }
            .asDriver(onErrorJustReturn: false)

        return Output(
            emailIsValid: emailIsValidDriver,
            phoneNumberIsValid: phoneNumberIsValidDriver,
            isSuccess: isSuccessDriver,
            error: errorTracker.asDriver()
        )
    }
    
    func validate(email: String?) -> Observable<Validation> {
        Observable.create { observer in
            if let email, !email.isEmpty {
                let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                
                let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
                let isValid = emailPred.evaluate(with: email)
                
                observer.onNext(isValid ? .valid : .error)
            } else {
                observer.onNext(.none)
            }
           
            return Disposables.create()
        }
    }
    
    func validate(phoneNumber: String?) -> Observable<Validation> {
        Observable.create { observer in
            if let phoneNumber, !phoneNumber.isEmpty {
                let PHONE_REGEX = "^[0-9+]{0,1}+[0-9]{12,12}$"
                let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
                let isValid = phoneTest.evaluate(with: phoneNumber)
                
                observer.onNext(isValid ? .valid : .error)
            } else {
                observer.onNext(.none)
            }
            
            return Disposables.create()
        }
    }
    
    func register(
        email: String,
        password: String,
        phoneNumber: String
    ) -> Observable<Bool> {
        .create { observer in
            self.provider.request(.creatAcc(email: email, password: password, phone: phoneNumber)) { result in
                switch result {
                case .success(let response):
                    if (200...299).contains(response.statusCode) {
                        observer.onNext(true)
                    } else {
                        if let errorModel = try? JSONDecoder().decode(ErrorModel.self, from: response.data) {
                            observer.onError(errorModel)
                        }
                    }
                case.failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
}

struct ErrorModel: Codable, LocalizedError {
    let code: Int
    let message: String?
    let title: String?
    
    var errorDescription: String? {
        return message
    }
}


