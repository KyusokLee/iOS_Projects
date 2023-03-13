//
//  AnimationTime.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/11.
//

import Foundation

enum AnimationTime {
    //相対的なstart時間とdurationを設ける
    typealias KeyFrameAnimationTime = (relativeStartTime: Double, relativeDuration: Double)
    
    // start時間とduration(animationが続く時間)
    static let duration: TimeInterval = 2.0
    static let firstAnimation: KeyFrameAnimationTime = (0.0 / 4.0, 1.0 / 4.0)
    static let secondAnimation: KeyFrameAnimationTime = (1.0 / 4.0, 1.0 / 4.0)
    static let thirdAnimation: KeyFrameAnimationTime = (2.0 / 4.0, 1.0 / 4.0)
    static let forthAnimation: KeyFrameAnimationTime = (3.0 / 4.0, 1.0 / 4.0)
}
