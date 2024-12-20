//
//  HomeViewController.swift
//  Bankezy
//
//  Created by Andy on 03/12/2024.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import SnapKit
import PanModal
import FloatingPanel

class HomeViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var filterView: UIView!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    @IBOutlet weak var bestPartnerCollectionView: UICollectionView!
    
    @IBOutlet weak var bestPartnersTableView: UITableView!
    
    @IBOutlet weak var btnNearby: UIButton!
    
    @IBOutlet weak var btnSales: UIButton!
    
    @IBOutlet weak var btnSeeAll: UIButton!
    
    @IBOutlet weak var btnRate: UIButton!
    
    @IBOutlet weak var btnFast: UIButton!
    
    @IBOutlet weak var lineViewNearby: UIView!
    
    @IBOutlet weak var lineViewSales: UIView!
    
    @IBOutlet weak var lineViewRate: UIView!
    
    @IBOutlet weak var lineViewFast: UIView!
    
    @IBOutlet weak var btnFilter: UIButton!
    
    //MARK: UIComponent
    
    lazy var searchBar = UISearchBar()
        .with(\.placeholder, setTo: "Search on Coody")
        .with(\.searchBarStyle, setTo: .minimal)
        .with(\.backgroundColor, setTo: .white)
        .with(\.frame.size.height, setTo: 44)
    
    lazy var flowlayoutCategory: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = .init(width: 120, height: 138)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        return flowLayout
    }()
    
    lazy var flowLayoutBestPartner: UICollectionViewFlowLayout = {
       let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = .init(width: 224, height: 238)
        flowlayout.scrollDirection = .horizontal
        flowlayout.minimumLineSpacing = -3
        flowlayout.minimumInteritemSpacing = 0
        return flowlayout
    }()
        
    
    //MARK: Variables
    var viewModel: HomeViewModel
    let filterInfoSubject = PublishSubject<FilterInfo>()
