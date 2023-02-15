//
//  ButtonCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/24.
//

import UIKit

protocol ButtonDelegate: AnyObject {
    func didFinishSaveData()
    func didFinishUpdateData()
    func didFinishDeleteData()
}

class ButtonCell: UITableViewCell {
    weak var delegate: ButtonDelegate?
    
    @IBOutlet weak var createButton: UIButton! {
        didSet {
            createButton.setTitle("作成", for: .normal)
            createButton.setTitleColor(UIColor.white, for: .normal)
            createButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .disabled)
            
            createButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            // default 設定
            createButton.backgroundColor = UIColor(rgb: 0xC0DFFD)
            createButton.isEnabled = false
            createButton.layer.cornerRadius = 8
            
            if createButton.isHidden {
                setButtonConstraints(createButton)
            }
            
        }
    }
    @IBOutlet weak var updateButton: UIButton! {
        didSet {
            updateButton.setTitle("更新", for: .normal)
            updateButton.setTitleColor(UIColor.white, for: .normal)
            updateButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            updateButton.backgroundColor = UIColor(rgb: 0xFFB74D)
            updateButton.layer.cornerRadius = 8
            
            if updateButton.isHidden {
                setButtonConstraints(updateButton)
            }
        }
    }
    @IBOutlet weak var deleteButton: UIButton! {
        didSet {
            deleteButton.setTitle("削除", for: .normal)
            deleteButton.setTitleColor(UIColor.white, for: .normal)
            deleteButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            deleteButton.backgroundColor = UIColor(rgb: 0xF5522D)
            deleteButton.layer.cornerRadius = 8
            
            if deleteButton.isHidden {
                setButtonConstraints(deleteButton)
            }
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // buttonがhiddenのとき、buttonのconstraintsをsettingするためのメソッド
    func setButtonConstraints(_ sender: UIButton!) {
        if sender.isHidden {
            sender.translatesAutoresizingMaskIntoConstraints = false
            sender.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
        self.updateConstraintsIfNeeded()
    }
    
    @IBAction func createButtonTap(_ sender: Any) {
        self.delegate?.didFinishSaveData()
    }
    
    @IBAction func updateButtonTap(_ sender: Any) {
        self.delegate?.didFinishUpdateData()
    }
    
    @IBAction func deleteButtonTap(_ sender: Any) {
        self.delegate?.didFinishDeleteData()
    }
}
