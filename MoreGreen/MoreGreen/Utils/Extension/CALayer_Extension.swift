//
//  CALayer_Extension.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/10/18.
//

import Foundation
import UIKit

extension CALayer {
    func addBorder(arrEdges: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arrEdges {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            
            border.backgroundColor = color.cgColor
            self.addSublayer(border)
        }
    }
}
