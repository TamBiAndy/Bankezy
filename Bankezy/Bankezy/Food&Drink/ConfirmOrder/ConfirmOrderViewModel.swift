//
//  ConfirmOrderViewModel.swift
//  Bankezy
//
//  Created by Andy on 26/12/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

struct OrderInforResponse: Codable {
  struct DeliveryTo: Codable {
    let phoneNumber: String?
    let address: String?
    let distance: Double?
  }

  struct Brand: Codable {
    let id: String?
    let brandName: String?
  }

  struct Item: Codable {
    let productID: String?
    let image: String?
    let productName: String?
    let quantity: Int?
    let price: Double?

    private enum CodingKeys: String, CodingKey {
      case productID = "productId"
      case image
      case productName
      case quantity
      case price
    }
  }

  let id: String?
  let status: String?
  let message: String?
  let deliveryTo: DeliveryTo?
  let brand: Brand?
  let items: [Item]?
  let totalAmount: Double?
  let discount: Int?
  let shippingFee: Int?
  let finalAmount: Double?
}

class ConfirmOrderViewModel {
    let provider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.delayedStub(2))
    
    func transform(input: Input) -> Output {
        
        let orderInforObv = input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.orderItemsInfor)
                    .map(OrderInforResponse.self)
                    .asObservable()
                    .catchErrorJustComplete()
            }
        
        let orderInforDriver = orderInforObv
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(orderInfor: orderInforDriver)
    }
}

extension ConfirmOrderViewModel {
    struct Input {
        let viewDidload: Observable<Void>
    }
    
    struct Output {
        let orderInfor: Driver<OrderInforResponse>
    }
}
