//
//  ItemCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/23.
//

import UIKit

enum isShowed {
    case normal
    case showed
}

class ItemCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var itemNameLabel: UILabel! {
        didSet {
            itemNameLabel.text = "データなし"
            itemNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        }
    }
    
    @IBOutlet weak var itemEndPeriod: UILabel! {
        didSet {
            itemEndPeriod.text = "賞味期限: "
            itemEndPeriod.font = .systemFont(ofSize: 14, weight: .medium)
        }
    }
    
    @IBOutlet weak var itemEndDDay: UILabel! {
        didSet {
            itemEndDDay.text = "D - "
            itemEndDDay.font = .systemFont(ofSize: 14, weight: .bold)
        }
    }
    
    @IBOutlet weak var showDetailButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure() {
        
        
        
    }
    
    
    @IBAction func showDetailItemInfo(_ sender: Any) {
        print("button click")
    }
}
