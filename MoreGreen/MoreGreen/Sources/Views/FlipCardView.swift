//
//  FlipCardView.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/21.
//

import UIKit

// CardViewの実装練習
class CardView: UIView {
    
    // Flipしたかのstateを保存
    private var flipped = false
    private var angle: Double = 0.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("FlipCardView doesn't use Nib file.")
    }

    private func setUpGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        addGestureRecognizer(tapGesture)
    }

    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        UIView.transition(
            with: self,
            duration: 0.5,
            options: .transitionFlipFromLeft,
            animations: {
                if self.angle == 180 {
                    self.angle = 0
                    self.flipped = false
                } else {
                    self.angle = 180
                    self.flipped = true
                }
            },
            completion: nil
        )
    }

}
//위 코드에서 setupGesture() 메서드에서 UITapGestureRecognizer 객체를 생성하고, addGestureRecognizer(_:) 메서드를 사용하여 뷰에 제스처를 등록합니다. 제스처가 감지되면 handleTapGesture(_:) 메서드가 호출되고, UIView.transition(with:duration:options:animations:completion:) 메서드를 사용하여 카드 뷰를 회전시킵니다. UIView.transition() 메서드는 애니메이션을 처리할 수 있는 여러 가지 옵션을 제공합니다. 위 코드에서는 transitionFlipFromLeft 옵션을 사용하여 가로축을 중심으로 회전합니다.
//
//이제 CardView 객체를 만들고, 적절한 위치에 추가하여 테스트하면 됩니다. 예를 들어, 다음과 같이 viewDidLoad() 메서드에서 CardView 객체를 생성하고, 뷰에 추가할 수 있습니다.
//

//class HomeCardViewController: UIViewController {
//
//    private var flipped = false
//    private var angle = 0.0
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let flipView = FlipView(frontView: frontView(),
//                                backView: backView(),
//                                axis: .vertical,
//                                flipped: flipped,
//                                angle: angle)
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        flipView.addGestureRecognizer(tapGesture)
//
//        view.addSubview(flipView)
//        NSLayoutConstraint.activate([
//            flipView.topAnchor.constraint(equalTo: view.topAnchor),
//            flipView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            flipView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            flipView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])
//    }
//
//    @objc private func handleTap() {
//        UIView.animate(withDuration: 1.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
//            if self.angle == 180 {
//                self.angle = 0
//            } else {
//                self.angle = 180
//            }
//        }, completion: nil)
//    }
//
//    private func frontView() -> UIView {
//        let frontView = FrontCardView()
//        frontView.card()
//        return frontView
//    }
//
//    private func backView() -> UIView {
//        let backView = BackCardView()
//        backView.card()
//        return backView
//    }
//}
//
//extension UIView {
//    func card() {
//        layer.cornerRadius = 16
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.2
//        layer.shadowOffset = CGSize(width: 0, height: 2)
//        layer.shadowRadius = 2
//    }
//}
//
//class FlipView: UIView {
//
//    private let frontView: UIView
//    private let backView: UIView
//    private let axis: Axis
//    private let flipped: Bool
//    private let angle: Double
//
//    enum Axis {
//        case horizontal
//        case vertical
//    }
//
//    init(frontView: UIView, backView: UIView, axis: Axis, flipped: Bool, angle: Double) {
//        self.frontView = frontView
//        self.backView = backView
//        self.axis = axis
//        self.flipped = flipped
//        self.angle = angle
//        super.init(frame: .zero)
//        addSubview(frontView)
//        addSubview(backView)
//        setupConstraints()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setupConstraints() {
//        frontView.translatesAutoresizingMaskIntoConstraints = false
//        backView.translatesAutoresizingMaskIntoConstraints = false
//
//        switch axis {
//        case .horizontal:
//            NSLayoutConstraint.activate([
//                frontView.topAnchor.constraint(equalTo: topAnchor),
//                frontView.leadingAnchor.constraint(equalTo: leadingAnchor),
//                frontView.bottomAnchor.constraint(equalTo: bottomAnchor),
//                frontView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
//
//                backView.topAnchor.constraint(equalTo: topAnchor),
//                backView.trailingAnchor.constraint(equalTo: trailingAnchor),
//                backView.bottomAnchor.constraint(equalTo: bottomAnchor),
//                backView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
//            ])
//
//            if flipped {
//                frontView.isHidden = true
//                backView.isHidden = false
//                let radians = CGFloat(angle * Double.pi / 180.0)
//                backView.transform = CGAffineTransform(rotationAngle: radians).scaledBy(x: -1, y: 1)
//            } else {
//                frontView.isHidden = false
//                backView.isHidden = true
//                let radians = CGFloat(angle * Double.pi / 180.0)
//                front
//
//
