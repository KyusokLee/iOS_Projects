//
//  DataResetPopupViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/12.
//

import UIKit

// データ初期化ボタンを押した時に表示されるPopupView
class DataResetPopupViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView! {
        didSet {
            popupView.layer.masksToBounds = true
            popupView.backgroundColor = UIColor.white
            popupView.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var resetImageView: UIImageView! {
        didSet {
            let image = UIImage(systemName: "trash")?.withTintColor(UIColor.systemRed.withAlphaComponent(0.35), renderingMode: .alwaysOriginal)
            resetImageView.image = image
        }
    }
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
            titleLabel.textColor = .black
            titleLabel.text = "データの初期化"
            titleLabel.textAlignment = .center
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.font = .systemFont(ofSize: 15, weight: .light)
            descriptionLabel.textColor = .black
            descriptionLabel.numberOfLines = 0
            descriptionLabel.text = "データを初期化すると、データの復元ができなくなります。\nデータを初期化しますか?"
            descriptionLabel.textAlignment = .center
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.backgroundColor = UIColor.systemGray3.withAlphaComponent(0.7)
            cancelButton.setTitle("戻る", for: .normal)
            cancelButton.setTitleColor(UIColor.white, for: .normal)
            cancelButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .light)
        }
    }
    
    @IBOutlet weak var checkButton: UIButton! {
        didSet {
            checkButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
            checkButton.setTitle("初期化", for: .normal)
            checkButton.setTitleColor(.white, for: .normal)
            checkButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        print("戻る!")
        self.dismiss(animated: true)
    }
    
    @IBAction func tapCheckButton(_ sender: Any) {
        print("初期化を行う!")
        self.dismiss(animated: true)
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
