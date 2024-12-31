//
//  ConfirmOrderViewController.swift
//  Bankezy
//
//  Created by Andy on 26/12/2024.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import FloatingPanel

class ConfirmOrderViewController: UIViewController {
    
    //MARK: IBOutlet
    
    @IBOutlet weak var lblPhoneNumber: UILabel!
    
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var lblDistance: UILabel!
    
    @IBOutlet weak var lblBrand: UILabel!
    
    @IBOutlet weak var lblSubTotal: UILabel!
    
    @IBOutlet weak var lblSubtotalPrice: UILabel!
    
    @IBOutlet weak var lblDeliveryCost: UILabel!
    
    @IBOutlet weak var lblVoucherCost: UILabel!
    
    @IBOutlet weak var lblTotalCost: UILabel!
    
    @IBOutlet weak var lblVoucherInfor: UILabel!
    
    @IBOutlet weak var lblPaypalPrice: UILabel!
    
    @IBOutlet weak var lblCashPrice: UILabel!
    
    @IBOutlet weak var itemsVstack: UIStackView!
    
    @IBOutlet weak var paypalView: UIView!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
    
    //MARK: Variables
    var viewModel: ConfirmOrderViewModel
    
    //MARK: Initializers
    init(viewModel: ConfirmOrderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "ConfirmOrderViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavi()
        bindData()
    }
    
    //MARK: Private func
    
