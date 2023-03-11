//
//  CameraGuideView.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/05.
//

import UIKit
import CoreData

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
            .withTintColor(
                UIColor.systemGreen,
                renderingMode: .alwaysOriginal
            )
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let checkBoxButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "checkmark.square")?
            .withTintColor(
                UIColor.systemGray.withAlphaComponent(0.8),
                renderingMode: .alwaysOriginal
            )
        button.setImage(image, for: .normal)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let checkBoxTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.systemGray.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.text = "もう一度、表示しない"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
     
    var isShowing = false {
        didSet {
            self.isHidden = !self.isShowing
            // animation効果を与えたいので、alphaでisHiddenと同様な処理をする
            if self.isShowing {
                UIView.animate(withDuration: 0.35) {
                    self.foregroundView.alpha = 1.0
                }
                //self.startMoveImageUpAndDown(duration: 0.8)
                self.startImageFadeAndChangeSize(duration: 2.0)
            } else {
                self.foregroundView.alpha = 0.0
                // Error: CamareViewControllerで ボタンをtapすると、animateが再動作しない
                // 理由: UIView.animateで一回animateで動かしたものは、stopしない限り、このpropertyによる再動作はしないことが原因だった
                // 解決: animateのtargetとしたUIのlayerでremoveAllAnimations()をすることで、animationの初期化ができる
                self.stopImageViewAnimation()
            }
        }
    }
    
    // cameraGuideViewを表示するかどうかに関するBool type propertyを設ける
    // buttonをtapすると、cameraGuidePopupViewをpresentする
    // ただし、PopupViewの取り消しボタンを押すと、ただ、popupViewをdismissするだけにする
    // 確認を押すと、cameraGuideViewをdismissする
    var isChecked: Bool = false {
        didSet {
            let checkBoxImageName = isChecked ? "s" : "ss"
        }
    }
    var checkState = [CheckState]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.backgroundView)
        self.addTapgesture()
        self.foregroundView.addSubview(self.titleLabel)
        self.foregroundView.addSubview(self.imageView)
        self.addSubview(self.foregroundView)
        self.addSubview(self.checkBoxButton)
        self.checkBoxButton.addTarget(self, action: #selector(didTapCheckBoxButton), for: .touchUpInside)
        self.addSubview(self.checkBoxTitleLabel)
        
        self.setBackgroundViewConstraints()
        self.setForegroundViewConstraints()
        self.setTitleLabelConstraints()
        self.setImageViewConstraints()
        self.setCheckBoxButtonConstraints()
        self.setCheckBoxTitleLabelConstraints()
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
    
    private func setCheckBoxButtonConstraints() {
        // imageViewのconstraints設定
        NSLayoutConstraint.activate([
            self.checkBoxButton.heightAnchor.constraint(equalToConstant: 25),
            self.checkBoxButton.widthAnchor.constraint(equalToConstant: 25),
            self.checkBoxButton.leadingAnchor.constraint(equalTo: self.backgroundView.leadingAnchor, constant: 25),
            self.checkBoxButton.topAnchor.constraint(equalTo: self.foregroundView.bottomAnchor, constant: 10)
        ])
    }
    
    private func setCheckBoxTitleLabelConstraints() {
        // imageViewのconstraints設定
        NSLayoutConstraint.activate([
            self.checkBoxTitleLabel.heightAnchor.constraint(equalToConstant: 25),
            self.checkBoxTitleLabel.leadingAnchor.constraint(equalTo: self.checkBoxButton.trailingAnchor, constant: 10),
            self.checkBoxTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.backgroundView.trailingAnchor, constant: -25),
            self.checkBoxTitleLabel.topAnchor.constraint(equalTo: self.foregroundView.bottomAnchor, constant: 10)
        ])
    }
    
    // 入力された時間だけ、Animationが動作できるようにstart(duration)のメソッドを定義
    // これは、2つ目のcameraGuideView
    func startMoveImageUpAndDown(duration: TimeInterval) {
        print("start animate!")
        self.layoutIfNeeded()
        
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
    
    // ImageViewのimageのsizeを拡大したり、縮小したりするanimateに加えて、色が微かになる(fadeIn, fadeOut効果)の一連のanimationを動作をメソッド
    // animation の流れ
    // 1.sizeの縮小(firstAnimation)
    // 2.sizeの拡大(secondAnimation): constraintsで設定したsizeに
    // 3.imageのfadeOut(thirdAnimation)
    // 4.imageのfadeIn(fourthAnimation)
    // これが最初のcameraGuideView
    func startImageFadeAndChangeSize(duration: TimeInterval) {
        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            // repeatをして、繰り返しを行う
            options: [.repeat],
            animations: {
                UIView.addKeyframe(
                    withRelativeStartTime: AnimationTime.firstAnimation.relativeStartTime,
                    relativeDuration: AnimationTime.firstAnimation.relativeDuration,
                    animations: self.animateDownsize
                )
                  
                UIView.addKeyframe(
                    withRelativeStartTime: AnimationTime.secondAnimation.relativeStartTime,
                    relativeDuration: AnimationTime.secondAnimation.relativeDuration,
                    animations: self.animateUpsize
                )
                
                UIView.addKeyframe(
                    withRelativeStartTime: AnimationTime.thirdAnimation.relativeStartTime,
                    relativeDuration: AnimationTime.thirdAnimation.relativeDuration,
                    animations: self.animateFadeOut
                )
                
                UIView.addKeyframe(
                    withRelativeStartTime: AnimationTime.forthAnimation.relativeStartTime,
                    relativeDuration: AnimationTime.forthAnimation.relativeDuration,
                    animations: self.animateFadeIn
                )
            },
            completion: nil
        )
    }
    
    func stopImageViewAnimation() {
        self.imageView.layer.removeAllAnimations()
    }
    
    // checkStateのcoredataをfetchする
    // ⚠️途中の段階: checkStateの中で、showCameraGuideといったtypeだけ利用したいのに、全部持ってくる必要があるのか
    // 考えられる解決策: CoreDataじゃなく、singleToneでsharingするといいかもって思った
    // CoreDataで新しく保存するとかじゃなくて、Bool Typeを更新するだけなんで、appendとかのデータの追加はいらない
    private func fetchCheckState() {
        let fetchRequest: NSFetchRequest<CheckState> = CheckState.fetchRequest()
        let context = appDelegate.persistentContainer.viewContext
        do {
            self.checkState = try context.fetch(fetchRequest)
            print(self.checkState)
        } catch {
            print(error)
        }
        
        fetchShowCameraGuideViewState()
    }
    
    private func fetchShowCameraGuideViewState() {
        let fetchRequest: NSFetchRequest<ItemList> = ItemList.fetchRequest()
        do {
            // filteredDataは、[ItemList]　配列typeである
            let showCameraGuideView = try context.fetch(fetchRequest)
           
            appDelegate.saveContext()
        } catch {
            print(error)
        }
    }
    
    @objc func removeCameraGuideView() {
        self.isShowing = false
    }
    
    @objc func didTapCheckBoxButton() {
        print("tap check button!")
        guard let controller = UIStoryboard(
            name: "CameraGuidePopup",
            bundle:nil
        ).instantiateViewController(
            withIdentifier: "CameraGuidePopupViewController"
        ) as? CameraGuidePopupViewController else {
            fatalError("CameraPopupViewController could not be found.")
        }
        
        controller.modalPresentationStyle = .overCurrentContext
        // 🌈modalTransitionStyle: 画面が転換されるときのStyle効果を提供する。animation Styleの設定可能
        // .crossDissolve: ゆっくりと消えるスタイルの設定
        controller.modalTransitionStyle = .crossDissolve
                
        // ⭐️Tip: modalTransitionStyleだけだと、ナチュラルなCrossDissolveStyleの画面の転換にならなかった。crossDissolve自体は、画面を交差するようなanimationであるため、overCurrentContextと一緒に書かないと、後ろのviewが小さくなり、popupViewが表に大きくでるような交差効果になる。
        self.window?.rootViewController?.tabBarController?.present(controller, animated: true, completion: nil)
    }
    
    private func animateDownsize() {
        self.imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }

    private func animateUpsize() {
        self.imageView.transform = .identity
    }

    private func animateFadeOut() {
        self.imageView.alpha = 0
    }

    private func animateFadeIn() {
        self.imageView.alpha = 1
    }
    
    private func animateMoveUp() {
        self.imageView.center.y += 10
    }
    
    private func animateMoveDowm() {
        self.imageView.center.y -= 10
    }
}
