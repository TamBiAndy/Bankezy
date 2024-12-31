//
//  AddPaymentMethodViewModel.swift
//  Bankezy
//
//  Created by Andy on 27/12/2024.
//

import UIKit
import RxCocoa
import RxSwift
import Moya

class AddPaymentMethodViewModel {
    var errorTracker = ErrorTracker()
    
    let provider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.delayedStub(2))
    
    
    func transform(input: Input) -> Output {
        let isValidCardNumberDriver = input.cardNumber
            .flatMapLatest { number in
                return self.isValidCardNumber(number: number)
            }
            .asDriver(onErrorJustReturn: .none)
        
        let isSuccessObv = input.addCartTapped
            .withLatestFrom(input.cardNumber.unwrap())
            .withLatestFrom(input.expireDate.unwrap()) { ($0, $1) }
            .withLatestFrom(input.cvcNumber.unwrap()) { ($0, $1) }
            .flatMapLatest { combine in
                let ((cardNumber, expireDate), cvcNumber) = combine
                
                return self.provider.rx.request(.addPaymentMethod(cardNumber: cardNumber, expireDate: expireDate, cvcNumber: cvcNumber))
                    .map { response in
                        if (200...299).contains(response.statusCode) {
                            return true
                        } else {
                            let error = try JSONDecoder().decode(ErrorModel.self, from: response.data)
                            
                            throw error
                        }
                    }
                    .trackError(self.errorTracker)
            }
            .asDriver(onErrorJustReturn: false)
        
        let cardNumberFormated = input.cardNumber
            .flatMapLatest {
                self.cardNumberFormater($0)
            }
            .asDriver(onErrorJustReturn: nil)
        
        let expireDateFormatted = input.expireDate
            .flatMapLatest { date in
                self.expireDateFormatted(date: date)
            }
            .asDriver(onErrorJustReturn: nil)
        
        let isValidExpireDateDriver = input.expireDate
            .flatMapLatest { date in
                return self.isValidExpireDate(date: date)
            }
            .asDriver(onErrorJustReturn: .none)
        
        let isValidCvcNumberDriver = input.cvcNumber
            .flatMapLatest { number in
                return self.isValidCvcNumber(number: number)
            }
            .asDriver(onErrorJustReturn: .none)
        
        return .init(
            isValidCardNumber: isValidCardNumberDriver,
            isValidExpireDate: isValidExpireDateDriver,
            isValidCvcNumber: isValidCvcNumberDriver,
            isSuccess: isSuccessObv,
            error: .empty(),
            cardNumberFormated: cardNumberFormated,
            expireDateFormated: expireDateFormatted
        )
    }
    
    func cardNumberFormater(_ cardNumber: String?) -> Observable<String?> {
        Observable.create { observer in
            guard let cardNumber else { 
                observer.onNext(nil)
                return Disposables.create()
            }
            
            let numberOnly = cardNumber.replacingOccurrences(
                of: "[^0-9]", with: "", options: .regularExpression
            )
            
            var formatted = ""
            var formatted4 = ""
            for character in numberOnly {
                if formatted4.count == 4 {
                    formatted += formatted4 + " "
                    formatted4 = ""
                }
                formatted4.append(character)
            }
            
            formatted += formatted4
            
            observer.onNext(formatted)
            
            return Disposables.create()
        }
    }
    
    func isValidCardNumber(number: String?) -> Observable<Validation> {
        Observable.create { observer in
            if let number, !number.isEmpty {
                let numberOnly = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                
                var formatted = ""
                var valid = false
                
                valid = self.luhnCheck(number: numberOnly)
                
                observer.onNext(valid ? .valid : .error)
            } else {
                observer.onNext(.none)
            }
            return Disposables.create()
        }
    }
    
    func matchesRegex(regex: String!, text: String!) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [.caseInsensitive])
            let range = NSRange(location: 0, length: text.utf16.count)
            return (regex.firstMatch(in: text, options: [], range: range) != nil)
        } catch {
            return false
        }
    }

    func luhnCheck(number: String) -> Bool {
        let reversedDigits = number.reversed().compactMap { Int(String($0)) }
        
        guard reversedDigits.count > 1 else {
            return false // Số thẻ tín dụng phải có ít nhất 2 chữ số
        }
        
        let checksum = reversedDigits.enumerated().reduce(0) { (sum, pair) in
            let (index, digit) = pair
            if index % 2 == 1 { // Các vị trí chẵn (đếm từ 0)
                let doubledDigit = digit * 2
                return sum + (doubledDigit > 9 ? doubledDigit - 9 : doubledDigit)
            } else {
                return sum + digit
            }
        }
        
        return checksum % 10 == 0
    }
    
    func expireDateFormatted(date: String?) -> Observable<String?> {
        Observable.create { observer in
            guard let date else {
                observer.onNext(nil)
                return Disposables.create()
            }
            var formatted = ""
            let origin = date.replacingOccurrences(of: "/", with: "")
            
            origin.forEach { character in
                if formatted.count == 2 {
                    formatted += "/"
                }
                formatted.append(character)
            }
            
            observer.onNext(formatted)
            return Disposables.create()
        }
    }
    
    func isValidExpireDate(date: String?) -> Observable<Validation> {
        Observable.create { observer in
            if let date, !(date.isEmpty) {
                let dateComponents = date.split(separator: "/")
                guard dateComponents.count == 2,
                      let month = Int(dateComponents[0]),
                      let year = Int(dateComponents[1]) else {
                    observer.onNext(.error)
                    return Disposables.create()
                }
                
                let currentDate = Date()
                let calendar = Calendar.current
                let currentYear = calendar.component(.year, from: currentDate) % 100
                let currentMonth = calendar.component(.month, from: currentDate)
                
                if year > currentYear || (year == currentYear && month >= currentMonth && (1...12).contains(month)) {
                    observer.onNext(.valid)
                } else {
                    observer.onNext(.error)
                }
            } else {
                observer.onNext(.none)
            }
            return Disposables.create()
        }
    }
    
    func isValidCvcNumber(number: String?) -> Observable<Validation> {
        Observable.create { observer in
            if let number, !(number.isEmpty) {
                observer.onNext(number.count == 3 ? .valid : .error)
                    
            } else {
                observer.onNext(.none)
            }
            return Disposables.create()
        }
    }
}

