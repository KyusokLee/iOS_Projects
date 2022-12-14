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
            headerTitle.text = "賞味期限が近づいている商品"
            headerTitle.textColor = UIColor.black.withAlphaComponent(0.7)
            headerTitle.backgroundColor = UIColor.white
            headerTitle.font = .systemFont(ofSize: 17, weight: .bold)
        }
    }
    
    @IBOutlet weak var alarmSetButton: UIButton! {
        didSet {
            let btnImage = UIImage(systemName: "bell")?.withTintColor(UIColor(rgb: 0x81C784), renderingMode: .alwaysOriginal)
            
            alarmSetButton.setImage(btnImage, for: .normal)
        }
    }
    
    @IBOutlet weak var showMoreDetailButton: UIButton! {
        didSet {
            showMoreDetailButton.setTitle("もっと見る", for: .normal)
            showMoreDetailButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            showMoreDetailButton.setTitleColor(UIColor.systemGray2.withAlphaComponent(0.8), for: .normal)
            showMoreDetailButton.backgroundColor = UIColor.white
        }
    }
    
    // TODO: 1. もっと見るボタンを押すと、賞味期限が近づいている商品のみのリストを表示する
    // TODO: 2. 月ごとの管理ができるようにしたい
    
    
}
