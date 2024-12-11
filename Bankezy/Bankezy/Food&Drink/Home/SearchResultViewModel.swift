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
        let itemsObv = input.searchText
            .compactMap { $0 }
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // Chờ user dừng gõ trong 300ms
            .distinctUntilChanged()
            .flatMapLatest { searchKey in
                self.provider.rx.request(.searchPartner)
                    .map(SearchPartnerResponse.self)
                    .map { response in
                        (searchKey, response.partners ?? [])
                    }
            }
            .asObservable()
            .catchErrorJustComplete()
        
        let itemsDriver = itemsObv
            .map { searchKey, items in
                items.filter { item in
                    return item.titleBrand?.lowercased().contains(searchKey.lowercased()) ?? false
                }
            }
            .asDriver(onErrorJustReturn: [])
        
        return .init(items: itemsDriver)
    }
}

extension SearchResultViewModel {
    struct Input {
        let searchText: Observable<String?>
    }
    
    struct Output {
        let items: Driver<[SearchPartnerResponse.Partner]>
    }
}
