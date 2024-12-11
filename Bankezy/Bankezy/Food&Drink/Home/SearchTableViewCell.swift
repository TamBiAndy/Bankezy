//
//  SearchTableViewCell.swift
//  Bankezy
//
//  Created by Andy on 09/12/2024.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgBrand: UIImageView!
    
    @IBOutlet weak var lblTitleBrand: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblDish: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func bind(with item: SearchPartnerResponse.Partner) {
        self.imgBrand.kf.setImage(with: URL(string: item.image ?? ""))
        self.lblTitleBrand.text = item.titleBrand
        self.lblPrice.text = "\(item.price ?? 0) USD"
        self.lblDish.text = item.dish
    }
}
