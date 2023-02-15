//
//  String+Utils.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/02/15.
//

import Foundation

// TODO: - ⚠️まだ途中の段階
extension String {
    func toDate() -> Date? {
        //"yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}
