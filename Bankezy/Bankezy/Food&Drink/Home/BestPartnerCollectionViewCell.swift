//
//  BestPartnerCollectionViewCell.swift
//  Bankezy
//
//  Created by Andy on 04/12/2024.
//

import UIKit

class BestPartnerCollectionViewCell: UICollectionViewCell {
    
    struct ViewState {
        let imageUrl: String?
        let title: String?
        let openStatus: String?
        let location: String?
        let rating: Double?
        let distance: Double?
        let shippingFee: String?
    }

    @IBOutlet weak var imgBrand: UIImageView!
    
    @IBOutlet weak var lblPartnerName: UILabel!
    
    @IBOutlet weak var lblOpenStatus: UILabel!
    
    @IBOutlet weak var lblLocation: UILabel!
    
    @IBOutlet weak var lblRating: UILabel!
    
    @IBOutlet weak var lblDistance: UILabel!
    
    @IBOutlet weak var lblShippingFee: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(with viewState: ViewState) {
        imgBrand.kf.setImage(with: URL(string: viewState.imageUrl ?? ""))
        lblPartnerName.text = viewState.title
        lblOpenStatus.text = viewState.openStatus
        lblLocation.text = viewState.location
        lblRating.text = "\(viewState.rating ?? 0)"
        lblDistance.text = "\(viewState.distance ?? 0) km"
        lblShippingFee.text = viewState.shippingFee
    }

}

extension BestPartnerCollectionViewCell.ViewState {
    init(bestPartner: BestPartnersResponse.Partner) {
        self.imageUrl = bestPartner.image
        self.title = bestPartner.titleBrand
        self.openStatus = bestPartner.openStatus
        self.location = bestPartner.location
        self.rating = bestPartner.rating
        self.distance = bestPartner.distance
        self.shippingFee = bestPartner.shippingFee
    }
}