    func bindData() {
        let input = ConfirmOrderViewModel.Input(viewDidload: .just(()))
        let output = viewModel.transform(input: input)
        
        output.orderInfor
            .compactMap(\.deliveryTo)
            .compactMap(\.phoneNumber)
            .drive(lblPhoneNumber.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.orderInfor
            .compactMap(\.deliveryTo)
            .compactMap(\.address)
            .drive(lblAddress.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.orderInfor
            .compactMap(\.deliveryTo)
            .compactMap(\.distance)
            .map { "\($0)" }
            .drive(lblDistance.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.orderInfor
            .compactMap(\.brand)
            .compactMap(\.brandName)
            .drive(lblBrand.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.orderInfor
            .compactMap(\.items)
            .drive(onNext: { items in
                items.forEach { item in
                    self.setupItemView(item: item)
                }
            })
            .disposed(by: rx.disposeBag)
        
        output.orderInfor
            .compactMap(\.items?.count)
            .map { "Subtotal (\($0) items)"}
            .drive(lblSubTotal.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.orderInfor
            .compactMap(\.totalAmount)
            .map { "$\($0)"}
            .drive(lblSubtotalPrice.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.orderInfor
            .compactMap(\.shippingFee)
            .map { "$\($0)"}
            .drive(lblDeliveryCost.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.orderInfor
            .compactMap(\.discount)
            .map { "$\($0)"}
            .drive(lblVoucherCost.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.orderInfor
            .compactMap(\.finalAmount)
            .map { "$\($0)"}
            .drive(lblTotalCost.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.orderInfor
            .compactMap(\.finalAmount)
            .map { "$\($0)"}
            .drive(lblPaypalPrice.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.orderInfor
            .compactMap(\.finalAmount)
            .map { "$\($0)"}
            .drive(lblCashPrice.rx.text)
            .disposed(by: rx.disposeBag)
        
        paypalView.rx.tapGesture()
            .when(.recognized)
            .bind(onNext: { _ in
                let viewModel = AddPaymentMethodViewModel()
                let bottomVc = AddPaymentMethodViewController(viewModel: viewModel)
                
                let fpc = FloatingPanelController()
                fpc.delegate = bottomVc
                
                let appearance = SurfaceAppearance()
                appearance.cornerRadius = 30
                fpc.surfaceView.appearance = appearance
                fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true

                fpc.set(contentViewController: bottomVc)
                fpc.addPanel(toParent: self, animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        btnSubmit.rx.tap
            .bind(onNext: {
                let iconImg = ResultStatus.IconInfor(
                    image: UIImage(named: "check-circle-fill"),
                    width: 40,
                    height: 40)
                let title = ResultStatus.Label(
                    title: "You ordered successfully",
                    font: .medium(size: 16),
                    color: UIColor(hexString: "172B4D"))
                
                let descript = ResultStatus.Label(
                    title: "You successfully place an order, your order is confirmed and delivered within 20 minutes. Wish you enjoy the food",
                    font: .medium(size: 12),
                    color: UIColor(hexString: "7A869A"))
                
                let button = ResultStatus.ButtonInfo(
                    title: "KEEP BROWSING",
                    titleColor: UIColor(hexString: "EF9F27"),
                    backgroundColor: .clear,
                    titleFont: .bold(size: 14),
                    action: {
                        print("KEEP BROWSING TAPPED")
                        self.dismiss(animated: true)
                    })
                
                let resultStatus = ResultStatus(
                    iconImg: iconImg,
                    title: title,
                    desciption: descript,
                    buttons: [button])
                
                self.showResultStatus(resultStatus)
            })
            .disposed(by: rx.disposeBag)
        
    }
    
    private func setupItemView(item: OrderInforResponse.Item) {
        let itemView = UIView(frame: .zero)
        let contentHstack = UIStackView(frame: .zero)
            .with(\.axis, setTo: .horizontal)
            .with(\.spacing, setTo: 17)
        
        let lineView = UIView(frame: .zero)
            .with(\.backgroundColor, setTo: UIColor(hexString: "F4F5F7"))
        
        let dishImage = UIImageView(frame: .zero)
            .with(\.contentMode, setTo: .scaleToFill)
            .with(\.layer.cornerRadius, setTo: 15)
            .with(\.clipsToBounds, setTo: true)
        
        let rightVstack = UIStackView(frame: .zero)
            .with(\.axis, setTo: .vertical)
            .with(\.spacing, setTo: 8)
        
        let lblDishName = UILabel(frame: .zero)
            .with(\.text, setTo: item.productName)
            .with(\.textColor, setTo: UIColor(hexString: "172B4D"))
            .with(\.font, setTo: .medium(size: 16))
        
        let qtyNpriceHstack = UIStackView(frame: .zero)
            .with(\.axis, setTo: .horizontal)
            .with(\.spacing, setTo: 16)
        
        let qtyView = UIView(frame: .zero)
            .with(\.backgroundColor, setTo: UIColor(hexString: "F4F5F7"))
            .with(\.layer.cornerRadius, setTo: 10)
        
        let lblPrice = UILabel(frame: .zero)
            .with(\.text, setTo: "$\(item.price ?? 0)")
            .with(\.textColor, setTo: UIColor(hexString: "EF9F27"))
            .with(\.font, setTo: .medium(size: 12))
        
        let qtyHstack = UIStackView(frame: .zero)
            .with(\.axis, setTo: .horizontal)
            .with(\.spacing, setTo: 8)
        
        let btnDown = UIButton(type: .custom)
        btnDown.setImage(UIImage(named: "ic_subtract"), for: .normal)
        btnDown.layer.cornerRadius = 8
        btnDown.backgroundColor = UIColor(hexString: "C1C7D0")
        btnDown.tintColor = .white
        
        let btnPlus = UIButton(type: .custom)
        btnPlus.setImage(UIImage(named: "ic_plus"), for: .normal)
        btnPlus.layer.cornerRadius = 8
        btnPlus.backgroundColor = UIColor(hexString: "EF9F27")
        btnPlus.tintColor = .white
        
        let lblQty = UILabel(frame: .zero)
            .with(\.text, setTo: "\(item.quantity ?? 0)")
            .with(\.textColor, setTo: UIColor(hexString: "172B4D"))
            .with(\.font, setTo: .medium(size: 12))
        
        dishImage.kf.setImage(with: URL(string: item.image ?? ""))
        
        itemView.addSubViews([contentHstack, lineView])
        contentHstack.addArrangedSubviews([dishImage, rightVstack])
        rightVstack.addArrangedSubviews([lblDishName, qtyNpriceHstack])
        qtyNpriceHstack.addArrangedSubviews([qtyView, lblPrice])
        qtyView.addSubview(qtyHstack)
        qtyHstack.addArrangedSubviews([btnDown, lblQty, btnPlus])
        itemsVstack.addArrangedSubview(itemView)
        
        contentHstack.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(contentHstack.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.bottom.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        dishImage.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
        
        qtyView.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.width.equalTo(88)
        }
        
        qtyHstack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        btnDown.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.verticalEdges.equalToSuperview()
        }
        
        btnPlus.snp.makeConstraints { make in
            make.width.height.equalTo(14)
        }
    }
    private func setupNavi() {
        navigationItem.title = "Confirm Order"
        navigationItem.leftBarButtonItem?.title = ""
    }
}
