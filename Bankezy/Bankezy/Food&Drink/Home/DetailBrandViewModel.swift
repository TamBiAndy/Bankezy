//
//  DetailBrandViewModel.swift
//  Bankezy
//
//  Created by Andy on 13/12/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import RxDataSources

struct BrandDetailResponse: Codable {
  let id: String?
  let titleBrand: String?
  let service: String?
  let openStatus: String?
  let location: String?
  let rating: Double?
  let shippingTime: String?
  let shippingFee: String?
  let discount: String?
}

struct PopularItemResponse: Codable {
    struct PopularItem: Codable {
       let id: String?
       let image: String?
       let title: String?
       let price: Double?
       let dish: String?
     }

     let id: String?
     let popularItems: [PopularItem]?
}

struct MenuResponse: Codable {
  struct Menu: Codable {
    struct Item: Codable {
      let id: Int?
      let image: String?
      let title: String?
      let price: Double?
      let type: String?
    }

    let header: String?
    let items: [Item]?
  }

  let menu: [Menu]?
}

struct ReviewBrandResponse: Codable {
  struct Review: Codable {
    let userID: String?
    let userName: String?
    let avatarURL: String?
    let createdAt: String?
    let rating: Int?
    let comment: String?
    let likes: Int?
    let reviewImage: [String]?

    private enum CodingKeys: String, CodingKey {
      case userID = "user_id"
      case userName = "user_name"
      case avatarURL = "avatar_url"
      case createdAt = "created_at"
      case rating
      case comment
      case likes
      case reviewImage = "review_image"
    }
  }

  let id: String?
  let reviews: [Review]?
}

class DetailBrandViewModel {
    typealias SectionDataSource = SectionModel<Section, Item>
    
    let provider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.delayedStub(2))
    var brandId: String?
    
    init(brandId: String? = nil) {
        self.brandId = brandId
    }
    
    func transform(input: Input) -> Output {
        let brandDetailDriver = input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.brandDetail(brandDetail: self.brandId))
                    .map(BrandDetailResponse.self)
            }
            .asObservable()
            .catchErrorJustComplete()
            .asDriver(onErrorDriveWith: .empty())
        
        let popularItemsObv = input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.popularItemsOfBrand)
                    .map(PopularItemResponse.self)
                    .asObservable()
                    .catchErrorJustComplete()
            }
        
        let menuItemsObv = input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.getMenuOfBrand)
                    .map(MenuResponse.self)
                    .asObservable()
                    .catchErrorJustComplete()
            }
        
        let reviewBrandObv = input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.getReviewBrand)
                    .map(ReviewBrandResponse.self)
                    .debug("Review")
                    .asObservable()
                    .catchErrorJustComplete()
            }
        
        let sectionDriver = Observable.combineLatest(
            input.optionSelected,
            popularItemsObv.compactMap(\.popularItems).debug("popularItems"),
            menuItemsObv.compactMap(\.menu).debug("menu"),
            reviewBrandObv.compactMap(\.reviews).debug("review")
        )
        .map { option, popularItems, menuItems, reviewBrandItems -> [SectionDataSource] in
            switch option {
            case .delivery:
                var sections: [SectionDataSource] = []
                
                if !popularItems.isEmpty {
                    sections.append(
                        SectionDataSource(
                            model: .popular,
                            items: [.popular(popularItems)]
                        )
                    )
                }
                
                if !menuItems.isEmpty {
                    let menuSections: [SectionDataSource] = menuItems.compactMap { menu -> SectionDataSource? in
                        guard let items = menu.items,
                              !items.isEmpty else { return nil }
                        
                        return .init(
                            model: .menu(menu),
                            items: items.map { .dish($0) }
                        )
                    }
                    
                    sections.append(contentsOf: menuSections)
                }
                
                return sections
                
            case .review:
                var sections: [SectionDataSource] = []
                
                if !reviewBrandItems.isEmpty {
                    sections.append(
                        SectionDataSource(
                            model: .review,
                            items: reviewBrandItems.map { .review($0) }
                        )
                    )
                }
                return sections
            }
        }
        .asDriver(onErrorDriveWith: .empty())
        
        return .init(
            brandDetail: brandDetailDriver,
            sections: sectionDriver
        )
    }
    
}

enum Section {

    case popular
    case menu(MenuResponse.Menu)
    case review
    
    var title: String {
        switch self {
        case .popular:
            return "Popular Items"
        case .menu(let menu):
            return menu.header ?? ""
        case .review:
            return ""
        }
    }
    
    var viewForFooterInSection: UIView? {
        switch self {
        case .popular, .menu, .review:
            let footerView = UIView()
            footerView.backgroundColor = .clear
            let line = UIView()
            line.backgroundColor = UIColor(hexString: "F4F5F7")
            line.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1)
            footerView.addSubview(line)
            return footerView
        }
    }
    
}

enum Item {
    case popular([PopularItemResponse.PopularItem])
    case dish(MenuResponse.Menu.Item)
    case review(ReviewBrandResponse.Review)
}

extension DetailBrandViewModel {
    struct Input {
        let viewDidload: Observable<Void>
        let optionSelected: Observable<DetailOption>
    }
    
    struct Output {
        let brandDetail: Driver<BrandDetailResponse>
        let sections: Driver<[SectionDataSource]>
    }
}
