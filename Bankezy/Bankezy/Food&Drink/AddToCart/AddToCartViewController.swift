//
//  AddToCartViewController.swift
//  Bankezy
//
//  Created by Andy on 20/12/2024.
//

import UIKit
import RxSwift
import RxCocoa

class AddToCartViewController: UIViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var dishImageCollectionView: UICollectionView!
    
    @IBOutlet weak var btnIncrease: UIButton!
    
    @IBOutlet weak var btnSubtract: UIButton!
    
    @IBOutlet weak var lblQty: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var btnAddtoOrder: UIButton!
    
    @IBOutlet weak var sizeHstack: UIStackView!
    
    
    //MARK: Variables
    var quantityLabel = BehaviorRelay<Int?>(value: 1)
    var selectedSize = BehaviorRelay<UIButton?>(value: nil)
    lazy var flowLayout = ZoomFlowLayout()
    var viewModel: AddToCartViewModel
    
    init(viewModel: AddToCartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "AddToCartViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindData()
    }
    
    func bindData() {
        let sizeObv = selectedSize.asObservable()
            .compactMap { $0 }
            .map { $0.currentTitle ?? "S" }
        
        let qtyObv = quantityLabel.asObservable()
            .map { "\($0 ?? 1)"}
        
        let input = AddToCartViewModel.Input(
            viewDidLoad: .just(()),
            size: sizeObv,
            qty: qtyObv,
            addToCartButtonTapped: btnAddtoOrder.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.dishInfor
            .compactMap(\.image)
            .drive(dishImageCollectionView.rx.items(cellIdentifier: "dishImageCollectionViewCell", cellType: dishImageCollectionViewCell.self)) { index, item, cell in
                cell.dishImage.kf.setImage(with: URL(string: item))
            }
            .disposed(by: rx.disposeBag)
        
        output.dishInfor
            .compactMap(\.size)
            .drive(onNext: { sizes in
                self.addSizeLabel(sizeString: sizes)
            })
            .disposed(by: rx.disposeBag)
        
        output.dishInfor
            .compactMap(\.title)
            .drive(lblTitle.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.dishInfor
            .compactMap(\.description)
            .drive(lblDescription.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.dishInfor
            .compactMap(\.price)
            .map { "\($0)" }
            .drive(lblPrice.rx.text)
            .disposed(by: rx.disposeBag)
        
        selectedSize
            .bind(onNext: { newButton in
                
                self.sizeHstack.arrangedSubviews.forEach { view in
                    if let button = view as? UIButton, button != newButton {
//                        button.isSelected = false
                        button.backgroundColor = .white
                    }
                }
                
                if let button = newButton {
                    button.isSelected.toggle()
                    if button.isSelected {
                        button.backgroundColor = UIColor(hexString: "FFC400")
                    } else {
                        button.backgroundColor = .white
                    }
                }
            })
            .disposed(by: rx.disposeBag)
        
        btnIncrease.rx.tap
            .bind(onNext: { _ in
                self.quantityLabel.accept((self.quantityLabel.value ?? 0) + 1)
            })
            .disposed(by: rx.disposeBag)
        
        btnSubtract.rx.tap
            .bind(onNext: { _ in
                if let currentValue = self.quantityLabel.value, currentValue > 0 {
                    self.quantityLabel.accept((self.quantityLabel.value ?? 0) - 1)
                }
            })
            .disposed(by: rx.disposeBag)
        
        quantityLabel
            .map { "\($0 ?? 0)"}
            .bind(to: lblQty.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.addToCart
            .drive(onNext: { isSuccess in
                self.dismiss(animated: true)
                
            })
            .disposed(by: rx.disposeBag)
        
        output.error
            .drive(onNext: {error in
                print(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    private func setupView() {
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = -50
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(
            width: dishImageCollectionView!.frame.width,
            height: dishImageCollectionView!.frame.height
        )
        dishImageCollectionView.collectionViewLayout = flowLayout
        dishImageCollectionView.isPagingEnabled = true
        dishImageCollectionView.showsHorizontalScrollIndicator = false
        
        let nibcellImage = UINib(nibName: "dishImageCollectionViewCell", bundle: nil)
        dishImageCollectionView.register(nibcellImage, forCellWithReuseIdentifier: "dishImageCollectionViewCell")
    }
    
    private func addSizeLabel(sizeString: [String]) {
        sizeString.forEach { size in
            let btnSize = UIButton(type: .custom)
            btnSize.setTitle(size, for: .normal)
            btnSize.setTitleColor(UIColor(hexString: "172B4D"), for: .normal)
            btnSize.titleLabel?.font = .medium(size: 16)
            btnSize.layer.cornerRadius = 14
            btnSize.applyShadowForButton(color: UIColor(hexString: "1F1B11"), alpha: 0.13, width: 0, height: 7, radius: 30)
            
            btnSize.snp.makeConstraints { make in
                make.width.height.equalTo(40)
            }
            
            btnSize.rx.tap
                .map { btnSize }
                .bind(to: selectedSize)
                .disposed(by: rx.disposeBag)
            
            self.sizeHstack.addArrangedSubview(btnSize)
        }
    }
    
}

class ZoomFlowLayout: UICollectionViewFlowLayout {
    let scaleFactor: CGFloat = 0.23
    let alphaFactor: CGFloat = 0.5
    
    override func prepare(forCollectionViewUpdates updates: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updates)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            guard let attributesArray = super.layoutAttributesForElements(in: rect),
                  let collectionView = collectionView else {
                return nil
            }

            let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)

            for attributes in attributesArray {
                if attributes.frame.intersects(visibleRect) {
                    let distance = abs(visibleRect.midX - attributes.center.x)
                    let normalizedDistance = distance / collectionView.bounds.width
                    let zoom = 1 - (scaleFactor * normalizedDistance)
                    let alpha = 1 - (alphaFactor * normalizedDistance)

                    attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
                    attributes.alpha = alpha
                    attributes.zIndex = Int(zoom * 10)
                }
            }
            return attributesArray
        }
}
