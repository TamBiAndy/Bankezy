//
//  HomeViewModel.swift
//  Bankezy
//
//  Created by Andy on 03/12/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Moya


struct CategoryResponse: Codable {
  struct Category: Codable {
    let id: String?
    let image: String?
    let title: String?
  }

  let id: String?
  let category: [Category]?
}

struct BestPartnersResponse: Codable {
    struct Partner: Codable {
        let id: String?
        let image: String?
        let titleBrand: String?
        let openStatus: String?
        let location: String?
        let rating: Double?
        let distance: Double?
        let shippingFee: String?
        let category: [String]?
    }
    
    let id: String?
    let partners: [Partner]?
}

enum Partner {
    case nearby
    case sales
    case rate
    case fast
}

class HomeViewModel {
    let provider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.delayedStub(2))
    
    func transfer(input: Input) -> Output {
        let categoryObv = input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.getCategory)
            }
            .map(CategoryResponse.self)
        
        let categoryDriver = categoryObv
            .compactMap(\.category)
            .asDriver(onErrorJustReturn: [])
        
        let bestpartnersObv = input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.getBestpartner)
                    .asObservable()
                    .catchErrorJustComplete()
            }
            .map(BestPartnersResponse.self)
        
        let bestPartnersDriver = bestpartnersObv
            .compactMap(\.partners)
            .asDriver(onErrorJustReturn: [])
        
        let partnersNearbyObv = input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.getPartnerNearby)
                    .asObservable()
                    .catchErrorJustComplete()
            }
            .map(BestPartnersResponse.self)
        
        let partnersNearbyDriver = partnersNearbyObv
            .compactMap(\.partners)
            .asDriver(onErrorJustReturn: [])
        
        let partnersSalesObv = input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.getPartnerSales)
                    .asObservable()
                    .catchErrorJustComplete()
            }
            .map(BestPartnersResponse.self)
        
        let partnersSalesDriver = partnersSalesObv
            .compactMap(\.partners)
            .asDriver(onErrorJustReturn: [])
        
        let partnersRateObv = input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.getPartnerRating)
                    .asObservable()
                    .catchErrorJustComplete()
            }
            .map(BestPartnersResponse.self)
        
        let partnersRateDriver = partnersRateObv
            .compactMap(\.partners)
            .asDriver(onErrorJustReturn: [])
        
        let partnersFastObv = input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.getPartnerFast)
                    .asObservable()
                    .catchErrorJustComplete()
            }
            .map(BestPartnersResponse.self)
        
        let partnersFastDriver = partnersFastObv
            .compactMap(\.partners)
            .asDriver(onErrorJustReturn: [])
        
        let partners = Driver.combineLatest(
            input.parterSelected.asDriver(onErrorJustReturn: .nearby),
            partnersNearbyDriver, partnersSalesDriver, partnersFastDriver, partnersRateDriver
        )
        .map { partnerSelected, nearbyPartners, salesPartners, fastPartners, ratePartners in
            
            switch partnerSelected {
            case .nearby:
                return nearbyPartners
            case .sales:
                return salesPartners
            case .fast:
                return fastPartners
            case .rate:
                return ratePartners
            }
        }
        
        return .init(
            category: categoryDriver,
            bestPartners: bestPartnersDriver,
            partners: partners
        )
    }
}

extension HomeViewModel {
    struct Input {
        let viewDidload: Observable<Void>
        let parterSelected: Observable<Partner>
    }
    
    struct Output {
        let category: Driver<[CategoryResponse.Category]>
        let bestPartners: Driver<[BestPartnersResponse.Partner]>
        let partners: Driver<[BestPartnersResponse.Partner]>
    }
}
