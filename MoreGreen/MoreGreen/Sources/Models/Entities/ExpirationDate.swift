//
//  EndPeriodImage.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/23.
//

import Foundation

// 賞味期限のモデル確立
// MARK: - 今後, 商品の名前, 価格, 賞味期限といった３週類のpropertyを持つModelにする予定
// Vision Frameworkを使うので、Parsing処理はいらない
// そのため、ExpirationDateというモデル名前より、Itemという可読性のいいmodel名に変更する

struct ExpirationDate {
    var expirationEndDate: String?
}

