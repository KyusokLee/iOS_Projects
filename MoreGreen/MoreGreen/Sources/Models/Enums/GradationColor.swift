//
//  GradiationColor.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/05/14.
//

import Foundation
import UIKit

// MARK: - TabBarControllerのaddButtonの色をgradiation効果を与えて、animateさせるための設定
enum GradationColor {
    // gradient: 変化の度合いを意味するので、このように命名
    static var gradientColors = [
        UIColor(rgb: 0x36B700).withAlphaComponent(0.65),
        UIColor(rgb: 0x36B700).withAlphaComponent(0.4),
        UIColor(rgb: 0x2196F3).withAlphaComponent(0.3),
        UIColor(rgb: 0x2196F3).withAlphaComponent(0.65),
        UIColor(rgb: 0x2196F3).withAlphaComponent(0.3),
        UIColor(rgb: 0x36B700).withAlphaComponent(0.4),
        UIColor(rgb: 0x36B700).withAlphaComponent(0.65)
    ]
}

// NSNumber -> scalar numeric valueに変える
enum GradientConstants {
    static let gradientLocation = [Int](0..<GradationColor.gradientColors.count)
        .map { NSNumber(value: Double($0)) }
}
