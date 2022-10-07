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

protocol ItemCellDelegate: AnyObject {
    func showDetailItemInfo()
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
    
    // customButtonを class継承することにし、button のtouch領域を増やした6666
    @IBOutlet weak var showDetailButton: UIButton! {
        didSet {
            let buttonImage = UIImage(systemName: "chevron.down.square")?.withTintColor(UIColor(rgb: 0x81C784), renderingMode: .alwaysOriginal)
            
            showDetailButton.setImage(buttonImage, for: .normal)
        }
    }
    
    var calendar = Calendar.current
    var currentDate = Date()
    var detailButtonState: isShowed = .normal
    var dayCountArray = [Int]()
    weak var delegate: ItemCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // cellのconfigure
    func configure(with imageData: Data, hasDate endDate: String, dayCount dateArray: [Int]) {
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
        
        if !dateArray.isEmpty {
            
        } else {
            itemEndDDay.text = "データなし"
            itemEndDDay.textColor = UIColor.systemGray3.withAlphaComponent(0.7)
        }
        
        
    }
    
    private func fetchDayCount(dayArray array: [Int]) {
        
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
    
    @IBAction func tabShowItemDetail(_ sender: Any) {
        print("detail Button Clicked")
        self.delegate?.showDetailItemInfo()
    }
    
}


