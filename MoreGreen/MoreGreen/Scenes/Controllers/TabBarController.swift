//
//  TabBarController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit
// MARK: APP logic
// カメラで商品の写真を撮る
// MVP🔥🔥 1-1(1). 商品のイメージを取るように
// MVP🔥🔥 1-1(2).賞味期限の OCR (GCP)
// MVP🔥 1-2. 商品のバーコードを読み込む
// 1-2(1). Yahoo search APIや外部の商品番号登録APIとfetchする (GCP 後、 他のAPI)
// MVP🔥🔥 1-3. 画面に表示
// MVP🔥 1-4. Core Dataを導入し、保存するように
// MVP🔥 1-5. dataのCRUDを可能に
// MVP🔥 1-6.　アラーム通知
// 1-7. 家族との共有システム (家の商品をより効率的に管理しよう)
// 1-8. 経済的な費用を計算するように
// 1-9. Callenderを導入し、月別のデータを見れるように

class TabBarController: UITabBarController {
    let addButton = UIButton(type: .custom)
    let buttonHeight: CGFloat = 65
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 影の部分はまだ、実装してない
        //setTabBarShadow()
        configureTabBar()
        setUpTabBarItems()
        setUpMiddleButton()
        setMiddleButtonConstraints()
        
        self.delegate = self
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
    
    private func setTabBarShadow() {
        // shadowをclearしてから、customしないと、shadowが反映されない
//        if #available(iOS 13.0, *) {
//            let appearance = self.tabBar.standardAppearance.copy()
//            appearance.backgroundImage = UIImage()
//            appearance.shadowImage = UIImage()
//            self.tabBar.standardAppearance = appearance
//        } else {
//            self.tabBar.shadowImage = UIImage()
//            self.tabBar.backgroundImage = UIImage()
//        }
//
//        if #available(iOS 15.0, *) {
//            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
//        }
        
//        tabBar.layer.masksToBounds = true
        
        self.tabBar.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.tabBar.layer.shadowColor = UIColor.black.cgColor
        self.tabBar.layer.shadowRadius = 4
        self.tabBar.layer.shadowOpacity = 0.4
        self.tabBar.layer.masksToBounds = false
    }
    
    private func setUpTabBarItems() {
        // ⚠️最初からUINavigationControllerで括ることはできない
        let firstViewController = UIStoryboard.init(name: "HomeVC", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
        let secondViewController = UIStoryboard(name: "ItemListVC", bundle: nil).instantiateViewController(withIdentifier: "ItemListVC")
        let newItemViewController = UIStoryboard(name: "NewItemVC", bundle: nil).instantiateViewController(withIdentifier: "NewItemVC")
        let thirdViewController = UIStoryboard(name: "CityInfoVC", bundle: nil).instantiateViewController(withIdentifier: "CityInfoVC")
        let fourthViewController = UIStoryboard(name: "SettingsVC", bundle: nil).instantiateViewController(withIdentifier: "SettingsVC")
        
        firstViewController.title = "Home"
        secondViewController.title = "Item List"
        thirdViewController.title = "City Info"
        fourthViewController.title = "Setting"
        
        firstViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        firstViewController.navigationItem.largeTitleDisplayMode = .always
        
        secondViewController.tabBarItem = UITabBarItem(title: "Item List", image: UIImage(systemName: "list.bullet.rectangle.portrait"), selectedImage: UIImage(systemName: "list.bullet.rectangle.portrait.fill"))
        secondViewController.navigationItem.largeTitleDisplayMode = .always

        newItemViewController.tabBarItem = UITabBarItem(title: nil, image: nil, selectedImage: nil)
        
        thirdViewController.tabBarItem = UITabBarItem(title: "City Info", image: UIImage(systemName: "building.2"), selectedImage: UIImage(systemName: "building.2.fill"))
        thirdViewController.navigationItem.largeTitleDisplayMode = .always
        
        fourthViewController.tabBarItem = UITabBarItem(title: "Setting", image: UIImage(systemName: "gearshape.circle"), selectedImage: UIImage(systemName: "gearshape.circle.fill"))
        fourthViewController.navigationItem.largeTitleDisplayMode = .always
        

        // navigationControllerのRoot view設定
        let navigationHome = UINavigationController(rootViewController: firstViewController)
        let navigationItemList = UINavigationController(rootViewController: secondViewController)
        let navigationCreate = UINavigationController(rootViewController: newItemViewController)
        let navigationCity = UINavigationController(rootViewController: thirdViewController)
        let navigationSetting = UINavigationController(rootViewController: fourthViewController)
        
        
        navigationHome.navigationBar.prefersLargeTitles = true
        navigationItemList.navigationBar.prefersLargeTitles = true
        navigationCreate.navigationBar.prefersLargeTitles = true
        navigationCity.navigationBar.prefersLargeTitles = true
        navigationSetting.navigationBar.prefersLargeTitles = true
        
        let viewControllers = [navigationHome, navigationItemList, navigationCreate, navigationCity, navigationSetting]
        self.setViewControllers(viewControllers, animated: false)
    }
    
    private func createNewFoodItemInfo() {
        let createNewItemVC = self.storyboard?.instantiateViewController(withIdentifier: "NewItemVC") as! NewItemVC
        createNewItemVC.modalPresentationCapturesStatusBarAppearance = true
        self.present(createNewItemVC, animated: true) {
            print("will create new info of food items")
        }
    }
    
    // コードで TabBarの真ん中にボタンを入れる
    private func setUpMiddleButton() {
        addButton.backgroundColor = UIColor(rgb: 0x36B700)
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .white

        addButton.contentMode = .scaleAspectFit
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.layer.cornerRadius = buttonHeight / 2
        // viewに入れるのではなく、tabBarにviewを追加すること
        self.view.layer.masksToBounds = false
        // viewに載せないと、button全体が効かない
        self.view.addSubview(addButton)
    }

    private func setMiddleButtonConstraints() {
        let heightDifference = -(buttonHeight / 2)
        addButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        addButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor).isActive = true
        addButton.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: heightDifference).isActive = true
        self.view.layoutIfNeeded()
    }
//
    @objc func addButtonAction(sender: UIButton) {
        // 商品の登録VCを画面に表示
        let createNewItemVC = UIStoryboard(name: "NewItemVC", bundle: nil).instantiateViewController(withIdentifier: "NewItemVC") as! NewItemVC
        
        let navigationNewItemVC = UINavigationController(rootViewController: createNewItemVC)
        
        navigationNewItemVC.modalPresentationCapturesStatusBarAppearance = true
        
        // navigation Controllerをpushじゃないpresentで表示させる方法
        self.present(navigationNewItemVC, animated: true) {
            print("will create new info of food items")
        }
    }

}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return true
        }
        
        // middleButton tabbar Itemのindex
        // このアプリの場合、indexは2になっている
        if selectedIndex == 2 {
            return false
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("didSelect: \(tabBarController.selectedIndex)")
    }
}
