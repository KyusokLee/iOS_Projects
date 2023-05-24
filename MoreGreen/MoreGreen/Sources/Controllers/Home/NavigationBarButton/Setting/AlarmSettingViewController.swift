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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var innerBackgroundView: UIView!
    
    weak var delegate: AlarmSettingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("AlarmSettingViewController!")
        // navigation画面遷移によるnavigation barの隠しをfalseにする
        navigationController?.setNavigationBarHidden(false, animated: false)
        setNavigationController()
        setUpScreen()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: false)
//        setNavigationController()
//    }
}

// MARK: - Logic and Function
private extension AlarmSettingViewController {
        
    func setNavigationController() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.title = "通知設定"
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        appearance.titleTextAttributes = textAttributes
        let dismissButtonImage = UIImage(systemName: "xmark")
        guard let image = dismissButtonImage else { return }
        let dismissBarButton = UIBarButtonItem(
            image: image.withTintColor(UIColor.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(didTapDismissButton)
        )
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = dismissBarButton
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func setUpScreen() {
        setUpScrollView()
    }
    
    func setUpScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.indicatorStyle = .black
        innerBackgroundView.backgroundColor = .systemBackground
    }
    
    @objc func didTapDismissButton() {
        self.dismiss(animated: true)
    }
}
