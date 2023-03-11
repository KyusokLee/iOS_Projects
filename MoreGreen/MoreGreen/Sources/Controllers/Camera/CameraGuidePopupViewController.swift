//
//  CameraGuidePopupViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/11.
//

import UIKit

class CameraGuidePopupViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView! {
        didSet {
            popupView.backgroundColor = UIColor.white
            popupView.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var checkImageView: UIImageView! {
        didSet {
            let image = UIImage(systemName: "checkmark.circle")?.withTintColor(UIColor(rgb: 0x36B700).withAlphaComponent(0.6), renderingMode: .alwaysOriginal)
            checkImageView.image = image
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
            titleLabel.textColor = .black
            titleLabel.text = "もう一度、表示しない"
            titleLabel.textAlignment = .center
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.font = .systemFont(ofSize: 17, weight: .light)
            descriptionLabel.textColor = .black
            descriptionLabel.text = "左上のはてなマークを押すと、いつでもカメラの活用法を確認できます"
            descriptionLabel.textAlignment = .center
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
            cancelButton.setTitle("取り消し", for: .normal)
            cancelButton.setTitleColor(UIColor.white, for: .normal)
            cancelButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .light)
        }
    }
    
    @IBOutlet weak var checkButton: UIButton! {
        didSet {
            checkButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
            checkButton.setTitle("確認", for: .normal)
            checkButton.setTitleColor(.white, for: .normal)
            checkButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapCheckButton(_ sender: Any) {
        print("check state true!")
        self.dismiss(animated: true)
    }
    

}
