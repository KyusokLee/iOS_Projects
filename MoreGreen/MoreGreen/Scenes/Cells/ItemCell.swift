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
    
    @IBOutlet weak var itemImageView: UIImageView! {
        didSet {
            itemImageView.layer.masksToBounds = true
            itemImageView.layer.cornerRadius = 8
            itemImageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var labelOnImage: UILabel! {
        didSet {
            labelOnImage.text = "No Image"
            labelOnImage.font = .systemFont(ofSize: 11, weight: .bold)
            labelOnImage.textColor = UIColor.white
        }
    }
    
    
    @IBOutlet weak var itemNameLabel: UILabel! {
        didSet {
            itemNameLabel.text = "データなし"
            itemNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        }
    }
    
    @IBOutlet weak var dateTitle: UILabel! {
        didSet {
            dateTitle.text = "賞味期限:"
            dateTitle.font = .systemFont(ofSize: 14, weight: .medium)
            dateTitle.textColor = UIColor.black
        }
    }
    
    
    @IBOutlet weak var itemEndPeriod: UILabel! {
        didSet {
            itemEndPeriod.text = "データなし"
            itemEndPeriod.textColor = UIColor(rgb: 0x751717)
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
    
    var calendar = Calendar.current
    var currentDate = Date()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // cellのconfigure
    func configure(with imageData: Data, hasDate endDate: String) {
        // ただのData()のまま (写真のイメージがないもの)
        if imageData == Data() {
            itemImageView.image = nil
            itemImageView.backgroundColor = UIColor.systemGray5
            labelOnImage.isHidden = false
        } else {
            itemImageView.backgroundColor = .clear
            labelOnImage.isHidden = true
            let hasImage = UIImage(data: imageData)
            itemImageView.image = hasImage!
        }
        
        if endDate != "" {
            itemEndPeriod.text = endDate
            itemEndPeriod.textColor = UIColor.black.withAlphaComponent(0.8)
        } else {
            return
        }
        
        
    }
    
//    func setDateFormat() {
//        if let dateString = 
//        let dateFormatter = DateFormatter()
//        var daysCount: Int = 0
//        
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        dateFormatter.date(f)
//        
//        
//    }
    
    
    @IBAction func showDetailItemInfo(_ sender: Any) {
        print("button click")
    }
}
