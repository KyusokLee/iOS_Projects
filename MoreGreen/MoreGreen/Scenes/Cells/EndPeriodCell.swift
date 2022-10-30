//
//  EndPeriodCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/24.
//

import UIKit

// TODO: 賞味期限を直接入力も可能にする
// TODO: 賞味期限をカレンダーから選ぶようにする

protocol EndPeriodCellDelegate {
    func takeEndPeriodScreen()
    func writeItemName(textField: UITextField)
}

class EndPeriodCell: UITableViewCell {
    
    @IBOutlet weak var itemNameTitleLabel: UILabel! {
        didSet {
            itemNameTitleLabel.text = "商品名"
            itemNameTitleLabel.textColor = UIColor.systemGray
            itemNameTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet weak var endPeriodTitleLabel: UILabel! {
        didSet {
            endPeriodTitleLabel.text = "賞味期限"
            endPeriodTitleLabel.textColor = UIColor.systemGray
            endPeriodTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet weak var itemNameTextField: UITextField! {
        didSet {
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
            
            itemNameTextField.attributedPlaceholder = NSAttributedString(string: "商品名を入力", attributes: attributes)
            itemNameTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        }
    }
    
    
    @IBOutlet weak var endPeriodView: UIView! {
        didSet {
            endPeriodView.backgroundColor = .clear
            //MARK: ⚠️こうすると、下部線のwidthだけが太くなる
            endPeriodView.layer.addBorder(arrEdges: [.top, .bottom], color: UIColor.systemGray3.withAlphaComponent(0.7), width: 1)
            // 上と下だけ線を引きたいので、extensionのCALayerを用いて、メソッドを呼び出す
        }
    }
    
    @IBOutlet weak var endPeriodDataLabel: UILabel! {
        didSet {
            endPeriodDataLabel.text = "日付が表示されます"
            endPeriodDataLabel.font = .systemFont(ofSize: 17, weight: .bold)
            endPeriodDataLabel.textColor = UIColor.systemGray3
        }
    }
    
    
    
    @IBOutlet weak var endPeriodShootButton: UIButton! {
        didSet {
            endPeriodShootButton.setTitle("賞味期限の写真を撮る", for: .normal)
            endPeriodShootButton.setTitleColor(.white, for: .normal)
            endPeriodShootButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
            endPeriodShootButton.tintColor = UIColor.white
            endPeriodShootButton.backgroundColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.7)
            endPeriodShootButton.layer.cornerRadius = 8
            
        }
    }
    
    var delegate: EndPeriodCellDelegate?
    // ⚠️使うかどうかはまだ未定
    var itemName = ""
    var endPeriodText = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func shootEndPeriod(_ sender: Any) {
        // カメラを撮りますかの写真がでるように
        print("take a endPeriod image text ocr")
        self.delegate?.takeEndPeriodScreen()
    }
    
    @objc func textFieldEdited(textField: UITextField) {
        // UIがあっても、他のVCでアクセス可能だった
        // delegateをしたからだと思う
        self.delegate?.writeItemName(textField: textField)
    }
    
    
    func configure(with endDate: String, checkState state: Bool, failure fail: Bool) {
        
        if endDate != "" {
            endPeriodDataLabel.text = endDate
        } else {
            // endDate が ""のとき　（データなし）の時
            endPeriodDataLabel.text = "日付が表示されます"
            endPeriodDataLabel.font = .systemFont(ofSize: 17, weight: .bold)
            endPeriodDataLabel.textColor = UIColor.systemGray3
            return
        }
        
        if !state {
            // 認証に失敗
            endPeriodDataLabel.textColor = UIColor(rgb: 0x751717)
            endPeriodDataLabel.font = .systemFont(ofSize: 17, weight: .medium)
        } else {
            if fail {
                // 正常に文字認識はできるが、日付を読み取れなかったとき
                endPeriodDataLabel.textColor = UIColor(rgb: 0x751717)
                endPeriodDataLabel.font = .systemFont(ofSize: 17, weight: .medium)
            } else {
                // 認証に成功、または、Core Data上のデータがある場合
                endPeriodDataLabel.textColor = UIColor(rgb: 0x388E3C)
                endPeriodDataLabel.font = .systemFont(ofSize: 17, weight: .medium)
            }
        }
        
        self.layoutIfNeeded()
    }
    
}
