//
//  TabBarController.swift
//  Bankezy
//
//  Created by Andy on 28/11/2024.
//

import UIKit

class TabBarController: UITabBarController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabbar()
    }
    
    func setupTabbar() {
        let viewModel = HomeViewModel()
        let firstVC = HomeViewController(viewModel: viewModel)
        firstVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ic_home"), selectedImage: UIImage(named: "ic_homeSelect"))
        firstVC.tabBarItem.tag = 0
        let homeNavi = UINavigationController(rootViewController: firstVC)
        
        let secondVC = HomeViewController(viewModel: viewModel)
        secondVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "compass"), tag: 1)
        let compassNavi = UINavigationController(rootViewController: secondVC)
        
        let thirdVC = HomeViewController(viewModel: viewModel)
        thirdVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "receipt"), selectedImage: UIImage(named: "receiptSelect"))
        thirdVC.tabBarItem.tag = 2
        let receiptNavi = UINavigationController(rootViewController: thirdVC)
        
        let fourthVC = HomeViewController(viewModel: viewModel)
        fourthVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "user"), selectedImage: UIImage(named: "userSelect"))
        fourthVC.tabBarItem.tag = 3
        let userNavi = UINavigationController(rootViewController: fourthVC)
        
        viewControllers = [homeNavi, compassNavi, receiptNavi, userNavi]
        
        tabBar.isTranslucent = false
        tabBar.tintColor = UIColor(hexString: "EF9F27")
        tabBar.unselectedItemTintColor = UIColor(hexString: "C1C7D0")
        
        if #available(iOS 15.0, *) {
            tabBar.backgroundColor = .white
        } else {
            tabBar.barTintColor = .white
        }
    }
}
