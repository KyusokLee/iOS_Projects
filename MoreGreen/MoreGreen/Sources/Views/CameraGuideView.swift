//
//  CameraGuideView.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/05.
//

import UIKit

final class CameraGuideView: UIView {
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
     }()
    
    private let foregroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.white.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "商品の賞味期限が映るようにしてください"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
     
    var isShowing = false {
        didSet {
            self.isHidden = !self.isShowing
            // animation効果を与えたいので、alphaでisHiddenと同様な処理をする
            if self.isShowing {
                self.foregroundView.alpha = 1.0
            } else {
                self.foregroundView.alpha = 0.0
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.backgroundView)
        self.addSubview(self.foregroundView)
        self.addSubview(self.titleLabel)
        
        // backgroundView
        NSLayoutConstraint.activate([
            self.backgroundView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.backgroundView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor)
        ])
        
        // foregroundView
        NSLayoutConstraint.activate([
            self.foregroundView.heightAnchor.constraint(equalToConstant: 100),
            self.foregroundView.widthAnchor.constraint(equalToConstant: 100),
            self.foregroundView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.foregroundView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        // titleLabelのconstraints設定
        NSLayoutConstraint.activate([
            self.titleLabel.heightAnchor.constraint(equalToConstant: 300),
            self.titleLabel.widthAnchor.constraint(equalToConstant: 300),
            self.titleLabel.centerXAnchor.constraint(equalTo: self.foregroundView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.foregroundView.topAnchor, constant: 90)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("CameraGuideView doesn't use Nib file.")
    }

}
