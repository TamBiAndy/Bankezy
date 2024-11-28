//
//  LoginViewController.swift
//  Bankezy
//
//  Created by Andy on 26/11/2024.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class LoginViewController: UIViewController {
    //MARK: - IBOutlet

    @IBOutlet weak var btnCreatAcc: UIButton!
    
    @IBOutlet weak var tfEmail: UITextField!
    
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBOutlet weak var tfPassword: UITextField!
    
    @IBOutlet weak var btnCheckbox: UIButton!
    
    //MARK: UIComponent
    
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
    
    lazy var btnForgot: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("FORGOT", for: .normal)
        btn.setTitleColor(UIColor(hexString: "24CDD8"), for: .normal)
        btn.titleLabel?.font = .bold(size: 10)
        return btn
    }()
    
    lazy var rightView2: UIView = {
       let view = UIView(frame: .init(x: 0, y: 0, width: 66, height: 60))
        btnForgot.frame = .init(x: 0, y: 16, width: 46, height: 22)
        view.addSubview(btnForgot)
        return view
    }()
    
    //MARK: Variables
    var viewModel: LoginViewModel
    var isChecked = BehaviorRelay(value: false)
    
    //MARK: Initializers
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "LoginViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindingData()
        
    }
    
    //MARK: Private func
    func bindingData() {
        let input = LoginViewModel.Input(
            email: tfEmail.rx.text.asObservable(),
            password: tfPassword.rx.text.asObservable(),
            autoLogin: isChecked.asObservable(),
            loginTapped: btnLogin.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.emailValidate
            .drive(onNext: { validation in
                switch validation {
                case .valid:
                    self.iconError1.isHidden = true
                    self.iconOK1.isHidden = false
                case .error:
                    self.iconError1.isHidden = false
                    self.iconOK1.isHidden = true
                case .none:
                    self.iconError1.isHidden = true
                    self.iconOK1.isHidden = true
                }
            })
            .disposed(by: rx.disposeBag)
        
        btnCheckbox.rx.tap
            .bind(onNext: {
                self.isChecked.accept((!self.isChecked.value))
            })
            .disposed(by: rx.disposeBag)
        
        isChecked.asObservable()
            .bind(onNext: { isSelected in
                self.btnCheckbox.setImage(
                    UIImage(named: isSelected ? "Group 12709" : "Rectangle 687")
                    , for: .normal)
            })
            .disposed(by: rx.disposeBag)
        
        Driver.combineLatest(
            output.emailValidate,
            input.password.asDriver(onErrorJustReturn: nil)
        )
        .drive(onNext: { emailValid, password in
            switch (emailValid, !(password?.isEmpty ?? true)) {
            case (.valid, true):
                self.btnLogin.isEnabled = true
            default:
                self.btnLogin.isEnabled = false
            }
        })
        .disposed(by: rx.disposeBag)
        
        output.loginIsSuccess
            .drive(onNext: { isSuccess in
                if isSuccess {
                    let nextVC = HomeViewController()
                    nextVC.modalPresentationStyle = .fullScreen
                    self.present(nextVC, animated: true)
                } else {
                    
                }
            })
            .disposed(by: rx.disposeBag)
    
        output.errorLogin
            .drive(onNext: { error in
                print(error.localizedDescription)
            })
    }

    func setupView() {
        tfEmail.rightView = rightView1
        tfEmail.rightViewMode = .always
        
        tfPassword.rightView = rightView2
        tfPassword.rightViewMode = .always
    }

}
