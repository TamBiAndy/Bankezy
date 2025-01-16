//
//  HistoryOrderViewModel.swift
//  Bankezy
//
//  Created by Andy on 14/01/2025.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

struct HistoryOrderResponse: Codable {
  struct Data: Codable {
    let orderID: String?
    let orderDate: String?
    let type: String?
    let status: String?
    let totalPrice: Int?
    let image: String?
    let brandName: String?
    let brandAddress: String?
    let itemsQty: Int?
  }

  let status: String?
  let messege: String?
  let data: [Data]?
}

class HistoryOrderViewModel {
    
    let provider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.delayedStub(2))
    func transform(input: Input) -> Output {
        
       let historyDriver = input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.getHistoryOrder)
                    .map(HistoryOrderResponse.self)
            }
            .asObservable()
            .catchErrorJustComplete()
            .compactMap(\.data)
            .asDriver(onErrorDriveWith: .empty())
        
        let onGoingDriver = input.viewDidload
             .flatMapLatest { _ in
                 self.provider.rx.request(.getOngoingList)
                     .map(HistoryOrderResponse.self)
             }
             .asObservable()
             .catchErrorJustComplete()
             .compactMap(\.data)
             .asDriver(onErrorDriveWith: .empty())
        
        let yourOrderDriver = Driver.combineLatest(
            input.segmentSelected.asDriver(onErrorJustReturn: .history),
            historyDriver,
            onGoingDriver
        )
            .map { segmentSelected, historyInfor, onGoingInfor in
                switch segmentSelected {
                case .history:
                    return historyInfor
                case .onGoing:
                    return onGoingInfor
                }
            }
        
        return Output(yourOrder: yourOrderDriver)
    }
}

extension HistoryOrderViewModel {
    struct Input {
        let viewDidload: Observable<Void>
        let segmentSelected: Observable<YourOrderHistory>
    }
    
    struct Output {
        let yourOrder: Driver<[HistoryOrderResponse.Data]>
    }
}

enum YourOrderHistory {
    case onGoing
    case history
}
