//
//  DeliveryStatusViewModel.swift
//  Bankezy
//
//  Created by Andy on 02/01/2025.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import MapKit
import Starscream

struct DeliveryStatusResponse: Codable {
  struct Data: Codable {
    struct Location: Codable {
      let latitude: Double?
      let longitude: Double?
      let address: String?
    }
      
    struct CurrentDriverLocation: Codable {
      let latitude: Double?
      let longitude: Double?
      let lastUpdated: String?
    }

    struct DriverInfo: Codable {
      let name: String?
      let phone: String?
      let vehicle: String?
      let profilePicture: String?
      let iconGoing: String?
    }

    let orderID: String?
    let orderStatus: String?
    let startTime: String?
    let deliveryTimeEstimate: String?
    let pickupLocation: Location?
    let deliveryLocation: Location?
    let currentDriverLocation: Location?
    let driverInfo: DriverInfo?

    private enum CodingKeys: String, CodingKey {
      case orderID = "orderId"
      case orderStatus
      case startTime
      case deliveryTimeEstimate
      case pickupLocation
      case deliveryLocation
      case currentDriverLocation
      case driverInfo
    }
  }

  let status: String?
  let message: String?
  let data: Data?
}

class DeliveryStatusViewModel {
    let provider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.delayedStub(2))
    
    func transform(input: Input) -> Output {
        let location = input.viewDidload
            .flatMapLatest {
                self.provider.rx.request(.getDeliveryStatus)
                    .map(DeliveryStatusResponse.self)
            }
            .asDriver(onErrorDriveWith: .empty())
        
        return .init(location: location)
    }
}

extension DeliveryStatusViewModel {
    struct Input {
        let viewDidload: Observable<Void>
    }
    
    struct Output {
        let location: Driver<DeliveryStatusResponse>
    }
}
