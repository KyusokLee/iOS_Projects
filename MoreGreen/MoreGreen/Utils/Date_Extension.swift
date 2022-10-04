//
//  Date_Extension.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/10/03.
//

import Foundation


// 日付を比較し、D-dayを表す
extension Date {
    public func dateCompare(fromDate: Date) -> String {
        var dDayDateMessage: String = ""
        let result: ComparisonResult = self.compare(fromDate)
        
        
        
        
        return dDayDateMessage
    }
}

// ⚠️まだ途中の段階
extension String {
    func toDate() -> Date? { //"yyyy-MM-dd HH:mm:ss"
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

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
}
