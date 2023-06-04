//
//  CameraViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/23.
//

import UIKit
import AVFoundation
import CoreData

// MARK: - コードの改善とVisionOCR機能の確立後、buttonを一つにする予定
// cellIndexによって、Image写真の種類を分ける
// index 0: ただのimage写真 -> 今後　商品の名前も認識するように変更する方針
// index 1: OCR 結果を用いる賞味期限の文字認識image -> この場合、presenterを用いる
protocol CameraViewControllerDelegate: AnyObject {
    func didFinishTakePhoto(with imageData: Data, index cellIndex: Int)
}

// MARK: - Life Cycle and Variables
// TODO: - 1. 商品の名前をカメラで撮るように、 2. 商品名を認証させた後、賞味期限を撮るように
final class CameraViewController: UIViewController {
    // カメラの拡大、縮小の機能をTapgestureで追加する
    @IBOutlet private weak var previewView: UIView!
    @IBOutlet weak var shootButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var showCameraGuideViewButton: UIButton!
    
    weak var delegate: CameraViewControllerDelegate?
    var checkState = [CheckState]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    // itemの写真を撮る場合は -> 0, itemの賞味期限や消費期限の写真を撮る場合は -> 1
    var cellIndex = 0
    // CaptureSession編数 _ cameraCaptureに関する全ての流れを管理するsession
    private let captureSession = AVCaptureSession()
    // 画像のOutput_写真キャプチャ
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let cameraGuideView: CameraGuideView = {
        let view = CameraGuideView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // 初期設定として、loadingをtrueに
        // CoreDataのshowCameraGuideStateに合わせる方法に変更
        // view.isShowing = true
        return view
    }()
    
    // カメラをVCへの画面遷移メソッド
    static func instantiate() -> CameraViewController {
        let storyboard = UIStoryboard(name: "Camera", bundle: nil)
        guard let controller = storyboard.instantiateViewController(
            withIdentifier: "CameraViewController"
        ) as? CameraViewController else {
            fatalError("CameraViewController could not be found.")
        }
        
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("cell Index: \(cellIndex)")
        // cameraの部分では、 navigationBarを隠す
        navigationController?.isNavigationBarHidden = true
        // GuideLineViewを表示
        self.view.addSubview(cameraGuideView)
        setUpScreen()
        // カメラの設定やセッションの組み立てはここで行う
        setUpSession()
        addPinchGesture()
        // preview Layer setting間数の呼び出し
        setUpPreveiwLayer()
        setUpCameraGuideViewConstraints()
        // delegateを受け取る
        cameraGuideView.delegate = self
        // CameraGuideView CheckStateをfetchする
        fetchCameraGuideViewCheckStateAndShowView()
    }
    
    // viewDidLayoutSubViewsを導入してみた
    // SubViewのlayoutが変更された後に呼び出されるメソッドである
    // このメソッドの呼び出される順番は、SubViewのlayoutを変更した後、追加のタスクを実行するのに最適な時点となる
    // そのため、previewLayerのframeをpreviewViewのboundsに合わせるのにいい時点だと判断
    // Viewがloadされた後、layoutを確立させる
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = previewView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        startCapture()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopCapture()
        resetZoomScale()
    }
}

