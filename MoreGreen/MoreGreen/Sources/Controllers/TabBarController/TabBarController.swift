//
//  TabBarController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit
import CoreData

//MARK: - tabbarControllerの方でnavigationBarButtonItemのclick イベントを実装するか、該当のViewControllerでイベント処理を実装するかを迷う
// -> TabbarControllerでは、controllerの構築だけをして、navigationBarItenなどのnavigationControllerの設定は、各controllerで実装することで、navigationControllerの遷移ができる
// まずは、TabbarControllerで実装することにした

// middle ButtonをTabBarに載せないと、popupViewなどがそのViewの上にある時、MiddleButtonが隠れないエラーが生じた
// 解決策: tabbarにaddSubviewすることで、できると考える

final class TabBarController: UITabBarController {
    //MARK: - Variable Part
    // ⚠️NewItemでitemを生成すると、戻る先はTabBarControllerなので、ここに
    var itemList = [ItemList]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let buttonHeight: CGFloat = 50
    private var timer: Timer?
    private var gradientLayer = CAGradientLayer()
    private let addButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold)
        //let color = UIColor(rgb: 0x36B700).withAlphaComponent(0.65)
        let color = UIColor.systemBackground
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)?.withTintColor(color, renderingMode: .alwaysOriginal)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(nil, action: #selector(tapAddButton(sender:)), for: .touchUpInside)
        return button
    }()
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    //MARK: - Life Cycle Part
    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBar()
        fetchData()
        self.delegate = self
    }
}

//MARK: - Extension
private extension TabBarController {
    func fetchData() {
        let fetchRequest: NSFetchRequest<ItemList> = ItemList.fetchRequest()
        let context = appDelegate.persistentContainer.viewContext
        do {
            self.itemList = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        itemList.forEach { item in
            print(item.endDate!)
        }
    }
    
    // tabBarのUIをCustomize
    private func setTabBar() {
        // tabbarの背景色
        tabBar.barTintColor = .white
        // tabbarのitemが選択された時の色
        tabBar.tintColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.85)
        // tabbarの選択されてないときの基本色
        tabBar.unselectedItemTintColor = .label
        // tabBarを丸くすることのメリットを見つけ出すことができないため、消す
//        tabBar.layer.cornerRadius = 23
        // 🔥falseにしないと、そとの部分が表示されない
        tabBar.layer.masksToBounds = false
//        tabBar.layer.borderColor = UIColor.lightGray.cgColor
//        tabBar.layer.borderWidth = 0.4
        setTabBarItems()
        tabBar.addSubview(addButton)
        setUpMiddleButtonConstraints()
        // GradationAnimation効果
        setUpMiddleButtonColorAnimation()
        // 影の部分はまだ、実装してない
        setTabBarShadow()
    }
    
    private func setTabBarShadow() {
        self.tabBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.tabBar.layer.shadowOpacity = 0.5
        self.tabBar.layer.shadowOffset = CGSize.zero
        self.tabBar.layer.shadowRadius = 1.5
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.layer.borderWidth = 0
        self.tabBar.clipsToBounds = false
        self.tabBar.backgroundColor = UIColor.white
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
    }
    
