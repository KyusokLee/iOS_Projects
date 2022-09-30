//
//  ItemImageCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/23.
//

import UIKit

// MARK: Buttonをなくして、+ pictogramで修正してもいいかも！


protocol ItemImageCellDelegate {
    func takeImagePhotoScreen()
    func takeItemImagePhoto()
    func tapImageViewEvent()
}

class ItemImageCell: UITableViewCell {
    var imageData: Data?
    var itemPhoto = UIImage()
    
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
//            resultItemImageView.image = UIImage(systemName: "plus")?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
////            resultItemImageView.image?.withConfiguration(imageConfig)
//            resultItemImageView.backgroundColor = UIColor.systemGray5
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
            itemImageCameraButton.layer.cornerRadius = 8
            itemImageCameraButton.setTitle("商品の写真を撮る", for: .normal)
            itemImageCameraButton.setTitleColor(.white, for: .normal)
            // なんか効かない
            itemImageCameraButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
            itemImageCameraButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
        }
    }
    
    var delegate: ItemImageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imagePlusButton.isHidden = false
        addImageViewTapGesture()
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
    func configure(with image: UIImage?) {
        if let hasImage = image {
            imagePlusButton.isHidden = true
            resultItemImageView.backgroundColor = .clear
            let itemImage = hasImage
            resultItemImageView.image = itemImage
        } else {
            if imagePlusButton.isHidden {
                imagePlusButton.isHidden = false
            }
            resultItemImageView.backgroundColor = UIColor.systemGray5
        }
        
        self.layoutIfNeeded()
    }
    
    func addImageViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapImageView))
        resultItemImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapImageView() {
        guard imageData != nil else {
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
