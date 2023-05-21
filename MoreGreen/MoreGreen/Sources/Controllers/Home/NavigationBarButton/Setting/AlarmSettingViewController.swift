//
//  AlarmSettingViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/12.
//

import UIKit

protocol AlarmSettingDelegate: AnyObject {
    func delegateCheckPractice()
}

// MARK: - Life Cycle and Variables
final class AlarmSettingViewController: UIViewController {
    
    @IBOutlet weak var dismissButton: UIButton!
    
    
    weak var delegate: AlarmSettingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("AlarmSettingViewController!")
        setUpScreen()
        //setNavigationController()
    }
}

// MARK: - Logic and Function
private extension AlarmSettingViewController {
    
    @IBAction func didTapDismissButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func setNavigationController() {
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
        self.navigationItem.title = "通知設定"
    }
    
    func setUpScreen() {
        setUpDismissButton()
    }
    
    func setUpDismissButton() {
        let color = UIColor.black.withAlphaComponent(0.7)
        let image = UIImage(systemName: "xmark")?.withTintColor(color, renderingMode: .alwaysOriginal)
        guard let image = image else { return }
        dismissButton.setImage(image, for: .normal)
        //Buttonの設定したconstraintsより、imageが小さくなった場合、Buttonをsizeの大きさに合わせる方法
        dismissButton.contentVerticalAlignment = .fill
        dismissButton.contentHorizontalAlignment = .fill
    }
}
