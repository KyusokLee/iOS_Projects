//
//  EndPeriodCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/24.
//

import UIKit

protocol EndPeriodCellDelegate {
    func takeEndPeriodScreen()
}

class EndPeriodCell: UITableViewCell {
    
    @IBOutlet weak var endPeriodtitleLabel: UILabel! {
        didSet {
            endPeriodtitleLabel.text = "賞味期限"
            endPeriodtitleLabel.textColor = UIColor.systemGray
            endPeriodtitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet weak var endPeriodDataLabel: UILabel! {
        didSet {
            endPeriodDataLabel.font = .systemFont(ofSize: 17, weight: .bold)
        }
    }
    
    @IBOutlet weak var endPeriodShootButton: UIButton! {
        didSet {
            endPeriodShootButton.setTitle("賞味期限の写真を撮る", for: .normal)
            endPeriodShootButton.tintColor = UIColor.white
            endPeriodShootButton.backgroundColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.5)
            endPeriodShootButton.layer.cornerRadius = endPeriodShootButton.frame.height / 2
            
        }
    }
    
    var delegate: EndPeriodCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func shootEndPeriod(_ sender: Any) {
        // カメラを撮りますかの写真がでるように
        print("take a endPeriod image text ocr")
        self.delegate?.takeEndPeriodScreen()
    }
    
    
    private func configure() {
        
    }
    
}
