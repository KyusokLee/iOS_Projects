//
//  CameraGuidePopupViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/11.
//

import UIKit
import CoreData

protocol CameraGuidePopupDelegate: AnyObject {
    func shouldShowCameraGuideViewAgain()
    func shouldHideCameraGuideView()
}

// MARK: - Life Cycle and Variables
final class CameraGuidePopupViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
        
    weak var delegate: CameraGuidePopupDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
    }
}

// MARK: - Function and Logic
private extension CameraGuidePopupViewController {
    @IBAction func didTapCancelButton(_ sender: Any) {
        print("cancel!")
        delegate?.shouldShowCameraGuideViewAgain()
        self.dismiss(animated: true)
    }
    
    // checkButton -> CoreDataのcheckStateをTrueにする
    @IBAction func didTapCheckButton(_ sender: Any) {
        print("check state true!")
        delegate?.shouldHideCameraGuideView()
        self.dismiss(animated: true)
    }
    
    // ここで、ViewのUIを確率する
    func setUpScreen() {
        setUpPopUpView()
        setUpCheckImageView()
        setUpTitleLabel()
        setUpDescriptionLabel()
        setUpCancelButton()
        setUpCheckButton()
    }
    
    func setUpPopUpView() {
        popupView.backgroundColor = UIColor.white
        popupView.layer.cornerRadius = 8
        popupView.layer.masksToBounds = true
    }
    
    func setUpCheckImageView() {
        let image = UIImage(systemName: "checkmark.circle")?.withTintColor(UIColor(rgb: 0x36B700).withAlphaComponent(0.6), renderingMode: .alwaysOriginal)
        checkImageView.image = image
    }
    
    func setUpTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.text = "これ以上、表示しない"
        titleLabel.textAlignment = .center
    }
    
    func setUpDescriptionLabel() {
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .light)
        descriptionLabel.textColor = .black
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "左上のはてなマークを押すと、いつでもカメラの活用法を確認できます"
        descriptionLabel.textAlignment = .center
    }
    
    func setUpCancelButton() {
        cancelButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
        cancelButton.setTitle("取り消す", for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .light)
    }
    
    func setUpCheckButton() {
        checkButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
        checkButton.setTitle("確認", for: .normal)
        checkButton.setTitleColor(.white, for: .normal)
        checkButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
    }
}
