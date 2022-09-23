//
//  CameraVC.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/23.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController {
    
    @IBOutlet private weak var previewView: UIView!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    
    //CaptureSession編数 _ cameraCaptureに関する全ての流れを管理するsession
    private let captureSession = AVCaptureSession()
    // 解像度の設定 -> default: Highになっている
    //CameraDevicesの登録編数
    private var cameraDevice: AVCaptureDevice!
    //画像のOutput_写真キャプチャ
    private let imageOutput = AVCapturePhotoOutput()
    
    //preview layerは全域編数として使ってもよかったかも
    

    // カメラをとって、item生成vcに画面遷移
    static func instantiate() -> NewItemVC {
        return UIStoryboard(name: "NewItemVC", bundle: nil).instantiateInitialViewController() as! NewItemVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // cameraの部分では、 navigationBarを隠す
        navigationController?.isNavigationBarHidden = true
        // カメラの設定やセッションの組み立てはここで行う
        settingSession()
        // preview Layer setting間数の呼び出し
        settingLivePreveiw()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        startCapture()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopCapture()
    }
}

extension CameraVC {
    @IBAction func shootButton(_ sender: Any) {
        /// TODO: 課題1
        // このタイミングでカメラのシャッターを切る
        print("Pressed Shutter _ 課題1")
        
        // 単一写真capture Requestで使用する機能及び設定の使用を定義するobject
        let settings = AVCapturePhotoSettings()
        // flashを使うかどうかの設定
        settings.flashMode = .auto
        // Not yet: カメラの手ぶれ補正もあったら？
        
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0.0)
        //スクショの処理
        imageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // Capture Resultを受け取るメソッド
    // didFinishProcessingPhoto: 保存のために、実装しなければいけない部分
    // ⚠️Error: -> private でも、ただのfuncでもAVCapturePhotoCaptureDelegate がErrorになった！
    
    // photoOutputをinternalにしたら直った -> なぜ？
    // internal 内部moduleだけで使う
//    internal func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        guard error == nil else {
//            print("Error broken photo data: \(error!)")
//            return
//        }
//
//        guard let imageData = photo.fileDataRepresentation() else {
//            print("No photo data to write.")
//            return
//        }
//
//        // logic: Success -> result Viewに画面を移動
//        //画面の設定 with imageData
//        let resultVC = ProfileViewController.instantiate(with: imageData)
//        // back buttonもあったらいいよね...? -> dismiss buttonがあった
//
//        // 画面移動
//        navigationController?.pushViewController(resultVC, animated: true)
//    }

    @IBAction func didTapCloseButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func settingSession() {
        // カメラ設定の変更のスタート時点
//        self.captureSession.beginConfiguration()
        // quality Level setting = .photo
        captureSession.sessionPreset = .photo
        // CameraDeviceの設定
        // position: 前面カメラ, 背面カメラの設定 (unspecified: 特定せず)
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        //Propertyの条件を満たしたカメラデバイスの取得
        // .first = .backにdefaultになってるっぽい
        let availableDevices = deviceDiscoverySession.devices
        for device in availableDevices {
            if device.position == AVCaptureDevice.Position.back {
                cameraDevice = device
            }
        }
        
        // back CameraからVideoInput　取得
        let videoInput: AVCaptureInput!
        
        do {
            // deviceのinput
            videoInput = try AVCaptureDeviceInput(device: cameraDevice)
        } catch {
            videoInput = nil
            print(error)
        }
        
        // 画質の設定 default: highになっている
        captureSession.sessionPreset = .hd1920x1080
        // sessionにinputを登録
        captureSession.addInput(videoInput)
        captureSession.addOutput(imageOutput)
    }
    
    //preview layer Setting
    private func settingLivePreveiw() {
        // input, outputが設定された AVCaptureSessionのpreview オブジェクトを受け取り、previewのlayerを持つデータ型
        let captureVideoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        // layerのframeを設定 -> layerのframeを
        captureVideoLayer.frame = self.view.bounds
        
        // 見せるpreviewのboundsのサイズを設定
        captureVideoLayer.videoGravity = .resizeAspectFill
        
        // Viewにlayerをaddする
        // ✍️ addSublayer と　insertSublayerの差は？
        // add -> Sublayerを上に足すこと
        // insert -> 該当のlayerに sublayerを入れること
        self.view.layer.insertSublayer(captureVideoLayer, at: 0)
    }

    func startCapture() {
        // TODO: 課題1 -> 完了
        // ここでセッションをスタート
        
        // DispatchQueue.globalを用いる
        // startRunningは設定処理に時間がかかるのでバックグラウンドスレッドで実行させる -> スムーズな実行処理ができるので、ユーザー経験を考えたコードの実装が可能
        // 参照: https://developer.apple.com/documentation/avfoundation/avcapturesession/1388185-startrunning
        // 🔥ここ、ちょっとむずい
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
        
        captureSession.startRunning()
    }

    func stopCapture() {
        // TODO: 課題1 -> 完了
        // ここでセッションをストップ
        
        //captureSessionが作動中であるときだけ、stopするように
        guard captureSession.isRunning else {
            return
        }
        captureSession.stopRunning()
    }
}

extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        guard error == nil else {
//            print("Error broken photo data: \(error!)")
//            return
//        }
        
        // dataがnilだったら、それ自体がerrorであることだから、上記のerrorに関するguard error処理はなくてもいい
        // fileDataRepresentation: 撮影した画像をデータ化する (Data型)
        guard let imageData = photo.fileDataRepresentation() else {
            print("No photo data to write.")
            return
        }
        
        // logic: Success -> result Viewに画面を移動
        //画面の設定 with imageData
        let resultVC = NewItemVC.instantiate(with: imageData)
        // 🔥ここが肝心なところ!!!
        // ここで、presenterのloadProfileメソッドを呼びださない以上、profileVCで作成したProtocolにデータが渡されるわけがない
        // 写真をとって、ここでloadするようにしておく
        // データ型を base64EncodedString()を用いて、String型にしておく必要がある
//        resultVC.presenter.loadProfile(from: imageData.base64EncodedString())
        
        // navigationItemのbackbuttonItemをcustomする
        // styleは、tapするとglowする plain　(default)にする
        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButtonItem
        navigationController?.navigationBar.tintColor = UIColor.white
        
        // 画面移動
        navigationController?.pushViewController(resultVC, animated: true)
    }
}
