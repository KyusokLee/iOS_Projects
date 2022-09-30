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
            createButton.tintColor = UIColor.white
            createButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            createButton.backgroundColor = UIColor(rgb: 0x0095F6)
            createButton.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var updateButton: UIButton! {
        didSet {
            updateButton.setTitle("更新", for: .normal)
            updateButton.tintColor = UIColor.white
            updateButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            updateButton.backgroundColor = UIColor(rgb: 0xFFB74D)
            updateButton.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var deleteButton: UIButton! {
        didSet {
            deleteButton.setTitle("削除", for: .normal)
            deleteButton.tintColor = UIColor.white
            deleteButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            deleteButton.backgroundColor = UIColor(rgb: 0xF5522D)
            deleteButton.layer.cornerRadius = 8
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
