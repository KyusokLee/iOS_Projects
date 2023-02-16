//
//  ItemImageCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/23.
//

import UIKit

// MARK: Buttonをなくして、+ pictogramで修正してもいいかも！
// MARK: image の方は、long press gestrueに変える
// Layoutの警告: imageViewのTop Spaceが、なぜか、itemImageCreateLabelのtopになっていて、contentViewがlayoutをestimatedできないのが原因であった

protocol ItemImageCellDelegate {
    func takeImagePhotoScreen()
    func takeItemImagePhoto()
    func tapImageViewEvent()
    func longPressImageViewEvent()
}

class ItemImageCell: UITableViewCell {
    var imageData: Data?
    var itemPhoto = UIImage()
    var bottomExplainText = ""
    
    @IBOutlet weak var itemImageCreateLabel: UILabel! {
        didSet {
            itemImageCreateLabel.text = "商品のイメージ"
            itemImageCreateLabel.font = .systemFont(ofSize: 17, weight: .medium)
            itemImageCreateLabel.textColor = UIColor.systemGray
        }
    }
    
    // ImageViewにgestureを追加する予定
    @IBOutlet weak var resultItemImageView: UIImageView! {
        didSet {
            // withTintColorだと、alwaysOriginalで、色を変えれる
            // ただの、tintColorだと、alwaysTemplateで色の変更ができる
            
//            let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
            // plusイメージを小さくしたい
            // configurationを用いても、変わらなかった
            
            resultItemImageView.layer.cornerRadius = 8
            resultItemImageView.contentMode = .scaleAspectFill
            self.resultItemImageView.isUserInteractionEnabled = true
            // 長押しのgesture
            addImageViewLongTapGesture()
            // ただのtapのgesture
            addImageViewTapGesture()
        }
    }
    
    // imageがあれば、hiddenにしておく
    // また、imageViewにtapGestureを追加する
    @IBOutlet weak var imagePlusButton: UIButton! {
        didSet {
            setButtonOnImage()
        }
    }
    
    @IBOutlet weak var itemImageCameraButton: UIButton! {
        didSet {
            itemImageCameraButton.layer.masksToBounds = true
            itemImageCameraButton.layer.cornerRadius = 8
            itemImageCameraButton.setTitle("商品の写真を撮る", for: .normal)
            itemImageCameraButton.setTitleColor(.white, for: .normal)
            // なんか効かない
            itemImageCameraButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
            itemImageCameraButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
        }
    }
    
    var delegate: ItemImageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imagePlusButton.isHidden = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setButtonOnImage() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 60, weight: .medium)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        imagePlusButton.setImage(image?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal), for: .normal)
        imagePlusButton.backgroundColor = .clear
    }
    
    
    // ⚠️NewItemVCとどのように繋げるかがちょっと難しい
    // 商品のimageがあるときだけ、呼び出すメソッド
    func configure(with imageData: Data, scaleX x: CGFloat?, scaleY y: CGFloat?) {
        // なにもないとき
        if imageData == Data() {
            imagePlusButton.isHidden = false
            resultItemImageView.image = nil
            resultItemImageView.backgroundColor = UIColor.systemGray5
        } else {
            // 初期化のData()以外のデータが入っているとき
            self.imageData = imageData
            imagePlusButton.isHidden = true
            resultItemImageView.backgroundColor = .clear
            let image = UIImage(data: imageData)
            resultItemImageView.image = image!
            self.itemPhoto = image!
            
            if x != nil || y != nil {
                resultItemImageView.transform = (resultItemImageView.transform).scaledBy(x: x!, y: y!)
            }
        }
        
        self.layoutIfNeeded()
    }
    
    // 長押しで実行されるメソッド
    func addImageViewLongTapGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressImageView))
        resultItemImageView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func longPressImageView(_ sender: UILongPressGestureRecognizer) {
        guard resultItemImageView.image != nil else {
            return
        }
        
        // タップを長押しして表示されるようにしたいなら、.began
        // 指を離した後に表示させたいのであれば、.ended
        if sender.state == .began {
            self.delegate?.longPressImageViewEvent()
        }
    }
    
    // ただ、tapしたら呼び出されるメソッド
    func addImageViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapImageView))
        resultItemImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapImageView(_ sender: UITapGestureRecognizer) {
        guard resultItemImageView.image != nil else {
            return
        }
        
        self.delegate?.tapImageViewEvent()
    }
    
    
    @IBAction func takeItemImageTap(_ sender: Any) {
        print("take photo !!!")
        self.delegate?.takeItemImagePhoto()
        
    }
    
    @IBAction func shootItemImage(_ sender: Any) {
        print("take a Item Image Photo")
        self.delegate?.takeImagePhotoScreen()
    }
    
    
}
