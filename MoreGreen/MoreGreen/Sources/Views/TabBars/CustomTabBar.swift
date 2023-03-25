//
//  CustomTabBar.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit
// 使わないコード
// Tabbarのmiddle Buttonのtouch領域拡大とbuttonのanimation効果を実装するために
// 後、高さも違くするために
// 方法1. Tabbarを継承するsubClassを作成して、customizeする
// 方法2. UITabbarをextensionする
class CustomTabBar: UITabBar {
    
    private let buttonHeight: CGFloat = 60
    private let middleButton = UIButton()
    
    //MARK: - Variables
    public var didTapButton: (() -> ())?
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowColor = UIColor.systemGray5.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.4
        self.layer.masksToBounds = false
        setUpMiddleButton()
        setMiddleButtonConstraints()
    }
    
    // Tabbarの高さを設定する方法
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 100
        return sizeThatFits
    }
    
    // ⚠️ここのコードは、まだ100%理解できてない
    // TabBar からはみ出た部分もタップが反応するようにするためのコード
    // TabBar の範囲外でも中央ボタン上のタップ座標である場合は true を返すことで、ボタンの反応が効くようになる
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let convertedPoint = middleButton.convert(point, to: self)
        
        // 中央ボタンが円の場合
        if UIBezierPath(ovalIn: middleButton.bounds).contains(convertedPoint) {
            return true
        }
        
        return super.point(inside: point, with: event)
    }
    
    private func setUpMiddleButton() {
        middleButton.backgroundColor = UIColor(rgb: 0x36B700).withAlphaComponent(1)
        middleButton.setImage(UIImage(systemName: "plus"), for: .normal)
        middleButton.tintColor = .white
        middleButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        self.addSubview(middleButton)
    }
    
    private func setMiddleButtonConstraints() {
        middleButton.translatesAutoresizingMaskIntoConstraints = false
        middleButton.widthAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        middleButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        middleButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        let heightDifference = (frame.height / 2) - buttonHeight / 2
        middleButton.topAnchor.constraint(equalTo: self.topAnchor, constant: heightDifference).isActive = true
    }
    
    @objc func addButtonAction(sender: UIButton) {
        didTapButton?()
    }
    
    // HitTest
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        return self.middleButton.frame.contains(point) ? self.middleButton : super.hitTest(point, with: event)
    }
}


//middleButton.frame.size = CGSize(width: buttonHeight, height: buttonHeight)
//        middleButton.backgroundColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.5)
//        middleButton.setImage(UIImage(systemName: "plus"), for: .normal)
//        // insetを入れる
//        middleButton.largeContentImageInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
//        middleButton.tintColor = .white
//
//        middleButton.contentMode = .scaleAspectFit
//        middleButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
//        middleButton.translatesAutoresizingMaskIntoConstraints = false
//        middleButton.layer.cornerRadius = buttonHeight / 2