    // TabBarItemsの設定
    private func setTabBarItems() {
        // 最初からUINavigationControllerで括ることはできない
        let firstViewController = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
//        firstViewController.title = "Home"
        firstViewController.tabBarItem = UITabBarItem(title: "ホーム", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
//        firstViewController.navigationItem.largeTitleDisplayMode = .always
        
        let secondViewController = UIStoryboard(name: "ItemList", bundle: nil).instantiateViewController(withIdentifier: "ItemListViewController")
        secondViewController.title = "商品リスト"
        secondViewController.tabBarItem = UITabBarItem(title: "商品リスト", image: UIImage(systemName: "list.bullet.rectangle.portrait"), selectedImage: UIImage(systemName: "list.bullet.rectangle.portrait.fill"))
        secondViewController.navigationItem.largeTitleDisplayMode = .always
        
        let newItemViewController = UIStoryboard(name: "NewItem", bundle: nil).instantiateViewController(withIdentifier: "NewItemViewController")
        newItemViewController.tabBarItem = UITabBarItem(title: nil, image: nil, selectedImage: nil)
        
        let thirdViewController = UIStoryboard(name: "NoticeList", bundle: nil).instantiateViewController(withIdentifier: "NoticeListViewController")
        thirdViewController.title = "お知らせ"
        thirdViewController.tabBarItem = UITabBarItem(title: "お知らせ", image: UIImage(systemName: "bell"), selectedImage: UIImage(systemName: "bell.fill"))
        thirdViewController.navigationItem.largeTitleDisplayMode = .always
        
        let fourthViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController")
        fourthViewController.title = "Profile"
        fourthViewController.tabBarItem = UITabBarItem(title: "プロフィール", image: UIImage(systemName: "person.crop.circle"), selectedImage: UIImage(systemName: "person.crop.circle.fill"))
        fourthViewController.navigationItem.largeTitleDisplayMode = .always
        
        // navigationControllerのRoot view設定
        let navigationHome = UINavigationController(rootViewController: firstViewController)
        let navigationItemList = UINavigationController(rootViewController: secondViewController)
        let navigationCreate = UINavigationController(rootViewController: newItemViewController)
        let navigationNotice = UINavigationController(rootViewController: thirdViewController)
        let navigationProfile = UINavigationController(rootViewController: fourthViewController)
        
        navigationHome.navigationBar.prefersLargeTitles = false
        navigationItemList.navigationBar.prefersLargeTitles = false
        navigationCreate.navigationBar.prefersLargeTitles = true
        navigationNotice.navigationBar.prefersLargeTitles = true
        navigationProfile.navigationBar.prefersLargeTitles = true
        
        let viewControllers = [
            navigationHome,
            navigationItemList,
            navigationCreate,
            navigationNotice,
            navigationProfile
        ]
        self.setViewControllers(viewControllers, animated: false)
    }
    
    // TabBarの真ん中のボタンをコードで実装
    // こうすると、plus Buttonだけが表示され、背景色がなくなってしまう
    private func setUpMiddleButtonConstraints() {
        let verticalSpace: CGFloat = 1
        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            addButton.widthAnchor.constraint(equalToConstant: buttonHeight),
            addButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: verticalSpace)
        ])
    }
    
    private func setUpGradationLayer() {
        // Gradient Layer生成
        //conicグラデーション効果を与えるため、CAGradientLayerインスタンスを生成した上に、maskにCAShapeLayerを代入
        gradientLayer.frame = CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight)
        gradientLayer.masksToBounds = false
        gradientLayer.cornerRadius = gradientLayer.frame.width / 2
        gradientLayer.type = .axial
        gradientLayer.colors = GradationColor.gradientColors.map { $0.cgColor } as [Any]
        gradientLayer.locations = GradientConstants.gradientLocation
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        // buttonのimageより裏にanimationを描画するための設定
        gradientLayer.zPosition = -1
        addButton.layer.addSublayer(gradientLayer)
    }
    
    // middleButtonへgradiation Animationを与える
    // TODO: - Gradation Animation Button 実装
    private func setUpMiddleButtonColorAnimation() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: GradientConstants.animationDuration, repeats: true) { _ in
            self.gradientLayer.removeAnimation(forKey: "buttonGradationAnimation")
            let previous = GradationColor.gradientColors.map { $0.cgColor }
            let last = GradationColor.gradientColors.removeLast()
            GradationColor.gradientColors.insert(last, at: 0)
            let lastColors = GradationColor.gradientColors.map { $0.cgColor }
            let colorsAnimation = CABasicAnimation(keyPath: "colors")
            colorsAnimation.fromValue = previous
            colorsAnimation.toValue = lastColors
            colorsAnimation.autoreverses = true
            colorsAnimation.repeatCount = .infinity
            colorsAnimation.duration = GradientConstants.animationDuration
            colorsAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            colorsAnimation.isRemovedOnCompletion = false
            colorsAnimation.fillMode = .forwards
            self.gradientLayer.add(colorsAnimation, forKey: "buttonGradationAnimation")
        }
        setUpGradationLayer()
    }
    
    @objc func tapAddButton(sender: UIButton) {
        // 商品の登録VCを画面に表示
        guard let controller = UIStoryboard(name: "NewItem", bundle: nil)
            .instantiateViewController(
                withIdentifier: "NewItemViewController"
            ) as? NewItemViewController else {
            fatalError("NewItemViewController could not be found")
        }
        
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationCapturesStatusBarAppearance = true
        // fullScreenで表示させる方法
        navigationController.modalPresentationStyle = .fullScreen
        // navigation Controllerをpushじゃないpresentで表示させる方法
        self.present(navigationController, animated: true) {
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
            print("tap middle button")
            return false
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("didSelect: \(tabBarController.selectedIndex)")
    }
}
