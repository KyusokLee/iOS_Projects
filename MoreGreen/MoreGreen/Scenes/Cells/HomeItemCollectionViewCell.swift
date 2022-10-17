//
//  HomeItemCollectionViewCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/10/16.
//

import UIKit

class HomeItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var itemDdayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCellLayout() {
        self.layer.cornerRadius = 8
        self.clipsToBounds = false
    }
    
    func configure(userDate itemList: ItemList) {
        itemImageView.image = UIImage(data: itemList.itemImage ?? Data())
        itemNameLabel.text = itemList.itemName ?? "No Data"
        itemDdayLabel.text = itemList.endDate ?? "No Data"
    }

}
