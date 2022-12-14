//
//  ItemCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/23.
//

import UIKit

// Cellã®UIå¦çlogic
// MARK: ð¥ä¸åå¦çãè¡ãªã£ãå¾ãUIã¯ãã®IBOutletã®ãã¼ã¿ãä¿æãããã¨ã«ãªãã
// ãã®ãããå¨ã¦ã®caseã«ã¤ãã¦ãconfigureï¼cellã®ãã¼ã¿ã«åãããimageãlabelã®ãã¼ã¿å¤æ´ï¼ããã£ããã¨åå²ããªãã¨ããã¼ã¿ããããããªããã¨ãããã£ãã
// ä¾ãã°ããã®ã¢ããªã ã¨ãç¾å¨ã®æ¥ä»ã 2022/10/09ã ã¨ããã¨ã2022/10/27ã¾ã§ 18æ¥ãã
// ãã®æãæ°ãããã¼ã¿ãçæãã¦ãä¿å­ããã¨ãã«æ¥ã«ã¡ã®å¦çãè¡ãªã£ã¦ãããªãã¨ãåã«å¦çããIBOutletã®ãã¼ã¿ãåæã«fetchããããã¨ã«ãªãã ---> D-18ã§ã¯ãªããD + 3ã«ãªã£ã¦ãã

// TODO: â ï¸ItemCellã®é¨åã§ãlayout Errorãçãã -> ä¿®æ­£äºå®

enum isShowed {
    case normal
    case showed
}

enum isPinned {
    case normal
    case pinned
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
            itemNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        }
    }
    
    @IBOutlet weak var pinImage: UIImageView! {
        didSet {
            pinImage.backgroundColor = .clear
            
            let image = UIImage(systemName: "pin")?.withTintColor(UIColor.systemGray3, renderingMode: .alwaysOriginal)
            
            pinImage.image = image
            
            if pinState == .normal {
                pinImage.isHidden = true
            } else {
                pinImage.isHidden = false
            }
        }
    }
    
    
    @IBOutlet weak var dateTitle: UILabel! {
        didSet {
            dateTitle.text = "è³å³æé:"
            dateTitle.font = .systemFont(ofSize: 14, weight: .medium)
            dateTitle.textColor = UIColor.black
        }
    }
    
    
    @IBOutlet weak var itemEndPeriod: UILabel! {
        didSet {
            itemEndPeriod.text = "ãã¼ã¿ãªã"
            itemEndPeriod.textColor = UIColor(rgb: 0x751717)
            itemEndPeriod.font = .systemFont(ofSize: 14, weight: .medium)
            
        }
    }
    
    @IBOutlet weak var itemEndDDay: UILabel! {
        didSet {
            itemEndDDay.text = "ãã¼ã¿ãªã"
            itemEndDDay.font = .systemFont(ofSize: 14, weight: .bold)
            itemEndDDay.textColor = UIColor.systemGray3.withAlphaComponent(0.7)
        }
    }
    
    // customButtonã classç¶æ¿ãããã¨ã«ããbutton ã®touché åãå¢ããã6666
    @IBOutlet weak var showDetailButton: UIButton! {
        didSet {
            let buttonImage = UIImage(systemName: "chevron.down.square")?.withTintColor(UIColor(rgb: 0x81C784), renderingMode: .alwaysOriginal)
            
            showDetailButton.setImage(buttonImage, for: .normal)
        }
    }
    
    var calendar = Calendar.current
    var currentDate = Date()
    var detailButtonState: isShowed = .normal
    var pinState: isPinned = .normal
    var dayCountArray = [Int]()
    var dDayText = ""
    weak var delegate: ItemCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // cellã®configure
    func configure(with imageData: Data, hasItemName itemName: String, hasDate endDate: String, dayCount dateArray: [Int]) {
        
        print(pinState)
        if itemName == "" {
            itemNameLabel.text = "ãã¼ã¿ãªã"
            itemNameLabel.textColor = UIColor.systemGray.withAlphaComponent(0.7)
        } else {
            itemNameLabel.text = itemName
            itemNameLabel.textColor = UIColor.black
        }
        
        // ãã ã®Data()ã®ã¾ã¾ (åçã®ã¤ã¡ã¼ã¸ããªããã®)
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
            itemEndPeriod.text = "ãã¼ã¿ãªã"
            itemEndPeriod.textColor = UIColor(rgb: 0x751717)
            itemEndPeriod.font = .systemFont(ofSize: 14, weight: .medium)
        }
        
        if !dateArray.isEmpty {
            fetchDayCount(dayArray: dateArray)
        } else {
            itemEndDDay.text = "ãã¼ã¿ãªã"
            itemEndDDay.textColor = UIColor.systemGray3.withAlphaComponent(0.7)
        }
        
        
    }
    
    // TODO: â ï¸DDayCountãè¡ãã¡ã½ãã
    private func fetchDayCount(dayArray array: [Int]) {
        guard array.count == 3 else {
            return
        }
        
        // endDateç· åãä»æ¥ã§ããã¨ã
        if array[0] == 0 && array[1] == 0 && array[2] == 0 {
            itemEndDDay.text = "D - 0"
            itemEndDDay.textColor = UIColor.systemRed.withAlphaComponent(0.7)
        } else {
            if array[0] >= 1 {
                itemEndDDay.text = "D - 1å¹´ä»¥ä¸"
                itemEndDDay.textColor = UIColor(rgb: 0x36B700)
            } else {
                // 1å¹´åã®æéãããã¯ãéããæé
                if array[0] == 0 {
                    // 1å¹´åã®æé
                    if array[1] >= 1 {
                        itemEndDDay.text = "D - 1ã¶æä»¥ä¸"
                        itemEndDDay.textColor = UIColor(rgb: 0x36B700)
                    } else if array[1] == 0 {
                        // ããéãã¦ããã¨ã
                        if array[2] < 0 {
                            // çµ¶å¯¾å¤
                            let absInt = abs(array[2])
                            itemEndDDay.text = "D + \(absInt)"
                            itemEndDDay.textColor = UIColor.red
                        } else {
                            itemEndDDay.text = "D - \(array[2])"
                            itemEndDDay.textColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.7)
                        }
                    } else if array[1] < 0 {
                        itemEndDDay.text = "1ã¶æä»¥ä¸çµé"
                        itemEndDDay.textColor = UIColor(rgb: 0x751717).withAlphaComponent(0.7)
                    }
                } else if array[0] < 0 {
                    // 1å¹´ä»¥ä¸éããå ´å
                    itemEndDDay.text = "1å¹´ä»¥ä¸çµé"
                    itemEndDDay.textColor = UIColor(rgb: 0x751717).withAlphaComponent(0.7)
                }
            }
        }
    }
    
    @IBAction func tabShowItemDetail(_ sender: Any) {
        print("detail Button Clicked")
        self.delegate?.showDetailItemInfo()
    }
    
}


