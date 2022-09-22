//
//  TabBarController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
        configureTabBar()
        setUpTabBarItems()
        
        guard let customTabBar = self.tabBar as? CustomTabBar else { return }
        
        customTabBar.didTapButton = { [unowned self] in
            self.createNewFoodItemInfo()
        }
        
        
//        setUpMiddleButton()
//        setMiddleButtonConstraints()
    }
    
    // tabBarのUIをCustomize
    private func configureTabBar() {
        // tabbarの背景色
        tabBar.barTintColor = .white
        // tabbarのitemが選択された時の色
        tabBar.tintColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.85)
        // tabbarの選択されてないときの基本色
        tabBar.unselectedItemTintColor = .label
        tabBar.layer.cornerRadius = 23
        tabBar.layer.masksToBounds = true
        tabBar.layer.borderColor = UIColor.lightGray.cgColor
        tabBar.layer.borderWidth = 0.4
    }
    
    private func setUpTabBarItems() {
        guard let firstViewController = UIStoryboard.init(name: "HomeVC", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as? UINavigationController else {
            print("no have")
            return
        }
        
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ItemListVC") as! UINavigationController
        let newItemViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewItemVC") as! UINavigationController
        
        firstViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        firstViewController.navigationItem.largeTitleDisplayMode = .always
        firstViewController.navigationBar.prefersLargeTitles = true
        
        secondViewController.tabBarItem = UITabBarItem(title: "Item List", image: UIImage(systemName: "list.bullet.rectangle.portrait"), selectedImage: UIImage(systemName: "list.bullet.rectangle.portrait.fill"))
        secondViewController.navigationItem.largeTitleDisplayMode = .always
        secondViewController.navigationBar.prefersLargeTitles = true
        
        newItemViewController.tabBarItem = UITabBarItem(title: nil, image: nil, selectedImage: nil)
        
        let viewControllers = [firstViewController, newItemViewController, secondViewController]
        self.setViewControllers(viewControllers, animated: false)
    }
    
    private func createNewFoodItemInfo() {
        let createNewItemVC = self.storyboard?.instantiateViewController(withIdentifier: "NewItemVC") as! UINavigationController
        createNewItemVC.modalPresentationCapturesStatusBarAppearance = true
        self.present(createNewItemVC, animated: true) {
            print("will create new info of food items")
        }
    }
    
//    // コードで TabBarの真ん中にボタンを入れる
//    private func setUpMiddleButton() {
//        addButton.backgroundColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.5)
//        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
//        addButton.tintColor = .white
//
//        addButton.contentMode = .scaleAspectFit
//        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
//        addButton.translatesAutoresizingMaskIntoConstraints = false
//        addButton.layer.cornerRadius = buttonHeight / 2
//        // viewに入れるのではなく、tabBarにviewを追加すること
//        self.view.addSubview(addButton)
//    }
//
//    private func setMiddleButtonConstraints() {
//        let heightDifference = (tabBar.frame.height / 2) - buttonHeight / 2
//        addButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
//        addButton.widthAnchor.constraint(equalToConstant: buttonHeight).isActive = true
//        addButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor).isActive = true
//        addButton.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: heightDifference).isActive = true
////        self.view.layoutIfNeeded()
//    }
//
//    @objc func addButtonAction(sender: UIButton) {
//        // カメラを撮るようにAlert
//        print("camera on!")
//    }

}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return true
        }
        
        // middleButton tabbar Itemのindex
        // このアプリの場合、indexは1になっている
        if selectedIndex == 1 {
            return false
        }
        return true
    }
}
