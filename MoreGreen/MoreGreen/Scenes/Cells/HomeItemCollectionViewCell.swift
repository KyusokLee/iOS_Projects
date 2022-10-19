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
            itemImageView.backgroundColor = UIColor.systemGray5
        }
    }
    
    @IBOutlet weak var itemNameLabel: UILabel! {
        didSet {
            itemNameLabel.font = .systemFont(ofSize: 14, weight: .medium)
            itemNameLabel.textColor = UIColor.black.withAlphaComponent(0.7)
        }
    }
    
    @IBOutlet weak var itemDdayLabel: UILabel! {
        didSet {
            itemDdayLabel.font = .systemFont(ofSize: 14, weight: .medium)
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
        setCellLayout()
    }
    
    func setCellLayout() {
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.borderColor = UIColor.systemGray3.cgColor
        self.contentView.layer.borderWidth = 1
        // ここを、trueにすることで、CollectionView cell自体を丸くすることが可能
        self.contentView.clipsToBounds = true
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
        
        print("itemName: \(itemName)")
        print("day: \(dayDifference)")
        
        if image == Data() {
            itemImageView.image = nil
            itemImageView.backgroundColor = UIColor.systemGray5
            labelOnImage.isHidden = false
        } else {
            labelOnImage.isHidden = true
            itemImageView.backgroundColor = .clear
            itemImageView.image = UIImage(data: itemList.itemImage ?? Data())
        }
        
        itemNameLabel.text = itemName ?? "No Data"
        itemDdayLabel.text = "D - \(dayDifference)"
    }

}
