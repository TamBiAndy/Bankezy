//
//  FilterViewModel.swift
//  Bankezy
//
//  Created by Andy on 09/12/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import NSObject_Rx

enum Filter {
    case category
    case sortby
    case price
}


class FilterViewModel {
    let bag = DisposeBag()
    
    let provider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.delayedStub(2))
    
    let sortbyRelay = BehaviorRelay<[SortbyFilter]>(value: [
        SortbyFilter(title: "Recomended", leftIcon: UIImage(named: "bookmark"), rightIcon: UIImage(named: "ic_select")),
        SortbyFilter(title: "Fastest Delivery", leftIcon: UIImage(named: "Time"), rightIcon: UIImage(named: "")),
        SortbyFilter(title: "Most Popular", leftIcon: UIImage(named: "Flame"), rightIcon: UIImage(named: ""))
    ])
    
    var selectedCategoriesRelay = BehaviorRelay<[CategoryResponse.Category]>(value: [])
    var selectedSortbyRelay = BehaviorRelay<[SortbyFilter]>(value: [])
    
    func transform(input: Input) -> Output {
        let categoryObv = input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.getCategory)
                    .asObservable()
                    .catchErrorJustComplete()
            }
            .map(CategoryResponse.self)
        
        let categoryDriver = categoryObv
            .compactMap(\.category)
            .asDriver(onErrorJustReturn: [])
        
        input.categorySelected
            .withLatestFrom(selectedCategoriesRelay) { selected, current in
                var updated = current
                if let index = updated.firstIndex(where: { $0.id == selected.id }) {
                    updated.remove(at: index)
                } else {
                    updated.append(selected)
                }
                return updated
            }
            .bind(to: selectedCategoriesRelay)
            .disposed(by: bag)
        
        input.sortbySelected
            .withLatestFrom(selectedSortbyRelay) { selected, current in
                var update = current
                if let index = update.firstIndex(where: { $0.title == selected.title}) {
                    update.remove(at: index)
                } else {
                    update.append(selected)
                }
                return update
            }
            .bind(to: selectedSortbyRelay)
            .disposed(by: bag)
        
        let filterInfo = Observable.combineLatest(
            selectedCategoriesRelay.asObservable().startWith([]),
            selectedSortbyRelay.asObservable().startWith([]),
            input.priceMin.startWith(nil),
            input.priceMax.startWith(nil)
        )
        
        let filterInforDriver = input.completeTapped
            .withLatestFrom(filterInfo)
            .map { filterInfo in
                let (categories, sortby, priceMin, priceMax) = filterInfo
                return FilterInfo(
                    categorys: categories.compactMap(\.title),
                    sortBy: sortby.compactMap(\.title),
                    minPrice: Double(priceMin ?? ""),
                    maxPrice: Double(priceMax ?? "")
                )
            }
            .asDriver(onErrorDriveWith: .empty())
        
        return .init(
            category: categoryDriver, 
            sortbyDriver: sortbyRelay.asDriver(),
            filterInfor: filterInforDriver,
            error: .empty()
        )
    }
}

extension FilterViewModel {
    struct Input {
        let viewDidload: Observable<Void>
        let categorySelected: Observable<CategoryResponse.Category>
        let sortbySelected: Observable<SortbyFilter>
        let priceMin: Observable<String?>
        let priceMax: Observable<String?>
        let completeTapped: Observable<Void>
    }
    
    struct Output {
        let category: Driver<[CategoryResponse.Category]>
        let sortbyDriver: Driver<[SortbyFilter]>
        let filterInfor: Driver<FilterInfo>
        let error: Driver<Error>
    }
}
