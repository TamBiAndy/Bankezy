//
//  PopularItemsTableViewCell.swift
//  Bankezy
//
//  Created by Andy on 17/12/2024.
//

import UIKit
import RxSwift
import RxCocoa

class PopularItemsTableViewCell: UITableViewCell {
    
//    struct ViewState {
//        let id: String?
//        let popularItems: BehaviorRelay<[PopularItemResponse.PopularItem]>
//    }
    
    @IBOutlet weak var popularItemsCollectionView: UICollectionView!
    
    let popularItems = BehaviorRelay<[PopularItemResponse.PopularItem]>(value: [])
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
       let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = .init(width: 180, height: 236)
        flowlayout.scrollDirection = .horizontal
        flowlayout.minimumLineSpacing = -27
        flowlayout.minimumInteritemSpacing = 0
        return flowlayout
    }()
    
    var selectedItem: ((PopularItemResponse.PopularItem) -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        bindingData()
    }
 
    func bind(with items: [PopularItemResponse.PopularItem]) {
        self.popularItems.accept(items)
    }
    
    private func bindingData() {
        popularItems
                  .bind(to: popularItemsCollectionView.rx.items(cellIdentifier: "PopularItemsCollectionViewCell", cellType: PopularItemsCollectionViewCell.self)) { index, item, cell in
                      cell.bind(with: item)
                  }
                  .disposed(by: rx.disposeBag)
        
        popularItemsCollectionView.rx.modelSelected(PopularItemResponse.PopularItem.self)
            .bind(onNext: { item in
                self.selectedItem?(item)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func setupView() {
        let nibCell = UINib(nibName: "PopularItemsCollectionViewCell", bundle: nil)
        popularItemsCollectionView.register(nibCell, forCellWithReuseIdentifier: "PopularItemsCollectionViewCell")
        popularItemsCollectionView.collectionViewLayout = flowLayout
        popularItemsCollectionView.showsHorizontalScrollIndicator = false
        
//        let nibcell = UINib(nibName: "PopularItemsTableViewCell", bundle: nil)
//        popularItemsCollectionView.register(nibcell, forCellWithReuseIdentifier: "PopularItemsTableViewCell")
    }
    
}
