//
//  BestPartnerAllViewModel.swift
//  Bankezy
//
//  Created by Andy on 05/12/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

class BestPartnerAllViewModel {
    let provider = MoyaProvider<APITarget>(stubClosure: MoyaProvider.delayedStub(2))
    
    func transform(input: Input) -> Output {
        let allPartnerObv = input.viewDidload
            .flatMapLatest { _ in
                self.provider.rx.request(.getPartnerAll)
            }
            .asObservable()
            .map(BestPartnersResponse.self)
        
        let allPartnerDriver = allPartnerObv
            .compactMap(\.partners)
            .asDriver(onErrorJustReturn: [])
        
        
        return .init(allPartner: allPartnerDriver)
    }
}

extension BestPartnerAllViewModel {
    struct Input {
        let viewDidload: Observable<Void>
    }
    
    struct Output {
        let allPartner: Driver<[BestPartnersResponse.Partner]>
    }
}
