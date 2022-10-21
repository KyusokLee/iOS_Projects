//
//  ItemListHeaderPageModel.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/10/20.
//

import Foundation
import UIKit

struct PageModel {
    var pages = [Page]()
    // defaultで0を設定
    var selectedPageIndex = 0
}

struct Page {
    var name = ""
    var viewController = UIViewController()
    
    init(with vc: UIViewController, viewName name: String) {
        self.viewController = vc
        self.name = name
    }
}
