//
//  TabBarController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit
import CoreData
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

//MARK: - tabbarControllerの方でnavigationBarButtonItemのclick イベントを実装するか、該当のViewControllerでイベント処理を実装するかを迷う
// -> TabbarControllerでは、controllerの構築だけをして、navigationBarItenなどのnavigationControllerの設定は、各controllerで実装することで、navigationControllerの遷移ができる
// まずは、TabbarControllerで実装することにした

// middle ButtonをTabBarに載せないと、popupViewなどがそのViewの上にある時、MiddleButtonが隠れないエラーが生じた
// 解決策: tabbarにaddSubviewすることで、できると考える

//TODO: - HitTestで、Middle Buttonのtouch領域を広げる

final class TabBarController: UITabBarController {
    
//MARK: - Variable Part
    // ⚠️Error: MiddleButtonがTabbarControllerの要素としてあるわけではなく、位置調整でそこにあるように見られているだけだった..
    let buttonHeight: CGFloat = 65
    // ⚠️NewItemでitemを生成すると、戻る先はTabBarControllerなので、ここに
    var itemList = [ItemList]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let addButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "plus.circle.fill")?
            .withTintColor(
                UIColor(rgb: 0x36B700).withAlphaComponent(0.65),
                renderingMode: .alwaysOriginal
            )
        
        let hideImage = UIImage(systemName: "plus.circle.fill")?
            .withTintColor(
                UIColor.black.withAlphaComponent(0.7),
                renderingMode: .alwaysOriginal
            )
        
        button.setBackgroundImage(image, for: .normal)
        button.setBackgroundImage(hideImage, for: .disabled)
        button.addTarget(nil, action: #selector(tapAddButton(sender:)), for: .touchUpInside)
        return button
    }()
    
//MARK: - Life Cycle Part
    override func viewDidLoad() {
        super.viewDidLoad()
        // 影の部分はまだ、実装してない
        //setTabBarShadow()
        setTabBar()
        fetchData()
        self.delegate = self
    }
}

//MARK: - Extension
extension TabBarController {
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
        //setTabBarShadow()
        setUpMiddleButton()
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
        self.tabBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.tabBar.layer.shadowOpacity = 0.5
        self.tabBar.layer.shadowOffset = CGSize.zero
        self.tabBar.layer.shadowRadius = 5
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.layer.borderWidth = 0
        self.tabBar.clipsToBounds = false
        self.tabBar.backgroundColor = UIColor.white
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        //しかし、middleButtonの上の部分まで線が続くようになる
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
    
    private func createNewFoodItemInfo() {
        guard let controller = self.storyboard?.instantiateViewController(
            withIdentifier: "NewItemViewController"
        ) as? NewItemViewController else {
            fatalError("NewItemViewController could not be found")
        }
        
        controller.modalPresentationCapturesStatusBarAppearance = true
        self.present(controller, animated: true) {
            print("will create new info of food items")
        }
    }
    
//    // コードで TabBarの真ん中にボタンを入れる
//    private func setUpMiddleButton() {
//        addButton.backgroundColor = UIColor(rgb: 0x36B700)
//        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
//        addButton.tintColor = .white
//        addButton.contentMode = .scaleAspectFit
//        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
//        addButton.translatesAutoresizingMaskIntoConstraints = false
//        addButton.layer.cornerRadius = buttonHeight / 2
//        // viewに入れるのではなく、tabBarにviewを追加すること
//        self.view.layer.masksToBounds = false
//        // viewに載せないと、button全体が効かない
//        self.view.addSubview(addButton)
//    }
    
    // TabBarの真ん中のボタンをコードで実装
    // こうすると、plus Buttonだけが表示され、背景色がなくなってしまう
    private func setUpMiddleButton() {
        let width: CGFloat = 70/375 * self.view.frame.width
        let height: CGFloat = 70/375 * self.view.frame.width
        let posX: CGFloat = self.view.frame.width/2 - width/2
        let posY: CGFloat = -32
        addButton.frame = CGRect(x: posX, y: posY, width: width, height: height)
//        tabBar.addSubview(self.addButton)
        self.tabBar.addSubview(self.addButton)
    }

    private func setMiddleButtonConstraints() {
        let heightDifference = -(buttonHeight / 2)
        addButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        addButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor).isActive = true
        addButton.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: heightDifference).isActive = true
        // subViewがないのに、layoutIfNeededをすることは正しくなかった
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

// Youtubeのcomment sheetViewみたいなものを表示する間数
//private func presentModal() {
//    let controller = DetailViewController()
//    let navigationController = UINavigationController(rootViewController: controller)
//    // 2
//    if let sheet = navigationController.sheetPresentationController {
//        // 3
//        sheet.detents = [.medium(), .large()]
//    }
//    self.present(navigationController, animated: true, completion: nil)
//}
