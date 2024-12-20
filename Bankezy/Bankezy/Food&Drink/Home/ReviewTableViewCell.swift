//
//  ReviewTableViewCell.swift
//  Bankezy
//
//  Created by Andy on 16/12/2024.
//

import UIKit
import Cosmos
import RxSwift
import RxCocoa

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var userAvatar: UIImageView!
    
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var lblCreatTime: UILabel!
    
    @IBOutlet weak var lblComment: UILabel!
    
    @IBOutlet weak var lblLikeQty: UILabel!
    
    @IBOutlet weak var imageReviewCollectionView: UICollectionView!
    
    @IBOutlet weak var ratingView: UIView!
    
    lazy var rating = CosmosView()
        .with(\.settings.updateOnTouch, setTo: false)
        .with(\.settings.totalStars, setTo: 5)
        .with(\.settings.fillMode, setTo: .full)
        .with(\.settings.starSize, setTo: 9)
        .with(\.settings.starMargin, setTo: 4)
        .with(\.settings.filledImage, setTo: UIImage(named: "fullStar"))
        .with(\.settings.emptyImage, setTo: UIImage(named: "emptyStar"))
    
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
    let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = .init(width: 56, height: 64)
        flowLayout.minimumLineSpacing = 8
        flowLayout.minimumInteritemSpacing = 0
        return flowLayout
    }()
    
    var imageReviewRelay = BehaviorRelay<[String]>(value: [])

    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        bindData()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupView() {
        ratingView.addSubview(rating)
        rating.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imageReviewCollectionView.collectionViewLayout = flowLayout
        imageReviewCollectionView.isScrollEnabled = false
        imageReviewCollectionView.register(
            UINib(nibName: "ImageReviewCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ImageReviewCollectionViewCell")
    }
    
    func bindData() {
        imageReviewRelay
            .bind(to: imageReviewCollectionView.rx.items(cellIdentifier: "ImageReviewCollectionViewCell", cellType: ImageReviewCollectionViewCell.self)) { index, item, cell in
                cell.bind(with: item)
            }
            .disposed(by: rx.disposeBag)
    }
    
    func bind(item: ReviewBrandResponse.Review) {
        self.userAvatar.kf.setImage(with: URL(string: item.avatarURL ?? ""))
        self.lblUserName.text = item.userName
        self.lblCreatTime.text = item.createdAt
        self.lblComment.text = item.comment
        self.rating.rating = Double(item.rating ?? 0)
        if item.likes == 0 {
            lblLikeQty.isHidden = true
        } else {
            self.lblLikeQty.isHidden = false
            self.lblLikeQty.text = "\(item.likes ?? 0) likes"
        }
        if let images = item.reviewImage, !images.isEmpty {
            imageReviewCollectionView.isHidden = false
            imageReviewRelay.accept(images)
        } else {
            imageReviewCollectionView.isHidden = true
        }
    }

}