//    @IBOutlet weak var bestPartnersTableViewHeight: NSLayoutConstraint!
    
    //MARK: Initializers
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "HomeViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setSearchTextField()
        setupView()
        bindingData()
        
    }
    
    //MARK: Private func
    
    private func bindingData() {
        let parterSelected = Observable.merge(
            btnNearby.rx.tap.mapTo(Partner.nearby).asObservable(),
            btnSales.rx.tap.mapTo(Partner.sales).asObservable(),
            btnRate.rx.tap.mapTo(Partner.rate).asObservable(),
            btnFast.rx.tap.mapTo(Partner.fast).asObservable()
        ).startWith(Partner.nearby)
            
        let partnerSelectedDriver = parterSelected
            .bind(onNext: { parterSelected in
                switch parterSelected {
                case .nearby:
                    self.btnNearby.setTitleColor(UIColor(hexString: "EF9F27"), for: .normal)
                    self.lineViewNearby.backgroundColor = UIColor(hexString: "EF9F27")
                    
                    [self.lineViewFast, self.lineViewRate, self.lineViewSales].forEach { lineView in
                        lineView?.backgroundColor = .clear
                    }
                    
                    [self.btnFast, self.btnRate, self.btnSales].forEach { button in
                        button?.setTitleColor(UIColor(hexString: "172B4D"), for: .normal)
                    }
                case .sales:
                    self.btnSales.setTitleColor(UIColor(hexString: "EF9F27"), for: .normal)
                    self.lineViewSales.backgroundColor = UIColor(hexString: "EF9F27")
                    
                    [self.lineViewFast, self.lineViewRate, self.lineViewNearby].forEach { lineView in
                        lineView?.backgroundColor = .clear
                    }
                    
                    [self.btnFast, self.btnRate, self.btnNearby].forEach { button in
                        button?.setTitleColor(UIColor(hexString: "172B4D"), for: .normal)
                    }
                    
                case .rate:
                    self.btnRate.setTitleColor(UIColor(hexString: "EF9F27"), for: .normal)
                    self.lineViewRate.backgroundColor = UIColor(hexString: "EF9F27")
                    
                    [self.lineViewFast, self.lineViewNearby, self.lineViewSales].forEach { lineView in
                        lineView?.backgroundColor = .clear
                    }
                    
                    [self.btnFast, self.btnNearby, self.btnSales].forEach { button in
                        button?.setTitleColor(UIColor(hexString: "172B4D"), for: .normal)
                    }
                case .fast:
                    self.btnFast.setTitleColor(UIColor(hexString: "EF9F27"), for: .normal)
                    self.lineViewFast.backgroundColor = UIColor(hexString: "EF9F27")
                    
                    [self.lineViewNearby, self.lineViewRate, self.lineViewSales].forEach { lineView in
                        lineView?.backgroundColor = .clear
                    }
                    
                    [self.btnNearby, self.btnRate, self.btnSales].forEach { button in
                        button?.setTitleColor(UIColor(hexString: "172B4D"), for: .normal)
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        let input = HomeViewModel.Input(
            viewDidload: .just(()),
            parterSelected: parterSelected,
            filterInfo: filterInfoSubject.asObservable()
        )
        
        let output = viewModel.transfer(input: input)
        
        output.category
            .drive(categoryCollectionView.rx.items(cellIdentifier: "CategoryCollectionViewCell", cellType: CategoryCollectionViewCell.self)) { index, category, cell in
                cell.lblCategoryName.text = category.title ?? ""
                let urlImgString = category.image
                cell.imgFood.kf.setImage(with: URL(string: urlImgString ?? ""))
            }
            .disposed(by: rx.disposeBag)
        
        output.bestPartners
            .drive(bestPartnerCollectionView.rx.items(cellIdentifier: "BestPartnerCollectionViewCell", cellType: BestPartnerCollectionViewCell.self)) { index, bestPartners, cell in
                cell.bind(with: .init(bestPartner: bestPartners))
            }
            .disposed(by: rx.disposeBag)
        
        output.partners
            .drive(bestPartnersTableView.rx.items(cellIdentifier: "BestPartnersTableViewCell", cellType: BestPartnersTableViewCell.self)) { index, partner, cell in
                cell.bind(with: .init(partner: partner))
                
            }
            .disposed(by: rx.disposeBag)
        
        btnSeeAll.rx.tap
            .bind(onNext: {
                let viewModel = BestPartnerAllViewModel()
                self.presentPanModal(BestPartnersAllViewController(viewModel: viewModel))
            })
            .disposed(by: rx.disposeBag)
        
//        bestPartnersTableView.rx.observe(CGSize.self, "contentSize")
//            .compactMap { $0 }
//            .map(\.height)
//            .bind(onNext: { [weak self] height in
//                self?.bestPartnersTableViewHeight.constant = height
//            })
//            .disposed(by: rx.disposeBag)
        btnFilter.rx.tap
            .bind(onNext: {
                let viewmodel = FilterViewModel()
                let nextVC = FilterViewController(
                    viewModel: viewmodel,
                    completionHandler: { filterInfo in
                        self.filterInfoSubject.onNext(filterInfo)
                    },
                    filterInfoSubject: self.filterInfoSubject
                )
                
                let fpc = FloatingPanelController()
                
                // Assign self as the delegate of the controller.
                fpc.delegate = nextVC // Optional
                
                let appearance = SurfaceAppearance()
                appearance.cornerRadius = 30
                fpc.surfaceView.appearance = appearance
                
                fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
                
                // Set a content view controller.
                fpc.set(contentViewController: nextVC)
                
                
                
                // Add and show the views managed by the `FloatingPanelController` object to self.view.
                fpc.addPanel(toParent: self, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        searchBar.rx.textDidBeginEditing
            .bind(onNext: {
                self.searchBar.searchTextField.resignFirstResponder()
                
                let viewModel = SearchResultViewModel()
                let searchVc = SearchResultViewController(viewModel: viewModel)
                self.navigationController?.pushViewController(searchVc, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        bestPartnerCollectionView.rx.modelSelected(BestPartnersResponse.Partner.self)
            .bind(onNext: { item in
                let id = item.id
                self.goToDetailBrandVC(with: id)
            })
            .disposed(by: rx.disposeBag)
        
        bestPartnersTableView.rx.modelSelected(BestPartnersResponse.Partner.self)
            .bind(onNext: { item in
                let id = item.id
                self.goToDetailBrandVC(with: id)
            })
            .disposed(by: rx.disposeBag)
      
    }
    
    func goToDetailBrandVC(with brandId: String?) {
        let viewModel = DetailBrandViewModel(brandId: brandId)
        let detailVC = DetailBrandViewController(viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
        
//        let fpc = FloatingPanelController()
//
//        fpc.delegate = detailVC
//        
//        let appearance = SurfaceAppearance()
//        appearance.cornerRadius = 30
//        fpc.surfaceView.appearance = appearance
//        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
//        fpc.set(contentViewController: detailVC)
//
//        fpc.addPanel(toParent: self, animated: true)
    }
    
    private func setupSearchBar() {
        navigationItem.titleView = searchBar
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        filterView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 15)
    }
    
    private func setupView() {
        //MARK: categoryCollectionView
        let nibCell = UINib(nibName: "CategoryCollectionViewCell", bundle: nil)
        categoryCollectionView.register(nibCell, forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        categoryCollectionView.collectionViewLayout = flowlayoutCategory
        categoryCollectionView.showsHorizontalScrollIndicator = false
        
        //MARK: categoryCollectionView
        
        let nibCell2 = UINib(nibName: "BestPartnerCollectionViewCell", bundle: nil)
        bestPartnerCollectionView.register(nibCell2, forCellWithReuseIdentifier: "BestPartnerCollectionViewCell")
        bestPartnerCollectionView.collectionViewLayout = flowLayoutBestPartner
        bestPartnerCollectionView.showsHorizontalScrollIndicator = false
        
        //MARK: bestPartnersTableView Register
        let nibCell3 = UINib(nibName: "BestPartnersTableViewCell", bundle: nil)
        bestPartnersTableView.register(nibCell3, forCellReuseIdentifier: "BestPartnersTableViewCell")
        bestPartnersTableView.rowHeight = UITableView.automaticDimension
    }
    
    private func setSearchTextField() {
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
            let imageView = UIImageView(image: UIImage(named: "ic_location"))
            imageView.frame = CGRect(x: 0, y: 0, width: 36, height: 24)
            searchTextField.leftView = imageView
            searchTextField.leftViewMode = .always
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Search on Coody", attributes: [.foregroundColor: UIColor(hexString: "7A869A"), .font: UIFont.regular(size: 14)])
        }
    }
    
    
}

extension HomeViewController: UITableViewDelegate {
    
}
