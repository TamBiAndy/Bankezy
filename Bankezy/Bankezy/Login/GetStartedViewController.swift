//
//  GetStartedViewController.swift
//  Bankezy
//
//  Created by Andy on 25/11/2024.
//

import UIKit

class SessionManager {
    static let shared = SessionManager()
    let token = ""
}

class GetStartedViewController: UIViewController {

    @IBOutlet weak var btnCreatAcc: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

    }
  
    @IBAction func clickToLogin(_ sender: Any) {
        let viewModel = LoginViewModel()
        let nextVC = LoginViewController(viewModel: viewModel)
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true)
    }
    
    @IBAction func creatAccount(_ sender: Any) {
        let viewModel = CreattAccViewModel()
        let nextVC = CreatAccViewController(viewModel: viewModel)
        nextVC.modalPresentationStyle = .fullScreen
        self.present(nextVC, animated: true)
    }
    
}
