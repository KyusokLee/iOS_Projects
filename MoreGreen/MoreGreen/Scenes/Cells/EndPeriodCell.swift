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

enum ItemNameEdit {
    case isEditing
    case normal
}

class EndPeriodCell: UITableViewCell {
    
    @IBOutlet weak var itemNameTitleLabel: UILabel! {
        didSet {
            itemNameTitleLabel.text = "商品名"
            itemNameTitleLabel.textColor = UIColor.systemGray
            itemNameTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet weak var editButton: UIButton! {
        didSet {
            // default Button Image
            let image = UIImage(systemName: "square.and.pencil")?.withTintColor(UIColor.black.withAlphaComponent(0.9), renderingMode: .alwaysOriginal)
            editButton.setImage(image, for: .normal)
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
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium)]
            
            // placeHolderの設定
            itemNameTextField.attributedPlaceholder = NSAttributedString(string: "商品名を入力", attributes: attributes)
            
            itemNameTextField.font = .systemFont(ofSize: 17, weight: .bold)
            
            itemNameTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        }
    }
    
    
    @IBOutlet weak var endPeriodView: UIView! {
        didSet {
            endPeriodView.backgroundColor = .clear
            //MARK: ⚠️こうすると、下部線のwidthだけが太くなる
            endPeriodView.layer.masksToBounds = true
            endPeriodView.layer.cornerRadius = 8
            endPeriodView.layer.borderColor = UIColor.systemGray3.withAlphaComponent(0.7).cgColor
            endPeriodView.layer.borderWidth = 1
//            endPeriodView.layer.addBorder(arrEdges: [.top, .bottom], color: UIColor.systemGray3.withAlphaComponent(0.7), width: 1)
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
    var buttonClicked: ItemNameEdit = .normal
    // 使うかどうかはまだ未定
    private var editButtonClicked: Bool = false

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
    
    // MARK: ⚠️Edit Buttonをタップ
    @IBAction func tapEditButton(_ sender: Any) {
        guard itemNameTextField.text != "" else {
            return
        }
        
        // buttonStateを変える処理のみをここに記入
        if buttonClicked == .normal {
            buttonClicked = .isEditing
            setEditButtonConstraints()
            setEditButtonImage()
            
            if !itemNameTextField.isUserInteractionEnabled {
                itemNameTextField.isUserInteractionEnabled = true
                itemNameTextField.resignFirstResponder()
            }
        } else {
            buttonClicked = .normal
            setEditButtonConstraints()
            setEditButtonImage()
            
            if itemNameTextField.isUserInteractionEnabled {
                itemNameTextField.isUserInteractionEnabled = false
            }
        }
        
        if itemNameTextField.text == "未記入" {
            itemNameTextField.text = ""
            itemNameTextField.textColor = UIColor.black.withAlphaComponent(0.8)
        }
    }
    
    @objc func textFieldEdited(textField: UITextField) {
        // UIがあっても、他のVCでアクセス可能だった
        // delegateをしたからだと思う
        self.delegate?.writeItemName(textField: textField)
    }
    
    // Edit Buttonのconstraintsを更新
    func setEditButtonConstraints() {
        if buttonClicked == .isEditing {
            // Buttonのimageを変更 ->入力完了のimageを表示
            editButton.translatesAutoresizingMaskIntoConstraints = false
            editButton.leftAnchor.constraint(equalTo: self.itemNameTitleLabel.rightAnchor, constant: 8).isActive = true
            editButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        } else {
            // 入力完了 -> 元のbutton imageを返す
            editButton.translatesAutoresizingMaskIntoConstraints = false
            editButton.leftAnchor.constraint(equalTo: self.itemNameTitleLabel.rightAnchor, constant: 8).isActive = true
            editButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        }
        self.updateConstraintsIfNeeded()
    }
    
    func setEditButtonImage() {
        switch buttonClicked {
        case .normal:
            editButton.setTitle(nil, for: .normal)
            let image = UIImage(systemName: "square.and.pencil")?.withTintColor(UIColor.black.withAlphaComponent(0.9), renderingMode: .alwaysOriginal)
            editButton.setImage(image, for: .normal)
        case .isEditing:
            editButton.setImage(nil, for: .normal)
            editButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            editButton.setTitle("入力完了", for: .normal)
        }
        
        self.layoutIfNeeded()
    }
    
    func configure(with endDate: String, itemName itemTitle: String?, checkState state: Bool, failure fail: Bool) {
        
        //MARK: itemTitleとeditButtonを関連づける処理を追加
        if itemTitle == nil {
            // 何も記入されていないとき
            // PlaceHolderのみが表示されるようになる
            itemNameTextField.text = nil
            editButton.isHidden = true
            itemNameTextField.isUserInteractionEnabled = true
        } else {
            // 記入されているとき
            if itemTitle == "" {
                // 空白のまま、保存してしまったとき (ミスを防ぐ処理)
                // もしくは、商品名を記入せずんに保存したとき
                itemNameTextField.text = "未記入"
                itemNameTextField.textColor = UIColor(rgb: 0x751717).withAlphaComponent(0.7)
            } else {
                itemNameTextField.text = itemTitle
                itemNameTextField.textColor = UIColor.black.withAlphaComponent(0.8)
            }
            editButton.isHidden = false
            itemNameTextField.isUserInteractionEnabled = false
        }
        
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
