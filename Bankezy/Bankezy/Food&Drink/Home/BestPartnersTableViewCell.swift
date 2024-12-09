//
//  BestPartnersTableViewCell.swift
//  Bankezy
//
//  Created by Andy on 04/12/2024.
//

import UIKit

extension BestPartnersTableViewCell.ViewState {
//    init(nearby: BestPartnersResponse.Partner) {
//        self.imageUrl = nearby.image
//        self.title = nearby.titleBrand
//        self.openStatus = nearby.openStatus
//        self.menu = nearby.category
//        self.rating = nearby.rating
//        self.distance = nearby.distance
//        self.shippingFee = nearby.shippingFee
//    }
//    
    init(partner: BestPartnersResponse.Partner) {
        self.imageUrl = partner.image
        self.title = partner.titleBrand
        self.openStatus = partner.openStatus
        self.menu = partner.category
        self.rating = partner.rating
        self.distance = partner.distance
        self.shippingFee = partner.shippingFee
    }
    
    init(seeAll: BestPartnersResponse.Partner) {
        self.imageUrl = seeAll.image
        self.title = seeAll.titleBrand
        self.openStatus = seeAll.openStatus
        self.menu = seeAll.category
        self.rating = seeAll.rating
        self.distance = seeAll.distance
        self.shippingFee = seeAll.shippingFee
    }
}

class BestPartnersTableViewCell: UITableViewCell {
    
    struct ViewState {
        let imageUrl: String?
        let title: String?
        let openStatus: String?
        let menu: [String]?
        let rating: Double?
        let distance: Double?
        let shippingFee: String?
    }
    
    //MARK: IBOutlet
    @IBOutlet weak var imgPartner: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblOpenStatus: UILabel!
    
    @IBOutlet weak var lblCategory1: UILabel!
    
    @IBOutlet weak var lblCategory2: UILabel!
    
    @IBOutlet weak var lblCategory3: UILabel!
    
    @IBOutlet weak var lblRating: UILabel!
    
    @IBOutlet weak var lblDistance: UILabel!
    
    @IBOutlet weak var lblShippingFee: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func bind(with viewState: ViewState) {
        imgPartner.kf.setImage(with: URL(string: viewState.imageUrl ?? ""))
        lblTitle.text = viewState.title
        lblOpenStatus.text = viewState.openStatus
        let menu = viewState.menu ?? []
        lblCategory1.text = menu[0]
        lblCategory2.text = menu[1]
        lblCategory3.text = menu[2]
        lblRating.text = "\(viewState.rating ?? 0)"
        lblDistance.text = "\(viewState.distance ?? 0)"
        lblShippingFee.text = viewState.shippingFee
    }
    
}
