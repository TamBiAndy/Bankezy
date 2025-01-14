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
import RxSwiftExt

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
    var quantity: Int?
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
  var items: [Item]?
  var totalAmount: Double?
  let discount: Int?
  let shippingFee: Int?
  var finalAmount: Double?
}

class ConfirmOrderViewModel {
    let provider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.delayedStub(2))
    let bag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let errorTracker = ErrorTracker()
        let orderInfoRelay = BehaviorRelay<OrderInforResponse?>(value: nil)
        
        input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.orderItemsInfor)
                    .map(OrderInforResponse.self)
                    .asObservable()
                    .catchErrorJustComplete()
            }
            .bind(to: orderInfoRelay)
            .disposed(by: bag)
        
        input.itemChanged
            .withLatestFrom(orderInfoRelay.compactMap { $0 }) { ($0, $1) }
            .map { itemChanged, orderInfo in
                var currentOrder = orderInfo
                var currentItems = orderInfo.items ?? []
                
                if let index = currentItems.firstIndex(where: { $0.productID == itemChanged.productID }) {
                    currentItems[index] = itemChanged
                }
                
                currentOrder.items = currentItems
                
                let totalAmount = currentItems.reduce(0.0) { partialResult, item in
                    return partialResult + (item.price ?? 0.0) * Double(item.quantity ?? 0)
                }
                
                let finalAmount = totalAmount
                + Double(currentOrder.shippingFee ?? 0)
                + Double(currentOrder.discount ?? 0)
                
                currentOrder.totalAmount = totalAmount
                currentOrder.finalAmount = finalAmount
                
                return currentOrder
            }
            .bind(to: orderInfoRelay)
            .disposed(by: bag)
        
        let orderInforDriver = orderInfoRelay
            .compactMap { $0 }
            .asDriver(onErrorDriveWith: .empty())
        
        let paymentRequest = Observable.combineLatest(
            input.paymentMethod,
            orderInfoRelay
        )
        .map { paymentMethod, orderInfo in
            
            return OrderRequest(
                receiveInfor: orderInfo?.deliveryTo,
                items: orderInfo?.items,
                totalPrice: orderInfo?.finalAmount,
                paymentMethod: paymentMethod)
        }
        
        let isSucessDriver = input.submitTapped
            .withLatestFrom(paymentRequest)
            .flatMapLatest { request in
                return self.provider.rx.request(.confirmOrder(orderInfor: request))
                    .map { respone in
                        if (200...299).contains(respone.statusCode) {
                            return true
                        } else {
                            let errorModel = try JSONDecoder().decode(ErrorModel.self, from: respone.data)
                            throw errorModel
                        }
                    }
                    .trackError(errorTracker)
            }
            .asDriver(onErrorJustReturn: false)
            
        
        return Output(
            orderInfor: orderInforDriver,
            isSuccess: isSucessDriver,
            error: errorTracker.asDriver())
    }
}

extension ConfirmOrderViewModel {
    struct Input {
        let viewDidload: Observable<Void>
        let submitTapped: Observable<Void>
        let paymentMethod: Observable<PaymentMethod>
        let itemChanged: Observable<OrderInforResponse.Item>
    }
    
    struct Output {
        let orderInfor: Driver<OrderInforResponse>
        let isSuccess: Driver<Bool>
        let error: Driver<Error>
    }
}

struct OrderRequest {
    let receiveInfor: OrderInforResponse.DeliveryTo?
    let items: [OrderInforResponse.Item]?
    let totalPrice: Double?
    let paymentMethod: PaymentMethod?
}

enum PaymentMethod {
    case creditCard
    case cash
}
