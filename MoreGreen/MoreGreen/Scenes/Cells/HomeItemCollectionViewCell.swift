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
            itemImageView.layer.cornerRadius = 8
            
            itemImageView.contentMode = .scaleAspectFill
            itemImageView.backgroundColor = UIColor.systemGray5
        }
    }
    
    @IBOutlet weak var itemNameLabel: UILabel! {
        didSet {
            itemNameLabel.font = .systemFont(ofSize: 14, weight: .bold)
            itemNameLabel.textColor = UIColor.black.withAlphaComponent(0.7)
        }
    }
    
    @IBOutlet weak var itemDdayLabel: UILabel! {
        didSet {
            itemDdayLabel.font = .systemFont(ofSize: 14, weight: .bold)
            itemDdayLabel.textColor = UIColor(rgb: 0x36B700)
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
        // Nibファイルが準備できたら、呼び出されるため、ここでcellのborderなどの枠を生成する
        setCellLayout()
    }
    
    func setCellLayout() {
        self.layer.cornerRadius = 8
        // ここを、trueにすることで、CollectionView cell自体を丸くすることが可能
        self.clipsToBounds = true
    }
    
    //　cell の中にあるviewのlayoutを調整する
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
    }
    
    // ここのconfigureを通して、collection View Cellをfetchする
    func configure(userData itemList: ItemList, dayDifference day: Int) {
        let image = itemList.itemImage
        let itemName = itemList.itemName
        let dayDifference = day
        
        if image == Data() {
            itemImageView.image = nil
            itemImageView.backgroundColor = UIColor.systemGray5
            labelOnImage.isHidden = false
        } else {
            labelOnImage.isHidden = true
            itemImageView.backgroundColor = .clear
            itemImageView.image = UIImage(data: itemList.itemImage ?? Data())
        }
        
        if dayDifference == 0 {
            itemDdayLabel.textColor = UIColor.systemRed.withAlphaComponent(0.7)
        } else if 1 <= dayDifference && dayDifference <= 3 {
            itemDdayLabel.textColor = UIColor(rgb: 0xFF9800).withAlphaComponent(0.7)
        } else {
            itemDdayLabel.textColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.7)
        }
        
        if itemName == nil {
            itemNameLabel.textColor = UIColor.systemGray3.withAlphaComponent(0.7)
        } else {
            itemNameLabel.textColor = UIColor.black.withAlphaComponent(0.7)
        }
        
        itemNameLabel.text = itemName ?? "No Data"
        itemDdayLabel.text = "D - \(dayDifference)"
        
        self.layoutIfNeeded()
    }

}
