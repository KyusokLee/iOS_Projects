//
//  UIButton_extension.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/10/07.
//

import Foundation
import UIKit

//// ⚠️こうすると、全てのUIButtonのtouch領域が増えることになる
//extension UIButton {
//    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        let margin: CGFloat = 100
//        let hitArea = self.bounds.insetBy(dx: -margin, dy: -margin)
//        return hitArea.contains(point)
//    }
//}
