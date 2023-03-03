//
//  Date_Extension.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/10/03.
//

import Foundation

extension Date {
    // Date型の日付をString型に変換する
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
}
