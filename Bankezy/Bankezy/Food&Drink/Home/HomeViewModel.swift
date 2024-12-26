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
        let timeShipping: Int?
        let buyCount: Int?
        let price: Double?
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
            .debug("DEBUG partnersNearbyDriver")
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
            .debug("DEBUG partnersSalesDriver")
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
            .debug("DEBUG partnersRateDriver")
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
            .debug("DEBUG partnersFastDriver")
            .asDriver(onErrorJustReturn: [])
        
        let partners = Driver.combineLatest(
            input.filterInfo.asDriver(onErrorDriveWith: .empty()),
            input.parterSelected.asDriver(onErrorJustReturn: .nearby),
            partnersNearbyDriver, partnersSalesDriver, partnersFastDriver, partnersRateDriver
        )
        .map { filterInfo, partnerSelected, nearbyPartners, salesPartners, fastPartners, ratePartners in
            
            
            
            switch partnerSelected {
            case .nearby:
                if let filterInfo {
                    let filteredPatner = nearbyPartners.filter { partner in
                        self.isValidCategory(partner: partner, filterInfo: filterInfo) &&
                        self.isValidSortby(partner: partner, filterInfo: filterInfo) &&
                        self.isValidPrice(partner: partner, filterInfo: filterInfo)
                        
                    }
                    return filteredPatner
                } else {
                    return nearbyPartners
                }
                
            case .sales:
                if let filterInfo {
                    let filteredPatner = salesPartners.filter { partner in
                        self.isValidCategory(partner: partner, filterInfo: filterInfo) &&
                        self.isValidSortby(partner: partner, filterInfo: filterInfo) &&
                        self.isValidPrice(partner: partner, filterInfo: filterInfo)
                    }
                    return filteredPatner
                } else {
                    return salesPartners
                }
            case .fast:
                if let filterInfo {
                    let filteredPatner = fastPartners.filter { partner in
                        self.isValidCategory(partner: partner, filterInfo: filterInfo) &&
                        self.isValidSortby(partner: partner, filterInfo: filterInfo) &&
                        self.isValidPrice(partner: partner, filterInfo: filterInfo)
                    }
                    return filteredPatner
                } else {
                    return fastPartners
                }
            case .rate:
                if let filterInfo {
                    let filteredPatner = ratePartners.filter { partner in
                        self.isValidCategory(partner: partner, filterInfo: filterInfo) &&
                        self.isValidSortby(partner: partner, filterInfo: filterInfo) &&
                        self.isValidPrice(partner: partner, filterInfo: filterInfo)
                    }
                    return filteredPatner
                } else {
                    return ratePartners
                }
            }
        }
        
        return .init(
            category: categoryDriver,
            bestPartners: bestPartnersDriver,
            partners: partners
        )
    }
    
    func isValidCategory(partner: BestPartnersResponse.Partner, filterInfo: FilterInfo) -> Bool {
        return filterInfo.categorys.contains(partner.category ?? [])
    }
    
    func isValidSortby(partner: BestPartnersResponse.Partner, filterInfo: FilterInfo) -> Bool {
        var isValidSortBy = true
        
        if filterInfo.sortBy.contains(where: { $0 == "Recommended" }) {
            isValidSortBy = partner.rating ?? 0 >= 4.0
        }
        if filterInfo.sortBy.contains(where: { $0 == "FastestDelivery" }) {
            isValidSortBy = partner.timeShipping ?? 0 <= 5
        }
        if filterInfo.sortBy.contains(where: { $0 == "Most Popular"}) {
            isValidSortBy = partner.buyCount ?? 0 >= 100
        }
        return isValidSortBy
    }
    
    func isValidPrice(partner: BestPartnersResponse.Partner, filterInfo: FilterInfo) -> Bool {
        let partnerPrice = partner.price ?? 0
         let isValidPrice =
        (filterInfo.minPrice == nil || partnerPrice >= filterInfo.minPrice!) &&
        (filterInfo.maxPrice == nil || partnerPrice <= filterInfo.maxPrice!)
        return isValidPrice
    }
    
    
}

extension HomeViewModel {
    struct Input {
        let viewDidload: Observable<Void>
        let parterSelected: Observable<Partner>
        let filterInfo: Observable<FilterInfo?>
    }
    
    struct Output {
        let category: Driver<[CategoryResponse.Category]>
        let bestPartners: Driver<[BestPartnersResponse.Partner]>
        let partners: Driver<[BestPartnersResponse.Partner]>
    }
}

struct FilterInfo {
    let categorys: [String]
    let sortBy: [String]
    let minPrice: Double?
    let maxPrice: Double?
}
