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

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController()
        
    }
    
    // navigationControllerの遷移先でnavigationControllerの色の設定をすると、rootViewControllerまで影響を与えてしまう
    private func setNavigationController() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        // MARK: - AppAppearanceの実装で、ここでの実装はしなくてもよくなった
//        appearance.backgroundColor = UIColor.white
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.black.withAlphaComponent(0.7)]
        self.navigationItem.backButtonTitle = .none
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.compactAppearance = appearance
        self.navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.title = "設定"
    }
    
    

}
