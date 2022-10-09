//
//  ItemCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/23.
//

import UIKit

// CellのUI処理logic
// MARK: 🔥一回処理を行なった後、UIはそのIBOutletのデータを保持することになる。
// そのため、全てのcaseについて、configure（cellのデータに合わせたimageやlabelのデータ変更）をしっかりと分岐しないと、データがおかしくなることがわかった。
// 例えば、このアプリだと、現在の日付が 2022/10/09だとすると、2022/10/27まで 18日ある
// この時、新しくデータを生成して、保存するときに日にちの処理を行なってあげないと、前に処理したIBOutletのデータが勝手にfetchされることになる。 ---> D-18ではなく　D + 3になっている

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
            itemEndDDay.text = "データなし"
            itemEndDDay.font = .systemFont(ofSize: 14, weight: .bold)
            itemEndDDay.textColor = UIColor.systemGray3.withAlphaComponent(0.7)
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
            itemEndPeriod.text = "データなし"
            itemEndPeriod.textColor = UIColor(rgb: 0x751717)
            itemEndPeriod.font = .systemFont(ofSize: 14, weight: .medium)
        }
        
        if !dateArray.isEmpty {
            fetchDayCount(dayArray: dateArray)
        } else {
            itemEndDDay.text = "データなし"
            itemEndDDay.textColor = UIColor.systemGray3.withAlphaComponent(0.7)
        }
        
        
    }
    
    // TODO: ⚠️DDayCountを行うメソッド
    private func fetchDayCount(dayArray array: [Int]) {
        guard array.count == 3 else {
            return
        }
        
        // endDate締切が今日であるとき
        if array[0] == 0 && array[1] == 0 && array[2] == 0 {
            itemEndDDay.text = "D - 0"
            itemEndDDay.textColor = UIColor.systemRed.withAlphaComponent(0.7)
        } else {
            if array[0] >= 1 {
                itemEndDDay.text = "D - 1年以上"
                itemEndDDay.textColor = UIColor(rgb: 0x36B700)
            } else {
                // 1年内の期間もしくは、過ぎた期間
                if array[0] == 0 {
                    // 1年内の期間
                    if array[1] >= 1 {
                        itemEndDDay.text = "D - 1ヶ月以上"
                        itemEndDDay.textColor = UIColor(rgb: 0x36B700)
                    } else if array[1] == 0 {
                        // もう過ぎているとき
                        if array[2] < 0 {
                            // 絶対値
                            let absInt = abs(array[2])
                            itemEndDDay.text = "D + \(absInt)"
                            itemEndDDay.textColor = UIColor.red
                        } else {
                            itemEndDDay.text = "D - \(array[2])"
                            itemEndDDay.textColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.7)
                        }
                    } else if array[1] < 0 {
                        itemEndDDay.text = "1ヶ月以上経過"
                        itemEndDDay.textColor = UIColor(rgb: 0x751717).withAlphaComponent(0.7)
                    }
                } else if array[0] < 0 {
                    // 1年以上過ぎた場合
                    itemEndDDay.text = "1年以上経過"
                    itemEndDDay.textColor = UIColor(rgb: 0x751717).withAlphaComponent(0.7)
                }
            }
            
//            // もう過ぎているとき
//            if array[2] < 0 {
//                // 絶対値
//                let absInt = abs(array[2])
//                itemEndDDay.text = "D + \(absInt)"
//                itemEndDDay.textColor = UIColor.red
//            }
        }
    }
    
    @IBAction func tabShowItemDetail(_ sender: Any) {
        print("detail Button Clicked")
        self.delegate?.showDetailItemInfo()
    }
    
}


