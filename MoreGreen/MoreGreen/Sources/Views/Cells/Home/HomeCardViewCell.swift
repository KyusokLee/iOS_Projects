//
//  HomeCardViewCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/24.
//

import UIKit

// TODO: ⚠️ここのlayoutで警告が出てる
// MARK: - ここのcardViewをFilpCardViewに変えるつもり -> その中に、imageViewとlabelなども入れるつもり
// Nibファイルを使わずに、customizeしたViewをCellに格納したい
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
            cardImageView.contentMode = .scaleAspectFill
            cardImageView.image = UIImage(named: "120")
            cardImageView.layer.masksToBounds = true
            cardImageView.layer.cornerRadius = cardImageView.bounds.height / 2
        }
    }
    @IBOutlet weak var cardTitleLabel: UILabel!
    @IBOutlet weak var cardWelcomeLabel: UILabel!
    @IBOutlet weak var cardUserNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layoutIfNeeded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
