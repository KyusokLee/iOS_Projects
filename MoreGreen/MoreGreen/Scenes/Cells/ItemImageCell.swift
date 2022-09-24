//
//  ItemImageCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/23.
//

import UIKit


protocol ItemImageCellDelegate {
    func takeImagePhotoScreen()
}

class ItemImageCell: UITableViewCell {
    
    @IBOutlet weak var itemImageCreateLabel: UILabel! {
        didSet {
            itemImageCreateLabel.text = "商品のイメージ"
            itemImageCreateLabel.font = .systemFont(ofSize: 17, weight: .medium)
            itemImageCreateLabel.textColor = UIColor.systemGray
        }
    }
    
    @IBOutlet weak var resultItemImageView: UIImageView! {
        didSet {
            resultItemImageView.image = UIImage(systemName: "photo.fill.on.rectangle.fill")?.withRenderingMode(.alwaysOriginal)
            resultItemImageView.tintColor = UIColor.systemGray.withAlphaComponent(0.7)
        }
    }
    
    @IBOutlet weak var itemImageCameraButton: UIButton! {
        didSet {
            itemImageCameraButton.layer.cornerRadius = 15
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func shootItemImage(_ sender: Any) {
        print("take a Item Image Photo")
        self.delegate?.takeImagePhotoScreen()
    }
    
    
}