extension AddPaymentMethodViewModel {
    struct Input {
        let cardNumber: Observable<String?>
        let expireDate: Observable<String?>
        let cvcNumber: Observable<String?>
        let addCartTapped: Observable<Void>
    }
    
    struct Output {
        let isValidCardNumber: Driver<Validation>
        let isValidExpireDate: Driver<Validation>
        let isValidCvcNumber: Driver<Validation>
        let isSuccess: Driver<Bool>
        let error: Driver<Error>
        let cardNumberFormated: Driver<String?>
        let expireDateFormated: Driver<String?>
    }
    
    enum Validation {
        case valid
        case error
        case none
    }
}

enum CardType: String {
    case Unknown, Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay

    static let allCards = [Amex, Visa, MasterCard, Diners, Discover, JCB, Elo, Hipercard, UnionPay]

    var regex : String {
        switch self {
        case .Amex:
           return "^3[47][0-9]{5,}$"
        case .Visa:
           return "^4[0-9]{6,}([0-9]{3})?$"
        case .MasterCard:
           return "^(5[1-5][0-9]{4}|677189)[0-9]{5,}$"
        case .Diners:
           return "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        case .Discover:
           return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        case .JCB:
           return "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        case .UnionPay:
           return "^(62|88)[0-9]{5,}$"
        case .Hipercard:
           return "^(606282|3841)[0-9]{5,}$"
        case .Elo:
           return "^((((636368)|(438935)|(504175)|(451416)|(636297))[0-9]{0,10})|((5067)|(4576)|(4011))[0-9]{0,12})$"
        default:
           return ""
        }
    }
}
