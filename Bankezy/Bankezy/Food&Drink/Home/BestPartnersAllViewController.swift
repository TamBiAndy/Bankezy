//
//  BestPartnersAllViewController.swift
//  Bankezy
//
//  Created by Andy on 05/12/2024.
//

import UIKit
import PanModal

class BestPartnersAllViewController: UIViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var seeAllTableView: UITableView!
    
    //MARK: Variables
    var viewModel = BestPartnerAllViewModel()
    
    //Initializers
    init(viewModel: BestPartnerAllViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "BestPartnersAllViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindingData()
    }
    
    //MARK: Private func
    private func bindingData() {
        let input = BestPartnerAllViewModel.Input(viewDidload: .just(()))
        
        let output = viewModel.transform(input: input)
        
        output.allPartner
            .drive(seeAllTableView.rx.items(cellIdentifier: "BestPartnersTableViewCell", cellType: BestPartnersTableViewCell.self)) { index, seeAll, cell in
                cell.bind(with: .init(seeAll: seeAll))
            }
            .disposed(by: rx.disposeBag)
    }
    
    private func setupTableView() {
        let nibCell = UINib(nibName: "BestPartnersTableViewCell", bundle: nil)
        seeAllTableView.register(nibCell, forCellReuseIdentifier: "BestPartnersTableViewCell")
        seeAllTableView.showsHorizontalScrollIndicator = false
        seeAllTableView.rowHeight = UITableView.automaticDimension
        seeAllTableView.estimatedRowHeight = 294
    }

}

extension BestPartnersAllViewController: PanModalPresentable {
    //MARK: setup PanModal
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeight
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var cornerRadius: CGFloat {
        return 30
    }
    
    var anchorModalToLongForm: Bool {
        return false
    }
}
