//
//  HomeItemCollectionViewCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/10/16.
//

import UIKit

class HomeItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView! {
        didSet {
            itemImageView.contentMode = .scaleAspectFill
            itemImageView.image = nil
            itemImageView.backgroundColor = UIColor.systemGray5
        }
    }
    
    @IBOutlet weak var itemNameLabel: UILabel! {
        didSet {
            itemNameLabel.textColor = UIColor.black.withAlphaComponent(0.7)
        }
    }
    
    @IBOutlet weak var itemDdayLabel: UILabel! {
        didSet {
            itemDdayLabel.textColor = UIColor.black.withAlphaComponent(0.7)
        }
    }
    
    @IBOutlet weak var labelOnImage: UILabel! {
        didSet {
            labelOnImage.text = "No Image"
            labelOnImage.font = .systemFont(ofSize: 14, weight: .bold)
            labelOnImage.textColor = UIColor.white
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setCellLayout()
    }
    
    func setCellLayout() {
        self.contentView.layer.cornerRadius = 8
        // ここを、trueにすることで、CollectionView cell自体を丸くすることが可能
        self.contentView.clipsToBounds = true
    }
    
    //　cell の中にあるviewのlayoutを調整する
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
    }
    
    // ここのconfigureを通して、collection View Cellをfetchする
    func configure(userDate itemList: ItemList) {
        
        if itemList.itemImage == Data() {
            itemImageView.image = nil
            itemImageView.backgroundColor = UIColor.systemGray5
            labelOnImage.isHidden = false
        } else {
            itemImageView.image = UIImage(data: itemList.itemImage ?? Data())
            itemNameLabel.text = itemList.itemName ?? "No Data"
            itemDdayLabel.text = itemList.endDate ?? "No Data"
        }
    }

}
