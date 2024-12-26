//
//  AddToCartViewModel.swift
//  Bankezy
//
//  Created by Andy on 20/12/2024.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import Kingfisher

struct DishInforResponse: Codable {
  let id: String?
  let title: String?
  let description: String?
  let size: [String]?
  let image: [String]?
  let price: Double?
}

struct AddToCartResponse: Codable {
  struct Cart: Codable {
    let id: String?
    let name: String?
    let size: String?
    let qty: Int?
    let price: Int?
    let totalPrice: Int?
  }

  let status: String?
  let message: String?
  let cart: Cart?
}

class AddToCartViewModel {
    let provider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.delayedStub(2))
    
    let dishId: String?
    
    init(dishId: String?) {
        self.dishId = dishId
    }
    
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let dishInforDriver = input.viewDidLoad
            .flatMapLatest { _ in
                self.provider.rx.request(.getDishInfor)
                    .map(DishInforResponse.self)
                    .asObservable()
                    .catchErrorJustComplete()
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let isSuccessDriver = input.addToCartButtonTapped
            .withLatestFrom(input.size)
            .withLatestFrom(input.qty) { ($0, $1) }
            .flatMapLatest { combine in
            let (size, qty) = combine 
                
                return self.provider.rx.request(.addToCart(id: self.dishId, size: size, qty: qty))
                    .map { response in
                        if (200...299).contains(response.statusCode) {
                            return true
                        } else {
                            let errorModel = try? JSONDecoder().decode(ErrorModel.self, from: response.data)
//                            throw errorModel
                        }
                        return false
                    }
                    .trackError(errorTracker)
            }
            .asDriver(onErrorJustReturn: false)
        
        
        return .init(dishInfor: dishInforDriver,
                     addToCart: isSuccessDriver,
                     error: errorTracker.asDriver())
    }
}

extension AddToCartViewModel {
    struct Input {
        let viewDidLoad:  Observable<Void>
        let size: Observable<String>
        let qty: Observable<String>
        let addToCartButtonTapped: Observable<Void>
    }
    
    struct Output {
        let dishInfor: Driver<DishInforResponse>
        let addToCart: Driver<Bool>
        let error: Driver<Error>
    }
}


