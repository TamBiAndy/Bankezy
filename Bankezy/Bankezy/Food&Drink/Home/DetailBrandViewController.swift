//
//  DetailBrandViewController.swift
//  Bankezy
//
//  Created by Andy on 11/12/2024.
//

import UIKit
import RxSwift
import RxCocoa
import FloatingPanel
import RxDataSources

enum DetailOption {
    case delivery
    case review
}

class DetailBrandViewController: UIViewController {
    
    typealias Section = DetailBrandViewModel.SectionDataSource
    
    //MARK: IBOutlet
    @IBOutlet weak var lblTitleBrand: UILabel!
    
    @IBOutlet weak var lblServiceOption: UILabel!
    
    @IBOutlet weak var lblOpenstatus: UILabel!
    
    @IBOutlet weak var lblLocation: UILabel!
    
    @IBOutlet weak var lblRating: UILabel!
    
    @IBOutlet weak var lblShippingTime: UILabel!
    
    @IBOutlet weak var lblShippingFee: UILabel!
    
    @IBOutlet weak var lblDiscount: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnDelivery: UIButton!
    
    @IBOutlet weak var btnReview: UIButton!
    
    @IBOutlet weak var lineViewDelivery: UIView!
    
    @IBOutlet weak var lineViewReview: UIView!
    
    lazy var dataSource = RxTableViewSectionedReloadDataSource<Section>(configureCell: { _, tableView, indexPath, item in
        switch item {
        case .popular(let items):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PopularItemsTableViewCell", for: indexPath) as? PopularItemsTableViewCell else { return .init() }
            cell.bind(with: items)
            
            return cell
        case .dish(let item):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as? MenuTableViewCell else { return .init() }
            cell.bind(item: item)
            return cell
        case .review(let item):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell", for: indexPath) as? ReviewTableViewCell else { return .init() }
            cell.bind(item: item)
            return cell
        }
    }, titleForHeaderInSection: { dataSource, index in
        let section = dataSource[index]
        
        return section.model.title
//    }, viewForFooterInSection: { dataSource, index in
//        let section = dataSource[index]
//        return section.model.viewForFooterInSection
    })
     
    //MARK: Variables
    var viewModel: DetailBrandViewModel
    
    //MARK: Initializers
    
    init(viewModel: DetailBrandViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "DetailBrandViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindingData()
    }
    
    //MARK: Private func
    
    private func bindingData() {
        
        let segmentObv = Observable.merge(
            btnDelivery.rx.tap.mapTo(DetailOption.delivery).asObservable(),
            btnReview.rx.tap.mapTo(DetailOption.review).asObservable()
        ).startWith(DetailOption.delivery)
        
        segmentObv
            .bind(onNext: { segmentSelected in
                switch segmentSelected {
                case .delivery:
                    self.btnDelivery.setTitleColor(UIColor(hexString: "EF9F27"), for: .normal)
                    self.lineViewDelivery.backgroundColor = UIColor(hexString: "EF9F27")
                    
                    self.btnReview.setTitleColor(UIColor(hexString: "172B4D"), for: .normal)
                    self.lineViewReview.backgroundColor = .clear
                case .review:
                    self.btnReview.setTitleColor(UIColor(hexString: "EF9F27"), for: .normal)
                    self.lineViewReview.backgroundColor = UIColor(hexString: "EF9F27")
                    
                    self.btnDelivery.setTitleColor(UIColor(hexString: "172B4D"), for: .normal)
                    self.lineViewDelivery.backgroundColor = .clear
                }
            })
            .disposed(by: rx.disposeBag)
        
        let input = DetailBrandViewModel.Input(
            viewDidload: .just(()),
            optionSelected: segmentObv)
        
        let output = viewModel.transform(input: input)
        
        output.brandDetail
            .drive(onNext: { detailBrand in
                self.bindDetailBrand(with: detailBrand)
            })
            .disposed(by: rx.disposeBag)
        
        output.sections
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
//        tableView.rx.contentSize
//            .bind(onNext: {)
    }
    
    private func setupView() {
        let nibCellMenu = UINib(nibName: "MenuTableViewCell", bundle: nil)
        tableView.register(nibCellMenu, forCellReuseIdentifier: "MenuTableViewCell")
        
        let popularCell = UINib(nibName: "PopularItemsTableViewCell", bundle: nil)
        tableView.register(popularCell, forCellReuseIdentifier: "PopularItemsTableViewCell")
        
        let reviewCell = UINib(nibName: "ReviewTableViewCell", bundle: nil)
        tableView.register(reviewCell, forCellReuseIdentifier: "ReviewTableViewCell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    func bindDetailBrand(with modal: BrandDetailResponse) {
        self.lblTitleBrand.text = modal.titleBrand
        self.lblServiceOption.text = modal.service
        self.lblOpenstatus.text = modal.openStatus
        self.lblLocation.text = modal.location
        self.lblRating.text = "\(modal.rating ?? 0)"
        self.lblShippingTime.text = modal.shippingTime
        self.lblShippingFee.text = modal.shippingFee
        self.lblDiscount.text = modal.discount
    }
    

}

//extension DetailBrandViewController: FloatingPanelControllerDelegate {
//    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
//        return BottomPositionedPanelLayout()
//    }
//}
//
//class BottomPositionedPanelLayout: FloatingPanelLayout {
//    let position: FloatingPanelPosition = .bottom
//    let initialState: FloatingPanelState = .full
//    let anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] = [
//        .full: FloatingPanelLayoutAnchor(absoluteInset: 432, edge: .top, referenceGuide: .safeArea)
//    ]
//}

