//
//  EndPeriodImage.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/23.
//

import Foundation

// 賞味期限のtext json parsing
// ParsingするデータがendDateしかない

// MARK: - 今後, 商品の名前, 価格, 賞味期限といった３週類のpropertyを持つModelにする予定
// そのため、EndDateというモデル名前より、Itemという可読性のいいmodel名に変更する

struct EndDate: Codable {
    var endDate: String?
}

