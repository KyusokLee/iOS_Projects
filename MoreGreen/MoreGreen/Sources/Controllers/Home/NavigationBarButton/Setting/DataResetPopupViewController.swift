//
//  DataResetPopupViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/12.
//

import UIKit

protocol DataResetPopupDelegate: AnyObject {
    func moveTabBarControllerUpAnimation(_ sender: UIButton)
}

// データ初期化ボタンを押した時に表示されるPopupView
// MARK: - Life Cycle and Variables
final class DataResetPopupViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var resetImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    weak var delegate: DataResetPopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
    }
}

// MARK: - Logic and Function
private extension DataResetPopupViewController {
    @IBAction func didTapCancelButton(_ sender: UIButton!) {
        print("戻る!")
        delegate?.moveTabBarControllerUpAnimation(sender)
        self.dismiss(animated: true) {
            print("moveTabbar up")
        }
    }
    
    @IBAction func didTapCheckButton(_ sender: UIButton!) {
        print("初期化を行う!")
        delegate?.moveTabBarControllerUpAnimation(sender)
        self.dismiss(animated: true) {
            print("moveTabbar up")
        }
    }
    
    // ここで、ScreenのUIを確率する
    func setUpScreen() {
        setUpPopupView()
        setUpResetImageView()
        setUpTitleLabel()
        setUpDescriptionLabel()
        setUpCancelButton()
        setUpCheckButton()
    }
    
    func setUpPopupView() {
        popupView.layer.masksToBounds = true
        popupView.backgroundColor = UIColor.white
        popupView.layer.cornerRadius = 8
    }
    
    func setUpResetImageView() {
        let image = UIImage(systemName: "trash")?.withTintColor(UIColor.systemRed.withAlphaComponent(0.35), renderingMode: .alwaysOriginal)
        resetImageView.image = image
    }
    
    func setUpTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.text = "データの初期化"
        titleLabel.textAlignment = .center
    }
    
    
    func setUpDescriptionLabel() {
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .light)
        descriptionLabel.textColor = .black
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "データを初期化すると、データの復元ができなくなります。\nデータを初期化しますか?"
        descriptionLabel.textAlignment = .center
    }
    
    func setUpCancelButton() {
        cancelButton.backgroundColor = UIColor.systemGray3.withAlphaComponent(0.7)
        cancelButton.setTitle("戻る", for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .light)
    }
    
    func setUpCheckButton() {
        checkButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
        checkButton.setTitle("初期化", for: .normal)
        checkButton.setTitleColor(.white, for: .normal)
        checkButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
    }
}
