//
//  AddPaymentMethodViewController.swift
//  Bankezy
//
//  Created by Andy on 27/12/2024.
//

import UIKit
import RxSwift
import RxCocoa
import FloatingPanel

class AddPaymentMethodViewController: UIViewController {
    
    //MARK: UIComponent
    lazy var leftView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: 48, height: 44))
        let leftImageView = UIImageView(frame: .init(x: 22, y: 16, width: 14, height: 12))
        leftImageView.contentMode = .scaleAspectFit
        leftImageView.image = UIImage(named: "credit-card")
        view.addSubview(leftImageView)
        return view
    }()
    
    lazy var rightImage = UIImageView()
        .with(\.image, setTo: UIImage(named: "Check-circle"))
        .with(\.contentMode, setTo: .scaleToFill)
    
    lazy var rightView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: 34, height: 44))
        rightImage.frame = .init(x: 0, y: 10, width: 24, height: 24)
        view.addSubview(rightImage)
        return view
    }()
    
    //MARK: IBOutlet
    @IBOutlet weak var tfCVCNumber: UITextField!
    
    @IBOutlet weak var tfDateExpire: UITextField!
    
    @IBOutlet weak var tfCardNumber: UITextField!
    
    @IBOutlet weak var btnAddCard: UIButton!
    
    @IBOutlet weak var btnScanCard: UIButton!
    
    //MARK: Variables
    var viewModel: AddPaymentMethodViewModel
    
    //MARK: Initializers
    init(viewModel: AddPaymentMethodViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "AddPaymentMethodViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindData()
    }
    
    private func bindData() {
        let input = AddPaymentMethodViewModel.Input(
            cardNumber: tfCardNumber.rx.text.asObservable(),
            expireDate: tfDateExpire.rx.text.asObservable(),
            cvcNumber: tfCVCNumber.rx.text.asObservable(),
            addCartTapped: btnAddCard.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.isValidCardNumber
            .drive(onNext: { validation in
                switch validation {
                case .valid:
                    self.rightImage.image = UIImage(named: "check")
                case .error, .none:
                    self.rightImage.image = UIImage(named: "Check-circle")
                }
            })
            .disposed(by: rx.disposeBag)
        
        Driver.combineLatest(
            output.isValidCardNumber,
            output.isValidExpireDate,
            output.isValidCvcNumber
        )
        .drive(onNext: { isValidCardNumber, isValidexpireDate, isValidcvcNumber in
            switch ( isValidCardNumber, isValidexpireDate, isValidcvcNumber) {
            case (.valid, .valid, .valid):
                self.btnAddCard.isEnabled = true
            default:
                self.btnAddCard.isEnabled = false
            }
        })
        .disposed(by: rx.disposeBag)
        
        output.cardNumberFormated
            .unwrap()
            .map { String($0.prefix(19)) }
            .drive(tfCardNumber.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.expireDateFormated
            .unwrap()
            .map { String($0.prefix(5)) }
            .drive(tfDateExpire.rx.text)
            .disposed(by: rx.disposeBag)
        
        output.isSuccess
            .drive(onNext: { isSuccess in
                if isSuccess {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    
                }
            })
            .disposed(by: rx.disposeBag)
            
    }

    private func setupView() {
        tfCardNumber.leftView = leftView
        tfCardNumber.leftViewMode = .always
        tfCardNumber.rightView = rightView
        tfCardNumber.rightViewMode = .always
    }
}

extension AddPaymentMethodViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        return BottomPositionedPanelLayout()
    }
}

class BottomPositionedPanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .full
    let anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] = [
        .full: FloatingPanelLayoutAnchor(absoluteInset: 380, edge: .top, referenceGuide: .safeArea)
    ]
}
