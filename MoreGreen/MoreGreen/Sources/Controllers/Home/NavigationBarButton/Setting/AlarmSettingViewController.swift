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

class AlarmSettingViewController: UIViewController {
    
    @IBOutlet weak var delegateTestButton: UIButton!
    weak var delegate: AlarmSettingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("AlarmSettingViewController!")
        setNavigationController()
    }
    
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
        self.navigationItem.title = "通知設定"
    }
    
    // rouletteViewを表示するテスト
    @IBAction func tapDelegateTestButton(_ sender: Any) {
        //self.delegate?.delegateCheckPractice()
        let rouletteView = RouletteWheelView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        rouletteView.center = CGPoint(
            x: self.view.frame.size.width / 2.0,
            y: self.view.frame.size.height / 2.0
        )
        
        self.view.addSubview(rouletteView)
    }
    
}
