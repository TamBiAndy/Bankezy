//
//  HistoryOrderViewController.swift
//  Bankezy
//
//  Created by Andy on 14/01/2025.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class HistoryOrderViewController: UIViewController {
    
    @IBOutlet weak var btnOngoing: UIButton!
    
    @IBOutlet weak var btnHistory: UIButton!
    
    @IBOutlet weak var lineViewOnGoing: UIView!
    
    @IBOutlet weak var lineViewhistory: UIView!
    
    @IBOutlet weak var historyTableView: UITableView!
    
    
    lazy var searchBar = UISearchBar()
        .with(\.placeholder, setTo: "Search on Coody")
        .with(\.searchBarStyle, setTo: .minimal)
        .with(\.backgroundColor, setTo: .white)
        .with(\.frame.size.height, setTo: 44)
    
    var isHidden: Bool = false
    var viewModel: HistoryOrderViewModel
    
    init(viewModel: HistoryOrderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "HistoryOrderViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        bindingData()
    }
    
    private func bindingData() {
        let nibcell = UINib(nibName: "HistoryOrderTableViewCell", bundle: nil)
        historyTableView.register(nibcell, forCellReuseIdentifier: "HistoryOrderTableViewCell")
        historyTableView.rowHeight = UITableView.automaticDimension
        historyTableView.separatorStyle = .none
        
        let segmentSelected = Observable.merge(
            btnHistory.rx.tap.mapTo(YourOrderHistory.history).asObservable(),
            btnOngoing.rx.tap.mapTo(YourOrderHistory.onGoing).asObservable()
        ).startWith(YourOrderHistory.history)
        
        segmentSelected
            .bind(onNext: { segmentSelected in
                switch segmentSelected {
                case .history:
                    self.btnHistory.setTitleColor(UIColor(hexString: "EF9F27"), for: .normal)
                    self.lineViewhistory.backgroundColor = UIColor(hexString: "EF9F27")
                    self.btnOngoing.setTitleColor(UIColor(hexString: "172B4D"), for: .normal)
                    self.lineViewOnGoing.backgroundColor = .clear
                    self.isHidden = false
                case .onGoing:
                    self.btnOngoing.setTitleColor(UIColor(hexString: "EF9F27"), for: .normal)
                    self.lineViewOnGoing.backgroundColor = UIColor(hexString: "EF9F27")
                    self.btnHistory.setTitleColor(UIColor(hexString: "172B4D"), for: .normal)
                    self.lineViewhistory.backgroundColor = .clear
                    self.isHidden = true
                }
            })
            .disposed(by: rx.disposeBag)
        
        let input = HistoryOrderViewModel.Input(
            viewDidload: .just(()),
            segmentSelected: segmentSelected)
        
        let output = viewModel.transform(input: input)
        
        output.yourOrder
            .drive(historyTableView.rx.items(cellIdentifier: "HistoryOrderTableViewCell", cellType: HistoryOrderTableViewCell.self)) { index, item, cell in
                cell.bind(with: item, isHidden: self.isHidden)
            }
            .disposed(by: rx.disposeBag)
        
    }
    
    private func setupSearchBar() {
        navigationItem.titleView = searchBar
    }



}
