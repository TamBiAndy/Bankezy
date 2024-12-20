//
//  PopularItemsCollectionViewCell.swift
//  Bankezy
//
//  Created by Andy on 17/12/2024.
//

import UIKit

class PopularItemsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dishImg: UIImageView!
    
    @IBOutlet weak var lblDish: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblCategory: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bind(with item: PopularItemResponse.PopularItem) {
        self.dishImg.kf.setImage(with: URL(string: item.image ?? ""))
        self.lblDish.text = item.title
        self.lblPrice.text = "$ \(item.price ?? 0)"
        self.lblCategory.text = item.dish
    }

}
