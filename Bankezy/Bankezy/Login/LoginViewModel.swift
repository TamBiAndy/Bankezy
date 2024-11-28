//
//  LoginViewModel.swift
//  Bankezy
//
//  Created by Andy on 27/11/2024.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Moya

struct LoginResponse: Decodable {
    let status: String?
    let message: String?
    let data: Data?
    
    struct Data: Decodable {
        let id: String?
        let email: String?
        let creatAt: String?
        let token: String?
    }
}

extension LoginViewModel {
    struct Input {
        let email: Observable<String?>
        let password: Observable<String?>
        let autoLogin: Observable<Bool>
        let loginTapped: Observable<Void>
    }
    
    struct Output {
        let emailValidate: Driver<Validation>
        let loginIsSuccess: Driver<Bool>
        let errorLogin: Driver<Error>
    }
    
    enum Validation {
        case valid
        case error
        case none
    }
    
    enum PasswordValidateError: Error {
        case empty
        case tooShort
    }
    
    enum EmailValidateError: Error {
        case empty
        case invalidEmailFormat
        case serverError
    }
}


class LoginViewModel {
    let provider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.delayedStub(2))
    
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let validEmailDriver = input.email
            .flatMapLatest({ email in
                return self.validate(email: email)
            })
            .asDriver(onErrorJustReturn: .error)
        
        let isSuccessDriver = input.loginTapped
            .withLatestFrom(input.email.unwrap())
            .withLatestFrom(input.password.unwrap()) { ($0, $1)}
            .withLatestFrom(input.autoLogin) { ($0,$1) }
            .flatMapLatest { combine, autologin in
                let (email, password) = combine
                return self.provider.rx.request(.login(email: email, password: password, autoLogin: autologin) )
                    .map { response in
                        if (200...299).contains(response.statusCode) {
                            return true
                        } else {
                            let errorModel = try JSONDecoder().decode(LoginErrorModel.self, from: response.data)
                            throw errorModel
                        }
                }
                    .trackError(errorTracker)
            }
            .asDriver(onErrorJustReturn: false)
        
        
        
        return .init(emailValidate: validEmailDriver, loginIsSuccess: isSuccessDriver, errorLogin: errorTracker.asDriver())
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
    
    
}

struct LoginErrorModel: Codable, LocalizedError {
    let code: Int
    let messege: String
    let title: String
    
    var errorDescription: String? {
        return messege
    }
}
