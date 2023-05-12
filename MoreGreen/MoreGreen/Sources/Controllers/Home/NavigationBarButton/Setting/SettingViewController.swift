//
//  SettingViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/03.
//

import UIKit

// SettingVCで実装したい機能まとめ
// 1. 通知の設定(通知が来る時間とか)
// 2. 地域設定
// 3. Userの設定 -> Profileのとこで実装する
// 4. 使用方法
// MARK: - Variables and Life Cycle
final class SettingViewController: UIViewController {
    
    @IBOutlet weak var settingTableView: UITableView!
    let settingModel = SettingViewItemModel.infomation
    lazy var customTabBarController = UITabBarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController()
        setTableView()
        fetchTabBarController()
    }
}

// MARK: - Func and Logics
private extension SettingViewController {
    //navigationControllerの遷移先でnavigationControllerの色の設定をすると、rootViewControllerまで影響を与えちゃう
    func setNavigationController() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.compactAppearance = appearance
        self.navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.title = "設定"
    }
    
    func setTableView() {
        settingTableView.delegate = self
        settingTableView.dataSource = self
        registerXib()
    }
    
    func registerXib() {
        settingTableView.register(UINib(nibName: "SettingTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingTableViewCell")
    }
    
    func moveTabBarControllerDownAnimation() {
        UIView.animate(
            withDuration: TabBarAnimation.duration,
            delay: 0.0,
            options: [.curveEaseInOut],
            animations: {
                self.customTabBarController.tabBar.center.y += TabBarAnimation.movingHeight
            }
        )
    }
    
    func fetchTabBarController() {
        guard let tabBarController = self.tabBarController else {
            fatalError("TabBarController could not be found")
        }
        print("func 実行")
        customTabBarController = tabBarController
    }
    //delegateで命名した間数名がdelegateを使う側の間数名と同じ時、internalをつけることで、受ける側で実装した間数を使うことが可能
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as? SettingTableViewCell else {
            fatalError("SettingTableViewCell could not found")
        }
        
        if let imageName = settingModel[indexPath.row].imageName {
            let image = UIImage(systemName: imageName)?.withTintColor(
                UIColor.black.withAlphaComponent(0.5),
                renderingMode: .alwaysOriginal
            )
            cell.cellImageView.image = image
            cell.titleLabel.text = settingModel[indexPath.row].title ?? ""
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        switch index {
        case 0:
            guard let controller = UIStoryboard(name: "AlarmSetting", bundle: nil).instantiateViewController(withIdentifier: "AlarmSettingViewController") as? AlarmSettingViewController else {
                fatalError("AlarmSettingViewController could not be found")
            }
            // ここで、delegateしなかったから、errorになった！
            controller.delegate = self
            
            tableView.deselectRow(at: indexPath, animated: true)
            self.navigationController?.pushViewController(controller, animated: true)
        case 1:
            tableView.deselectRow(at: indexPath, animated: true)
            guard let controller = UIStoryboard(name: "DataResetPopup", bundle: nil).instantiateViewController(withIdentifier: "DataResetPopupViewController") as? DataResetPopupViewController else {
                fatalError("DataResetPopupViewController could not be found")
            }
            // ここで、delegateしなかったから、errorになった！
            controller.delegate = self
            
            // .overCurrentContextだとTabbarControllerが透過されない
            controller.modalPresentationStyle = .overFullScreen
            // 🌈modalTransitionStyle: 画面が転換されるときのStyle効果を提供する。animation Styleの設定可能
            // .crossDissolve: ゆっくりと消えるスタイルの設定
            controller.modalTransitionStyle = .crossDissolve
            
            // tabBarにアニメーション効果を与える
            self.moveTabBarControllerDownAnimation()
            self.present(controller, animated: true)
        default:
            return
        }
    }
}

//MARK: - DataResetPopup の delegate
extension SettingViewController: DataResetPopupDelegate {
    // Buttonによるdelegateであることを明示したく、sender: UIButtonを記入した
    func moveTabBarControllerUpAnimation(_ sender: UIButton) {
        UIView.animate(
            withDuration: TabBarAnimation.duration,
            delay: 0.0,
            options: [.curveEaseOut],
            animations: {
                self.customTabBarController.tabBar.center.y -= TabBarAnimation.movingHeight
            }
        )
    }
}

//MARK: - AlarmSetting の delegate
extension SettingViewController: AlarmSettingDelegate {
    // ERROR: ⚠️delegateが効かない
    func delegateCheckPractice() {
        print("alarmView - settingView delegate check")
    }
}
