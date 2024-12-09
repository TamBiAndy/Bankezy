//
//  FilterViewController.swift
//  Bankezy
//
//  Created by Andy on 08/12/2024.
//

import UIKit
import RxSwift
import RxCocoa


struct SortbyFilter {
    let title: String?
    let leftIcon: UIImage?
    let rightIcon: UIImage?
}
class FilterViewController: UIViewController {

    //MARK: - IBOutlet
    
    @IBOutlet weak var btnCategory: UIButton!
    
    @IBOutlet weak var lineViewCategory: UIView!
    
    @IBOutlet weak var btnSortby: UIButton!
    
    @IBOutlet weak var lineViewSortby: UIView!
    
    @IBOutlet weak var btnPrice: UIButton!
    
    @IBOutlet weak var lineViewPrice: UIView!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    @IBOutlet weak var sortbyTableView: UITableView!
    
    @IBOutlet weak var priceView: UIView!
    
    @IBOutlet weak var tfMinPrice: UITextField!
    
    @IBOutlet weak var tfMaxPrice: UITextField!
    
    @IBOutlet weak var btnComplete: UIButton!
    
    //MARK: UIComponent
    lazy var searchBar = UISearchBar()
        .with(\.placeholder, setTo: "Search on Coody")
        .with(\.searchBarStyle, setTo: .minimal)
        .with(\.backgroundColor, setTo: .white)
        .with(\.frame.size.height, setTo: 44)
    
    lazy var categoryFlowlayout: UICollectionViewFlowLayout = {
       let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = .init(width: 120, height: 138)
        flowlayout.scrollDirection = .horizontal
        flowlayout.minimumLineSpacing = 0
        flowlayout.minimumInteritemSpacing = 0
        return flowlayout
    }()
    
    //MARK: Variables
    var viewModel: FilterViewModel
    
    let sortbyRelay = BehaviorRelay<[SortbyFilter]>(value: [
        SortbyFilter(title: "Recomended", leftIcon: UIImage(named: "bookmark"), rightIcon: UIImage(named: "ic_select")),
        SortbyFilter(title: "Fastest Delivery", leftIcon: UIImage(named: "Time"), rightIcon: UIImage(named: "")),
        SortbyFilter(title: "Most Popular", leftIcon: UIImage(named: "Flame"), rightIcon: UIImage(named: ""))
    ])
    
    //MARK: Initializers
    init(viewModel: FilterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "FilterViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchTextField()
        filterSelected()
        bindingData()
        setupVew()
    }
    
    //MARK: Private func
    
    private func bindingData() {
        let input = FilterViewModel.Input(viewDidload: .just(()))
        let output = viewModel.transform(input: input)
        
        sortbyRelay
            .bind(to: sortbyTableView.rx.items(cellIdentifier: "sortbyTableViewCell", cellType: sortbyTableViewCell.self)) { index, sortby, cell in
                cell.bind(with: sortby)
            }
            .disposed(by: rx.disposeBag)
        
        output.category
            .drive(categoryCollectionView.rx.items(cellIdentifier: "CategoryCollectionViewCell", cellType: CategoryCollectionViewCell.self)) { index, category, cell in
                cell.lblCategoryName.text = category.title
                cell.imgFood.kf.setImage(with: URL(string: category.image ?? ""))
            }
            .disposed(by: rx.disposeBag)
    }
    private func filterSelected() {
       let itemFilterSelected = Observable.merge(
            btnCategory.rx.tap.mapTo(Filter.category).asObservable(),
            btnSortby.rx.tap.mapTo(Filter.sortby).asObservable(),
            btnPrice.rx.tap.mapTo(Filter.price).asObservable()
        ).startWith(Filter.category)
        
        let filterSelectedDriver = itemFilterSelected
            .bind(onNext: { itemFilterSelected in
                switch itemFilterSelected {
                case .category:
                    self.categoryCollectionView.isHidden = false
                    self.sortbyTableView.isHidden = true
                    self.priceView.isHidden = true
                    
                    self.btnCategory.setTitleColor(UIColor(hexString: "EF9F27"), for: .normal)
                    self.lineViewCategory.backgroundColor = UIColor(hexString: "EF9F27")
                    
                    [self.btnPrice, self.btnSortby].forEach { button in
                        button?.setTitleColor(UIColor(hexString: "172B4D"), for: .normal)
                    }
                    
                    [self.lineViewPrice, self.lineViewSortby].forEach { view in
                        view?.backgroundColor = .clear
                    }
                    
                case .sortby:
                    self.categoryCollectionView.isHidden = true
                    self.sortbyTableView.isHidden = false
                    self.priceView.isHidden = true
                    
                    self.btnSortby.setTitleColor(UIColor(hexString: "EF9F27"), for: .normal)
                    self.lineViewSortby.backgroundColor = UIColor(hexString: "EF9F27")
                    
                    [self.btnPrice, self.btnCategory].forEach { button in
                        button?.setTitleColor(UIColor(hexString: "172B4D"), for: .normal)
                    }
                    
                    [self.lineViewPrice, self.lineViewCategory].forEach { view in
                        view?.backgroundColor = .clear
                    }
                case .price:
                    self.categoryCollectionView.isHidden = true
                    self.sortbyTableView.isHidden = true
                    self.priceView.isHidden = false
                    
                    self.btnPrice.setTitleColor(UIColor(hexString: "EF9F27"), for: .normal)
                    self.lineViewPrice.backgroundColor = UIColor(hexString: "EF9F27")
                    
                    [self.btnCategory, self.btnSortby].forEach { button in
                        button?.setTitleColor(UIColor(hexString: "172B4D"), for: .normal)
                    }
                    
                    [self.lineViewCategory, self.lineViewSortby].forEach { view in
                        view?.backgroundColor = .clear
                    }
                }
            })
    }
    
    private func setupVew() {
        let nibCell = UINib(nibName: "CategoryCollectionViewCell", bundle: nil)
        categoryCollectionView.register(nibCell, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        categoryCollectionView.collectionViewLayout = categoryFlowlayout
        categoryCollectionView.showsHorizontalScrollIndicator = false
        
        let nibcell2 = UINib(nibName: "sortbyTableViewCell", bundle: nil)
        sortbyTableView.register(nibcell2, forCellReuseIdentifier: "sortbyTableViewCell")
        sortbyTableView.separatorStyle = .none
    }
    
    private func setupSearchTextField() {
        navigationItem.titleView = searchBar
        
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
            let imageView = UIImageView(image: UIImage(named: "ic_location"))
            imageView.frame = CGRect(x: 0, y: 0, width: 36, height: 24)
            searchTextField.leftView = imageView
            searchTextField.leftViewMode = .always
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Search on Coody", attributes: [.foregroundColor: UIColor(hexString: "7A869A"), .font: UIFont.regular(size: 14)])
        }
    }



}
