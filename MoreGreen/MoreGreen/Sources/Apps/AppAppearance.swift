//
//  AppAppearance.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/05.
//

import UIKit

// アプリの共通している部分は、AppAppearanceを設けて、別途に使うと効率的であると考える
final class AppAppearance {
    static func setAppearance() {
        UIBarButtonItem.appearance().tintColor = .label
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.label]
    }
}
