//
//  CameraGuideView.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/05.
//

import UIKit

final class CameraGuideView: UIView {
    // 背景のview
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
     }()
    
    // TODO: ⚠️前のviewを今後、2つにしたい
    private let foregroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 文字を表示させる
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "商品の賞味期限が映るようにしてください"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // imageViewでimageを動かせる
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "viewfinder")?
            .withTintColor(UIColor.systemGreen, renderingMode: .alwaysTemplate)
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
     
    var isShowing = false {
        didSet {
            self.isHidden = !self.isShowing
            // animation効果を与えたいので、alphaでisHiddenと同様な処理をする
            if self.isShowing {
                UIView.animate(withDuration: 0.35) {
                    self.foregroundView.alpha = 1.0
                }
                self.startMoveImageUpAndDown(duration: 0.8)
            } else {
                self.foregroundView.alpha = 0.0
                // Error: CamareViewControllerで ボタンをtapすると、animateが再動作しない
                // 理由: UIView.animateで一回animateで動かしたものは、stopしない限り、このpropertyによる再動作はしないことが原因だった
                // 解決: animateのtargetとしたUIのlayerでremoveAllAnimations()をすることで、animationの初期化ができる
                self.stopMoveImageUpAndDown()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.backgroundView)
        self.addTapgesture()
        self.foregroundView.addSubview(self.titleLabel)
        self.foregroundView.addSubview(self.imageView)
        self.addSubview(self.foregroundView)
        
        self.setBackgroundViewConstraints()
        self.setForegroundViewConstraints()
        self.setTitleLabelConstraints()
        self.setImageViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("CameraGuideView doesn't use Nib file.")
    }
    
    private func addTapgesture() {
        // Error: self.backgroundViewにすると、unrecognized selector sent to instance 0x10178c010'のようなエラーが生じる
        // 解決: -> self.backgroundViewからviewに変えることで解決した
        // 理由: backgroundviewにaddGestureRecognizerで自分自身にgestureRecognizerを登録してるのに、そのgestureのtargetがself.backgroundViewだと重複になるので、エラーがでた
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(removeCameraGuideView))
        self.backgroundView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setBackgroundViewConstraints() {
        // backgroundView
        NSLayoutConstraint.activate([
            self.backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.backgroundView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor)
        ])
    }
    
    private func setForegroundViewConstraints() {
        // foregroundView
        NSLayoutConstraint.activate([
            self.foregroundView.heightAnchor.constraint(equalToConstant: 200),
            self.foregroundView.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor, constant: 25),
            self.foregroundView.trailingAnchor.constraint(equalTo: self.backgroundView.trailingAnchor, constant: -25),
            self.foregroundView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.foregroundView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func setTitleLabelConstraints() {
        // titleLabelのconstraints設定
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.foregroundView.leadingAnchor, constant: 15),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.foregroundView.trailingAnchor, constant: -15),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.foregroundView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.foregroundView.topAnchor, constant: 30)
        ])
    }
    
    private func setImageViewConstraints() {
        // imageViewのconstraints設定
        NSLayoutConstraint.activate([
            self.imageView.heightAnchor.constraint(equalToConstant: 80),
            self.imageView.widthAnchor.constraint(equalToConstant: 80),
            self.imageView.centerXAnchor.constraint(equalTo: self.foregroundView.centerXAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 30)
        ])
    }
    
    // 入力された時間だけ、Animationが動作できるようにstart(duration)のメソッドを定義
    func startMoveImageUpAndDown(duration: TimeInterval) {
        print("start animate!")
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            options: [.curveEaseIn, .autoreverse, .repeat],
            animations: {
                self.imageView.center.y += 10
            },
            completion: { _ in
                self.imageView.center.y -= 10
            })
    }
    
    func stopMoveImageUpAndDown() {
        self.imageView.layer.removeAllAnimations()
    }
    
    @objc func removeCameraGuideView() {
        self.isShowing = false
    }

}
