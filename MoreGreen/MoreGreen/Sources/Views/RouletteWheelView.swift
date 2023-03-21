//
//  RouletteWheelView.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/20.
//

import UIKit

final class RouletteWheelView: UIView {
    var rotationAngle: CGFloat = 0.0 {
        didSet {
            self.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
    }
    var lastRotation: CGFloat = 0
    var items: [UIView] = []
        
    func add(item: UIView) {
        items.append(item)
        addSubview(item)
    }
    
//    // Rouletteに追加する項目を配列で入れる
//    let items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.layer.borderColor = UIColor.green.cgColor
        self.layer.borderWidth = 3
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
        self.isUserInteractionEnabled = true
        addItems()
        addRotationGesture()
    }
        
    required init?(coder: NSCoder) {
        fatalError("RouletteWheelView doesn't use Nib file.")
    }
    
    override func layoutSubviews() {
            super.layoutSubviews()
            
            let itemAngle = 2 * .pi / CGFloat(items.count)
            let radius = min(bounds.width, bounds.height) / 2 - 20
            
            for (index, item) in items.enumerated() {
                let angle = CGFloat(index) * itemAngle
                let x = radius * cos(angle - .pi / 2)
                let y = radius * sin(angle - .pi / 2)
                item.center = CGPoint(x: bounds.midX + x, y: bounds.midY + y)
                item.transform = CGAffineTransform(rotationAngle: angle)
            }
        }
    
    // Rouletteにitemを追加する
    // Labelが正しく格納されない
    func addItems() {
        // Rouletteにitemを追加する
        let radius: CGFloat = 80.0 // rouletteの半径
        let itemAngle = CGFloat.pi * 2.0 / CGFloat(items.count) // 項目１個当たりの角度
        for (index, item) in items.enumerated() {
            let label = UILabel()
            label.text = item
            label.textAlignment = .center
            label.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
            label.center = CGPoint(
                x: radius * cos(itemAngle * CGFloat(index)),
                y: radius * sin(itemAngle * CGFloat(index))
            )
            
            self.addSubview(label)
        }
    }
    
    func addRotationGesture() {
        // rotateGestureは、指２本で回転させるgestureなので、panGestureが適切であると判断した
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didSpinRouletteView))
        panGesture.minimumNumberOfTouches = 1
        self.addGestureRecognizer(panGesture)
    }
    
    // MARK: - これは、ただのtapによる回転となる
    // -> 指先で回転させるようなanimationを与えたい
    @objc func didSpinRouletteView(_ sender: UIPanGestureRecognizer) {
        let rotation = CGAffineTransform(rotationAngle: sender.)
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0.0,
            options: .curveLinear,
            animations: {
                sender.view?.transform = (sender.view?.transform.rotated(by: CGFloat(Double.pi / 2)))!
            },
            completion: nil
        )
        
        switch sender.state {
        case .began:
            lastRotation = self.transform.rotationAngle
        case .changed:
            self.transform = CGAffineTransform(rotationAngle: lastRotation + rotation)
        case .ended:
            let itemAngle = 2 * .pi / CGFloat(self.items.count)
            let index = Int((self.transform.rotationAngle / itemAngle).rounded())
            let targetRotation = CGFloat(index) * itemAngle
                    
            let animator = UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.7) {
                self.transform = CGAffineTransform(rotationAngle: targetRotation)
            }animator.addCompletion { _ in
                self.performVibration()
            }
            animator.startAnimation()
        default:
            break
        }
    }
    
    func performVibration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func startRotating() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat.pi * 2.0 + self.rotationAngle
        rotationAnimation.duration = 2.0
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
        
    func stopRotating() {
        if let presentationLayer = self.layer.presentation(),
           let animation = presentationLayer.animation(forKey: "rotationAnimation") {
            print(animation)
            self.layer.removeAnimation(forKey: "rotationAnimation")
            // vibrate効果を与える
            self.vibrate()
                
            // 止まった角度を計算する
            let itemAngle = CGFloat.pi * 2.0 / CGFloat(self.items.count)
            let itemIndex = Int((self.rotationAngle + CGFloat.pi) / itemAngle) % self.items.count
            let selectedItem = self.items[itemIndex]
            print("Selected Item: \(selectedItem)")
        }
    }
    
    // 回転するとき、バイブレーション効果を与える
    func vibrate() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: self.center.x - 5.0, y: self.center.y)
        animation.toValue = CGPoint(x: self.center.x + 5.0, y: self.center.y)
        self.layer.add(animation, forKey: "position")
    }
}
