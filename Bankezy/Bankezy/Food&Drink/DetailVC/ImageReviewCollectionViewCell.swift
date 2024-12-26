//
//  ImageReviewCollectionViewCell.swift
//  Bankezy
//
//  Created by Andy on 16/12/2024.
//

import UIKit
import Kingfisher

class ImageReviewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageReview: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func bind(with item: String?) {
        self.imageReview.kf.setImage(with: URL(string: item ?? ""))
    }
}