// MARK: - Logic and Function
private extension CameraViewController {
    @IBAction func didTapShootButton(_ sender: Any) {
        // このタイミングでカメラのシャッターを切る
        print("Pressed Shutter")
        // 単一写真capture Requestで使用する機能及び設定の使用を定義するobject
        let settingsForMonitoring = AVCapturePhotoSettings()
        // flashを使うかどうかの設定
        settingsForMonitoring.flashMode = .auto
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0.0)
        // スクショの処理
        // 写真をcaptureするdelegateは、self(CameraViewController)
        photoOutput.capturePhoto(with: settingsForMonitoring, delegate: self)
    }

    @IBAction func didTapDismissButton(_ sender: Any) {
        // 以前のnavigation controllerに戻る
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapShowCameraGuideViewButton(_ sender: Any) {
        self.cameraGuideView.isShowing = true
    }
    
    // ここで、ScreenのUIを確率する
    func setUpScreen() {
        setUpDismissButton()
        setUpShootButton()
        setUpShowCameraGuideViewButton()
    }
    
    func setUpDismissButton() {
        let color = UIColor.systemGray.withAlphaComponent(0.7)
        let image = UIImage(systemName: "xmark")?.withTintColor(color, renderingMode: .alwaysOriginal)
        guard let image = image else { return }
        dismissButton.setImage(image, for: .normal)
        //Buttonの設定したconstraintsより、imageが小さくなった場合、Buttonをsizeの大きさに合わせる方法
        dismissButton.contentVerticalAlignment = .fill
        dismissButton.contentHorizontalAlignment = .fill
    }
    
    func setUpShootButton() {
        // imageの大きさがただのimageに入れるととても小さく表示される
        // しかし、backGroundに入れると、大きいサイズになっている
        let color = UIColor(rgb: 0x388E3C)
        let image = UIImage(systemName: "camera.circle.fill")?.withRenderingMode(.alwaysOriginal)
        guard let image = image else { return }
        shootButton.setImage(image, for: .normal)
        shootButton.contentVerticalAlignment = .fill
        shootButton.contentHorizontalAlignment = .fill
        shootButton.tintColor = color
    }
    
    func setUpShowCameraGuideViewButton() {
        let color = UIColor.white.withAlphaComponent(0.7)
        let image = UIImage(systemName: "questionmark.circle")?.withRenderingMode(.alwaysTemplate)
        guard let image = image else { return }
        showCameraGuideViewButton.setImage(image, for: .normal)
        // UIのboundsに合わせてSizeを調整する方法
        showCameraGuideViewButton.contentVerticalAlignment = .fill
        showCameraGuideViewButton.contentHorizontalAlignment = .fill
        showCameraGuideViewButton.tintColor = color
    }
    
    func setUpCameraGuideViewConstraints() {
        NSLayoutConstraint.activate([
            self.cameraGuideView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.cameraGuideView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.cameraGuideView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.cameraGuideView.topAnchor.constraint(equalTo: self.view.topAnchor)
        ])
    }
    
    // CameraGuideViewのcheckStateをfetchし、viewを表示するかどうかを管理するメソッド
    // MARK: - ⚠️途中の段階
    func fetchCameraGuideViewCheckStateAndShowView() {
        // let shouldShow = shouldShowCameraGuideView()
        cameraGuideView.isShowing = shouldShowCameraGuideView()
        
//        if shouldShow {
//            // CameraGuideViewを表示
//            cameraGuideView.isShowing = shouldShow
//
//        } else {
//            // CameraGuideViewを表示させない
//
//
//        }
    }
    
    // CameraGuideViewを表示させるかどうかを判別するメソッド
    func shouldShowCameraGuideView() -> Bool {
        let fetchRequest: NSFetchRequest<CheckState> = CheckState.fetchRequest()
        let context = appDelegate.persistentContainer.viewContext
        do {
            let results = try context.fetch(fetchRequest)
            if let checkState = results.first {
                return checkState.value(forKey: "showCameraGuideView") as? Bool ?? true
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // 設定されてないなら、trueをdefaultとして返すように
        return true
    }
    
    // camera Preview viewに拡大、縮小の機能を追加
    func addPinchGesture() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchToCameraZoom))
        previewView.addGestureRecognizer(pinch)
    }
        
    @objc func pinchToCameraZoom(_ sender: UIPinchGestureRecognizer) {
        guard let captureDevice =  AVCaptureDevice.default(for: .video) else {
            fatalError("There is no available capture device.")
        }
        
        var initialScale = captureDevice.videoZoomFactor
        let minAvailableZoomScale = 1.0
        let maxAvailableZoomScale = captureDevice.maxAvailableVideoZoomFactor
        
        do {
            try captureDevice.lockForConfiguration()
            
            if (sender.state == UIPinchGestureRecognizer.State.began) {
                initialScale = captureDevice.videoZoomFactor
            } else {
                if (initialScale * (sender.scale) < minAvailableZoomScale) {
                    captureDevice.videoZoomFactor = minAvailableZoomScale
                } else if (initialScale * (sender.scale) > maxAvailableZoomScale) {
                    captureDevice.videoZoomFactor = maxAvailableZoomScale
                } else {
                    captureDevice.videoZoomFactor = initialScale * (sender.scale)
                }
            }
            sender.scale = 1.0
            captureDevice.unlockForConfiguration()
        } catch let error {
            print("Error: \(error.localizedDescription)")
            return
        }
    }
    
    // ViewがDisppearされるとき、Zoom ScaleをDefaultに戻す間数
    func resetZoomScale() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            fatalError("There is no available capture device.")
        }
        
        do {
            try captureDevice.lockForConfiguration()
            // videoZoomFactorを1.0にresetする
            captureDevice.videoZoomFactor = 1.0
            captureDevice.unlockForConfiguration()
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func setUpSession() {
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: captureDevice),
              captureSession.canAddInput(videoInput),
              captureSession.canAddOutput(photoOutput)
        else {
            fatalError("カメラのセットアップに失敗しました")
        }
        // 画質の設定 default: highになっている
        captureSession.sessionPreset = .hd1920x1080
        captureSession.addInput(videoInput)
        captureSession.addOutput(photoOutput)
    }
    
    // previewLayerのSetting
    private func setUpPreveiwLayer() {
        previewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        // 見せるpreviewのboundsのサイズを設定
        previewLayer.videoGravity = .resizeAspectFill
        // 縦でカメラを撮ることを前提とした設定
        previewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(previewLayer)
    }

    func startCapture() {
        // ここでセッションをスタート
        // DispatchQueue.globalを用いる
        // startRunningは設定処理に時間がかかるのでバックグラウンドスレッドで実行させる -> スムーズな実行処理ができることに気づいた
        // 参照: https://developer.apple.com/documentation/avfoundation/avcapturesession/1388185-startrunning
        guard !captureSession.isRunning else {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func stopCapture() {
        // ここでセッションをストップ
        //captureSessionが作動中であるときだけ、stopするように
        guard captureSession.isRunning else {
            return
        }
        captureSession.stopRunning()
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    // カメラのシャッター音に関しては、今後変更する予定である
    // 🔥カメラの音を無音にする (複数の国では、無音にすることは禁止されている)
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        AudioServicesDisposeSystemSoundID(1108)
    //  AVAudioPlayer().play()
    }
    
    // 🔥カメラの音を無音にする (複数の国では、無音にすることは禁止されている)
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        AudioServicesDisposeSystemSoundID(1108)
    }
    
    //　写真を撮った後のprocess動作処理
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // fileDataRepresentation: 撮影した画像をデータ化する (Data型)
        guard let imageData = photo.fileDataRepresentation() else {
            print("No photo data to write.")
            return
        }
        // Logic: Success -> result Viewに画面を移動
        //画面の設定 with imageData
        print(imageData)
        // bytesが表示される
        // Photoを撮ったことをdelegateに知らせる
        delegate?.didFinishTakePhoto(with: imageData, index: cellIndex)
        // 一個前のVCに戻る
        navigationController?.popViewController(animated: true)
    }
}

