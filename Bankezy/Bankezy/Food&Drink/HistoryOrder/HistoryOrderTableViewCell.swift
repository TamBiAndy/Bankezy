//
//  HistoryOrderTableViewCell.swift
//  Bankezy
//
//  Created by Andy on 14/01/2025.
//

import UIKit
import RxSwift
import RxCocoa
import FloatingPanel

class HistoryOrderTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var lblType: UILabel!
    
    @IBOutlet weak var lblStatusOrder: UILabel!
    
    @IBOutlet weak var lblTimeOrder: UILabel!
    
    @IBOutlet weak var brandIcon: UIImageView!
    
    @IBOutlet weak var lblBrandName: UILabel!
    
    @IBOutlet weak var lblBrandAddress: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblItemsCount: UILabel!
    
    @IBOutlet weak var btnRate: UIButton!
    
    @IBOutlet weak var btnReOrder: UIButton!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    
    func bind(with item: HistoryOrderResponse.Data, isHidden: Bool) {
        self.lblType.text = item.type
        self.lblStatusOrder.text = item.status
        self.lblTimeOrder.text = formatDateString(item.orderDate ?? "")
        let urlString = item.image ?? ""
        self.brandIcon.kf.setImage(with: URL(string: urlString))
        self.lblBrandName.text = item.brandName
        self.lblBrandAddress.text = item.brandAddress
        self.lblPrice.text = "$\(item.totalPrice ?? 0)"
        self.lblItemsCount.text = "\(item.itemsQty ?? 0) items"
        btnRate.isHidden = isHidden
        btnReOrder.isHidden = isHidden
        
        btnRate.rx.tap
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
                fpc.delegate = nextVC
                
                let appearance = SurfaceAppearance()
                appearance.cornerRadius = 30
                fpc.surfaceView.appearance = appearance
                fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true

                fpc.set(contentViewController: nextVC)
                fpc.addPanel(toParent: self, animated: true)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func formatDateString(_ dateString: String) -> String? {

        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        inputDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "EEEE, dd MMMM yyyy"
        outputDateFormatter.locale = Locale(identifier: "en_US") // Thay đổi locale nếu cần
        
        if let date = inputDateFormatter.date(from: dateString) {
            return outputDateFormatter.string(from: date)
        } else {
            return nil
        }
    }
}
