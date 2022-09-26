//
//  HomeCardViewCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/24.
//

import UIKit

class HomeCardViewCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView! {
        didSet {
            cardView.layer.masksToBounds = true
            cardView.backgroundColor = UIColor(rgb: 0x81C784)
            cardView.layer.cornerRadius = 20
        }
    }
    
    @IBOutlet weak var cardImageView: UIImageView! {
        didSet {
            cardImageView.image = UIImage(named: "120")
            cardImageView.layer.cornerRadius = cardImageView.bounds.height / 2
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