extension CameraViewController: CameraGuideViewDelegate {
    // checkBox buttonをtapしたとき、popupViewが表示されるようにする
    func didTapCheckBoxButton() {
        let storyboard = UIStoryboard(name: "CameraGuidePopup", bundle: nil)
        guard let controller = storyboard.instantiateViewController(
            withIdentifier: "CameraGuidePopupViewController"
        ) as? CameraGuidePopupViewController else {
            fatalError("CameraPopupViewController could not be found.")
        }
        
        cameraGuideView.foregroundView.alpha = 0.0
        cameraGuideView.swipeLeftButton.alpha = 0.0
        cameraGuideView.swipeRightButton.alpha = 0.0
        cameraGuideView.checkBoxButton.alpha = 0.0
        cameraGuideView.checkBoxTitleLabel.alpha = 0.0
        cameraGuideView.stopImageViewAnimation()
        
        controller.delegate = self
        controller.modalPresentationStyle = .overCurrentContext
        // 🌈modalTransitionStyle: 画面が転換されるときのStyle効果を提供する。animation Styleの設定可能
        // .crossDissolve: ゆっくりと消えるスタイルの設定
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true)
    }
}

extension CameraViewController: CameraGuidePopupDelegate {
    func shouldShowCameraGuideViewAgain() {
        print("show CameraGuideView again")
        UIView.animate(withDuration: 0.4) {
            self.cameraGuideView.foregroundView.alpha = 1.0
            self.cameraGuideView.swipeLeftButton.alpha = 1.0
            self.cameraGuideView.swipeRightButton.alpha = 1.0
            self.cameraGuideView.checkBoxButton.alpha = 1.0
            self.cameraGuideView.checkBoxTitleLabel.alpha = 1.0
        }
        cameraGuideView.isShowing = shouldShowCameraGuideView()
        cameraGuideView.startImageFadeAndChangeSize(duration: AnimationTime.duration)
    }
    
    func shouldHideCameraGuideView() {
        print("hide camera Guide View")
        UIView.animate(withDuration: 0.4) {
            self.cameraGuideView.foregroundView.alpha = 1.0
            self.cameraGuideView.swipeLeftButton.alpha = 1.0
            self.cameraGuideView.swipeRightButton.alpha = 1.0
            self.cameraGuideView.checkBoxButton.alpha = 1.0
            self.cameraGuideView.checkBoxTitleLabel.alpha = 1.0
        }
        
        cameraGuideView.isShowing = shouldShowCameraGuideView()
    }
}
