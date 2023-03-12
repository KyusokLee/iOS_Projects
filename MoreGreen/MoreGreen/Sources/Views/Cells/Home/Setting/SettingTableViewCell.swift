//
//  SettingTableViewCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/12.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var chevronImageView: UIImageView! {
        didSet {
            let image = UIImage(systemName: "chevron.right")?.withTintColor(
                UIColor.systemGray.withAlphaComponent(0.3),
                renderingMode: .alwaysOriginal
            )
            chevronImageView.image = image
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
    
    // cellの特性をここでリンクさせる
    func configure() {
        
    }
    
}
