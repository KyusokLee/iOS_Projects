//
//  showItemInfoDetailButton.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/10/07.
//

import UIKit

// MARK: - HomeViewControllerの'もっと見る'ボタンを押したあと、処理するButton
class showItemInfoDetailButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    // 今回は、コードではなく、buttonのUIを生成して使うことにしたので、required initに入ることになる
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    // このクラスを継承するUIButtonオブジェクトのみのbuttonのtouch領域を拡大させるために、pointをoverrideした。
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard super.point(inside: point, with: event) else {
            return false
        }
        print("pressed show more button!")
        // 全ての方向に20ほどタッチ領域を増やす
        // dx: x軸が設定したdxほど増加する (負数じゃないと増加しない)
        let margin: CGFloat = 20
        let touchArea = bounds.insetBy(dx: -margin, dy: -margin)
        return touchArea.contains(point)
    }

    func configure() {}
    func bind() {}
}
