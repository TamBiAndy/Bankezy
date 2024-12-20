//
//  MenuTableViewCell.swift
//  Bankezy
//
//  Created by Andy on 13/12/2024.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var imgDish: UIImageView!
    
    @IBOutlet weak var lblTitleDish: UILabel!
    
    @IBOutlet weak var imgStar: UIImageView!
    
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblCategory: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    func bind(item: MenuResponse.Menu.Item) {
        self.imgDish.kf.setImage(with: URL(string: item.image ?? ""))
        self.lblTitleDish.text = item.title
        self.lblPrice.text = "$ \(item.price ?? 0)"
        self.lblCategory.text = item.type
    }
}
