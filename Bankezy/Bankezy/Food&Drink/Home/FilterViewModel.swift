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

enum Filter {
    case category
    case sortby
    case price
}


class FilterViewModel {
    let provider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.delayedStub(2))
    
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
        
        return .init(category: categoryDriver)
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
        let isSuccess: Driver<Bool>
        let error: Driver<Error>
    }
}
