//
//  CustomTabBar.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit

class CustomTabBar: UITabBar {
    
    private let buttonHeight: CGFloat = 60
    public var didTapButton: (() -> ())?
    public lazy var middleButton: UIButton! = {
        let addButton = UIButton()
        addButton.frame.size = CGSize(width: buttonHeight, height: buttonHeight)
        addButton.backgroundColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.5)
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        // insetを入れる
        addButton.largeContentImageInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        addButton.tintColor = .white
        
        addButton.contentMode = .scaleAspectFit
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.layer.cornerRadius = buttonHeight / 2
        
        self.addSubview(addButton)
        
        return addButton
    }()
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowColor = UIColor.systemGray5.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.4
        self.layer.masksToBounds = false
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        middleButton.center = CGPoint(x: self.frame.width / 2, y: -5)
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
