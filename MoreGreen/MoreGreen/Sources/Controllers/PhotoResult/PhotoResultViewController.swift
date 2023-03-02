//
//  PhotoResultViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/30.
//

import UIKit

// ✍️撮った写真を画面に反映するためのtest VC
// ❗️PhotoResultへの反映は可能だった
// 写真をtapして、撮った写真を確認するように
// ここのページはcell indexが要らない
// ⚠️ただの、pinch gestureだけが可能となるViewになった　-> 今後、scroll viewにも対応させる予定

protocol ResizePhotoDelegate: AnyObject {
    func resizePhoto(with imageData: Data, scaleX x: CGFloat, scaleY y: CGFloat)
}

class PhotoResultViewController: UIViewController {
    
    // NewItemVCからimage写真データを受け取る変数
    var resultImageData: Data?
    var recognizerScale: CGFloat = 1.0
    var scaleX: CGFloat = 1.0
    var scaleY: CGFloat = 1.0
    var maxScale: CGFloat = 2.0
    var minScale: CGFloat = 1.0
    weak var delegate: ResizePhotoDelegate?
    
    @IBOutlet weak var resultImageView: UIImageView! {
        didSet {
            resultImageView.contentMode = .scaleAspectFill
            resultImageView.isUserInteractionEnabled = true
        }
    }
    
    @IBOutlet weak var dismissButton: UIButton! {
        didSet {
            dismissButton.setImage(UIImage(systemName: "multiply")?.withTintColor(UIColor.systemGray, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    
    @IBOutlet weak var resizeImageButton: UIButton! {
        didSet {
            resizeImageButton.setTitle("上記の写真に変更", for: .normal)
            resizeImageButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
            resizeImageButton.tintColor = UIColor.white
            
            resizeImageButton.layer.cornerRadius = 8
            resizeImageButton.backgroundColor = UIColor(rgb: 0x81C784)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPinchGesture()
        addTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func addPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(doPinch))
        resultImageView.addGestureRecognizer(pinchGesture)
    }
    
    @objc func doPinch(_ pinch: UIPinchGestureRecognizer) {
        if pinch.state == .began || pinch.state == .changed {
            if (recognizerScale < maxScale && pinch.scale > 1.0) {
                // 拡大
                resultImageView.transform = (resultImageView.transform).scaledBy(x: pinch.scale, y: pinch.scale)
                recognizerScale *= pinch.scale
                pinch.scale = 1.0
            } else if (recognizerScale > minScale && pinch.scale < 1.0) {
                // 縮小
                resultImageView.transform = (resultImageView.transform).scaledBy(x: pinch.scale, y: pinch.scale)
                recognizerScale *= pinch.scale
                pinch.scale = 1.0
            }
        }
    }
    
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        tapGesture.numberOfTapsRequired = 2
    }
    
    @objc func imageTap(_ gesture: UITapGestureRecognizer) {
        resultImageView.transform = CGAffineTransform.identity
        recognizerScale = 1.0
    }
    
    static func instantiate(with imageData: Data) -> PhotoResultViewController {
        guard let controller = UIStoryboard(name: "PhotoResultView", bundle: nil).instantiateViewController(withIdentifier: "PhotoResultViewController") as? PhotoResultViewController else {
            fatalError("PhotoResutViewController could not be found")
        }
        controller.loadViewIfNeeded()
        controller.configure(with: imageData)
        
        return controller
    }

    @IBAction func dismissTap(_ sender: Any) {
        self.dismiss(animated: true) {
            print("dismiss photoresult VC")
        }
    }
    
    @IBAction func tapResizePhoto(_ sender: Any) {
        print("take photo again")
        self.delegate?.resizePhoto(with: resultImageData!, scaleX: recognizerScale, scaleY: recognizerScale)
        self.dismiss(animated: true)
    }
    
}

private extension PhotoResultViewController {
    func configure(with imageData: Data) {
        print("success to take a photo!")
        
        let image = UIImage(data: imageData)
        resultImageView.image = image
    }
    
    // ⚠️test のとこは、navigationじゃなくpresentにしたい
    func setUpNavigationBar(from imageData: Data) {
        let image = UIImage(data: imageData)?.toUp
        resultImageView.image = image
        
        navigationItem.title = "写真結果の画面"
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
    }
}
