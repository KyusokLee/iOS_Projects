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

class SettingViewController: UIViewController {
    
    @IBOutlet weak var settingTableView: UITableView!
    let settingModel = SettingModel.infomation
    let customTabBarController = TabBarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController()
        setTableView()
    }
    // navigationControllerの遷移先でnavigationControllerの色の設定をすると、rootViewControllerまで影響を与えてしまう
    private func setNavigationController() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        // MARK: - AppAppearanceの実装で、ここでの実装はしなくてもよくなった
//        appearance.backgroundColor = UIColor.white
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.black.withAlphaComponent(0.7)]
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.compactAppearance = appearance
        self.navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.title = "設定"
    }
    
    private func setTableView() {
        settingTableView.delegate = self
        settingTableView.dataSource = self
        registerXib()
    }
    
    private func registerXib() {
        settingTableView.register(UINib(nibName: "SettingTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingTableViewCell")
    }
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
            tableView.deselectRow(at: indexPath, animated: true)
            self.navigationController?.pushViewController(controller, animated: true)
        case 1:
            tableView.deselectRow(at: indexPath, animated: true)
            guard let controller = UIStoryboard(name: "DataResetPopup", bundle: nil).instantiateViewController(withIdentifier: "DataResetPopupViewController") as? DataResetPopupViewController else {
                fatalError("DataResetPopupViewController could not be found")
            }
            
            controller.modalPresentationStyle = .overCurrentContext
            // 🌈modalTransitionStyle: 画面が転換されるときのStyle効果を提供する。animation Styleの設定可能
            // .crossDissolve: ゆっくりと消えるスタイルの設定
            controller.modalTransitionStyle = .crossDissolve
            
            // tabBarControllerへのアクセスができる
            // 表示されたViewControllerのancestorのtabbarControllerの取得,つまり、ViewControllerの親のcontrollerを取得できる
            if let tabBarcontroller = tabBarController {
                tabBarcontroller.tabBar.isHidden = true
            }
            
            self.present(controller, animated: true)
        default:
            return
        }
    }
    
    
}
