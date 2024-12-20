//
//  SearchResultViewModel.swift
//  Bankezy
//
//  Created by Andy on 11/12/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

struct SearchPartnerResponse: Codable {
  struct Partner: Codable {
    let id: String?
    let image: String?
    let titleBrand: String?
    let price: Int?
    let dish: String?
  }

  let id: String?
  let partners: [Partner]?
}

class SearchResultViewModel {
    let provider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.delayedStub(2))
    var items = BehaviorRelay<[SearchPartnerResponse.Partner]>(value: [])
    
    func transform(input: Input) -> Output {
        let itemsObv = input.viewDidLoad
            .flatMapLatest { _ in
                self.provider.rx.request(.searchPartner)
                    .map(SearchPartnerResponse.self)
                    .compactMap(\.partners)
            }
        
        let itemsDriver = Observable.combineLatest(
            input.searchText.startWith("").compactMap { $0 },
            itemsObv
        )
        .map { combined -> [SearchPartnerResponse.Partner] in
            let (searchKey, items) = combined
            
            if searchKey.isEmpty {
                return items
            } else {
                return items.filter { item in
                    return (item.titleBrand?.lowercased().contains(searchKey.lowercased()) ?? false) || item.dish == searchKey
                }
            }
        }
        .asDriver(onErrorJustReturn: [])
        
        return .init(items: itemsDriver)
    }
}

extension SearchResultViewModel {
    struct Input {
        let viewDidLoad: Observable<Void>
        let searchText: Observable<String?>
    }
    
    struct Output {
        let items: Driver<[SearchPartnerResponse.Partner]>
    }
}
