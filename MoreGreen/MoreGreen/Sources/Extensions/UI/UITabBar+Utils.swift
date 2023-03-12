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
}
