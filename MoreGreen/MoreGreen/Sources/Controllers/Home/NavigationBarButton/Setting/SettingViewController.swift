//
//  SettingViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/03.
//

import UIKit

class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationController()
        print("SettingViewController has been presented")
    }
    
    private func setNavigationController() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(rgb: 0x64B5F6)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
//        self.navigationItem.backButtonTitle = "Back"
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.compactAppearance = appearance
        self.navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.title = "設定"
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
