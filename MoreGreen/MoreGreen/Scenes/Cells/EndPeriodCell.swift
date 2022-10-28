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
}

class EndPeriodCell: UITableViewCell {
    
    @IBOutlet weak var endPeriodtitleLabel: UILabel! {
        didSet {
            endPeriodtitleLabel.text = "賞味期限"
            endPeriodtitleLabel.textColor = UIColor.systemGray
            endPeriodtitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet weak var itemNameTextField: UITextField! {
        didSet {
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
            
            itemNameTextField.attributedPlaceholder = NSAttributedString(string: "商品名を入力", attributes: attributes)
        }
    }
    
    
    @IBOutlet weak var endPeriodView: UIView! {
        didSet {
            endPeriodView.backgroundColor = .clear
            //MARK: ⚠️こうすると、下部線のwidthだけが太くなる
            endPeriodView.layer.addBorder(arrEdges: [.top, .bottom], color: UIColor(rgb: 0x115293), width: 1)
            // 上と下だけ線を引きたいので、extensionのCALayerを用いて、メソッドを呼び出す
//            endPeriodView.layer.borderColor = UIColor(rgb: 0x36B700).cgColor
//            endPeriodView.layer.borderWidth = 0.5
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
