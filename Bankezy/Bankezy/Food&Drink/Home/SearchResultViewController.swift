//
//  SearchResultViewController.swift
//  Bankezy
//
//  Created by Andy on 11/12/2024.
//

import UIKit
import RxSwift
import RxCocoa

class SearchResultViewController: UIViewController {
    
    
    @IBOutlet weak var searchResultTableview: UITableView!
    
    lazy var searchBar = UISearchBar()
        .with(\.placeholder, setTo: "Search on Coody")
        .with(\.searchBarStyle, setTo: .minimal)
        .with(\.backgroundColor, setTo: .white)
        .with(\.frame.size.height, setTo: 44)
    
    var viewModel: SearchResultViewModel
  
    
    init(viewModel: SearchResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "SearchResultViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindingData()
    }
    
    func setupView() {
        navigationItem.titleView = searchBar
        
        let nibcell = UINib(nibName: "SearchTableViewCell", bundle: nil)
        searchResultTableview.register(nibcell, forCellReuseIdentifier: "SearchTableViewCell")
        
        searchBar.rx.textDidBeginEditing
            .bind(onNext: {
                self.searchBar.becomeFirstResponder()
                self.searchBar.showsCancelButton = true
            })
            .disposed(by: rx.disposeBag)
        
        searchBar.rx.textDidEndEditing
            .bind(onNext: {
                self.searchBar.resignFirstResponder()
                self.searchBar.showsCancelButton = false
            })
            .disposed(by: rx.disposeBag)
        
        searchBar.rx.cancelButtonClicked
            .bind(onNext: {
                self.searchBar.resignFirstResponder()
            })
            .disposed(by: rx.disposeBag)
        
        
    }
    
    func bindingData() {
        let input = SearchResultViewModel.Input(searchText: searchBar.rx.text.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.items
            .drive(searchResultTableview.rx.items(cellIdentifier: "SearchTableViewCell", cellType: SearchTableViewCell.self)) { index, items, cell in
                cell.bind(with: items)
            }
            .disposed(by: rx.disposeBag)
    }


}
