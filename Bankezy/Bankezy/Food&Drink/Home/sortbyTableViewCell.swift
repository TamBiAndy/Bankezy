//
//  sortbyTableViewCell.swift
//  Bankezy
//
//  Created by Andy on 09/12/2024.
//

import UIKit

class sortbyTableViewCell: UITableViewCell {

    @IBOutlet weak var leftIcon: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var righticon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(with model: SortbyFilter) {
        self.leftIcon.image = model.leftIcon
        self.lblTitle.text = model.title
        self.righticon.image = model.rightIcon
    }
    
}
