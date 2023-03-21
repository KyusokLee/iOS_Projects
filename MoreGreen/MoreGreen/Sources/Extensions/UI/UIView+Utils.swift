//
//  UIView+Utils.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/21.
//

import UIKit

extension UIView {
    // ViewをCardの形にする
    func card() -> UIView {
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.7
        self.layer.shadowRadius = 4
        return self
    }
}
