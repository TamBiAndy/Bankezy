//
//  CreatAccViewController.swift
//  Bankezy
//
//  Created by Andy on 26/11/2024.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class CreatAccViewController: UIViewController {

    @IBOutlet weak var emailVstack: UIStackView!
    
    @IBOutlet weak var tfEmail: UITextField!
    
    @IBOutlet weak var lblError: UILabel!
    
    @IBOutlet weak var tfPassword: UITextField!
    
    @IBOutlet weak var tfPhoneNumber: UITextField!
    
    @IBOutlet weak var btnCreate: UIButton!
    
    lazy var rightView1: UIView = {
       let view = UIView(frame: .init(x: 0, y: 0, width: 49, height: 60))
       let stackview = UIStackView(frame: .zero)
        stackview.addArrangedSubviews([iconError1, iconOK1])
        stackview.frame = .init(x: 0, y: 16, width: 28, height: 28)
        view.addSubview(stackview)
        return view
    }()
    
    lazy var iconError1 = UIImageView(frame: .init(x: 0, y: 0, width: 28, height: 28))
        .with(\.image, setTo: UIImage(named: "Group 12708"))
        .with(\.contentMode, setTo: .scaleToFill)
    
    lazy var iconOK1 = UIImageView(frame: .init(x: 0, y: 0, width: 28, height: 28))
        .with(\.image, setTo: UIImage(named: "Group 12709"))
        .with(\.contentMode, setTo: .scaleToFill)
    
    lazy var btnHide: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("HIDE", for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.titleLabel?.font = .bold(size: 10)
        btn.backgroundColor = UIColor(hexString: "49435E")
        btn.layer.cornerRadius = 6
        return btn
    }()
    
    lazy var rightView2: UIView = {
       let view = UIView(frame: .init(x: 0, y: 0, width: 66, height: 60))
        btnHide.frame = .init(x: 0, y: 16, width: 46, height: 22)
        view.addSubview(btnHide)
        return view
    }()
    
    lazy var rightView3: UIView = {
       let view = UIView(frame: .init(x: 0, y: 0, width: 49, height: 60))
       let stackview = UIStackView(frame: .zero)
        stackview.addArrangedSubviews([iconError2, iconOK2])
        stackview.frame = .init(x: 0, y: 16, width: 28, height: 28)
        view.addSubview(stackview)
        return view
    }()
    
    lazy var iconError2 = UIImageView(frame: .init(x: 0, y: 0, width: 28, height: 28))
        .with(\.image, setTo: UIImage(named: "Group 12708"))
        .with(\.contentMode, setTo: .scaleToFill)
    
    lazy var iconOK2 = UIImageView(frame: .init(x: 0, y: 0, width: 28, height: 28))
        .with(\.image, setTo: UIImage(named: "Group 12709"))
        .with(\.contentMode, setTo: .scaleToFill)
    
    var viewModel: CreattAccViewModel
    
    init(viewModel: CreattAccViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "CreatAccViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindingData()
    }
    
    
    private func bindingData() {
        let input = CreattAccViewModel.Input(
            email: tfEmail.rx.text.asObservable(),
            password: tfPassword.rx.text.asObservable(),
            phoneNumber: tfPhoneNumber.rx.text.asObservable(), 
            createTapped: btnCreate.rx.tap.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        output.emailIsValid
            .drive(onNext: { validation in
                switch validation {
                case .valid:
                    self.iconOK1.isHidden = false
                    self.iconError1.isHidden = true
                    self.lblError.isHidden = true
                case .error:
                    self.iconOK1.isHidden = true
                    self.iconError1.isHidden = false
                    self.lblError.isHidden = false
                case .none:
                    self.iconOK1.isHidden = true
                    self.iconError1.isHidden = true
                    self.lblError.isHidden = true
                }
            })
            .disposed(by: rx.disposeBag)
        
        btnHide.rx.tap
            .bind(onNext: {
                self.tfPassword.isSecureTextEntry = !self.tfPassword.isSecureTextEntry
            })
            .disposed(by: rx.disposeBag)
        
        output.phoneNumberIsValid
            .drive(onNext: {
                switch $0 {
                case .valid:
                    self.iconOK2.isHidden = false
                    self.iconError2.isHidden = true
                case .error:
                    self.iconOK2.isHidden = true
                    self.iconError2.isHidden = false
                case .none:
                    self.iconOK2.isHidden = true
                    self.iconError2.isHidden = true
                }
            })
            .disposed(by: rx.disposeBag)
        
        Driver.combineLatest(
            output.emailIsValid,
            output.phoneNumberIsValid,
            input.password.asDriver(onErrorJustReturn: nil)
        )
        .drive(onNext: { emailIsValid, phoneNumberIsValid, password in
            switch (emailIsValid, phoneNumberIsValid, !(password?.isEmpty ?? true)) {
            case (.valid, .valid, true):
                self.btnCreate.isEnabled = true
            default:
                self.btnCreate.isEnabled = false
            }
        })
        .disposed(by: rx.disposeBag)
        
        output.isSuccess
            .drive(onNext: { isSucces in
                if isSucces {
                    let viewModel = LoginViewModel()
                    let nextVC = LoginViewController(viewModel: viewModel)
                    nextVC.modalPresentationStyle = .fullScreen
                    self.present(nextVC, animated: true)
                } else {
                    
                }
            })
            .disposed(by: rx.disposeBag)
        
        output.error
            .drive(onNext: { error in
                print(error.localizedDescription)
            })
            .disposed(by: rx.disposeBag)
    }
    private func setupView() {
        tfEmail.rightView = rightView1
        tfEmail.rightViewMode = .always
        
        tfPassword.rightView = rightView2
        tfPassword.rightViewMode = .always
        
        tfPhoneNumber.rightView = rightView3
        tfPhoneNumber.rightViewMode = .always
    }
    

}
