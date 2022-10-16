//
//  HomeCustomHeader.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/10/16.
//

import UIKit

// HomeVCで使うcustom Header
// 目的: 今週、賞味期限が切れるitemだけをHomeVCで表示させる

final class HomeCustomHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var headerTitle: UILabel! {
        didSet {
            headerTitle.text = "今週中、賞味期限が切れる商品リスト"
            headerTitle.textColor = UIColor.black.withAlphaComponent(0.7)
        }
    }
    
}
