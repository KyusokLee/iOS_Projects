//
//  UITabBar_extension.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/23.
//

import Foundation
import UIKit

extension UITabBar {
    //　基本のshadowStyleを初期化しないと、custom styleが反映されない
    static func clearShadow() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    // TabBarのitemにbadgeを追加する
    func addBadge(index:Int) {
        if let tabItems = self.items {
            let tabItem = tabItems[index]
            tabItem.badgeValue = "●"
            tabItem.badgeColor = .clear
            tabItem.setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
        }
    }
    
    // TabBarのitemのbadgeを消す
    func removeBadge(index:Int) {
        if let tabItems = self.items {
            let tabItem = tabItems[index]
            tabItem.badgeValue = nil
        }
    }
}
