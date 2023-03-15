//
//  BarcodeScannerViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/15.
//

import UIKit
import AVFoundation

//AVCaptureSessionオブジェクトを生成し、カメラ入力を追加してAVCaptureMetadataOutputオブジェクトを生成してバーコード認識のためのメタデータ出力を追加する。
// AVCaptureMetadataOutputは、画像データからMetaデータ(バーコード、QRコード、顔認証など)を検証し、出力するための役割を果たす
// カメラまたは、ビデオ入力から取得したデータストリームを分析し、メタデータオブジェクトを生成してデリゲートに転送する。
//AVCaptureMetadataOutputは、ビデオストリームで認識するメタデータの種類を設定することができ、このような設定を通して、特定のメタデータだけを検索することができる。
//AVCaptureMetadataOutputはAVCaptureOutputのSubClassで、PreviewLayerまたはファイルにデータを保存するためのAVCaptureVideoDataOutput、AVCaptureAudioDataOutputと一緒に使用できる。

//つまり、AVCaptureMetadataOutputはカメラから持ってきたビデオデータからバーコードやQRコードのようなメタデータを検索するためのクラスで、認識した結果をdelegateObjectに伝える。
class BarcodeScannerViewController: UIViewController {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // AVCaptureSessionのインスタンスを生成
        captureSession = AVCaptureSession()

        // Capture Deviceを設定する
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }

        // Capture入力を確立する Configure
        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }

        // 入力sessionを入れる
        captureSession.addInput(captureInput)

        // AVCaptureMetadataOutputのインスタンスを生成し、出力を作る
        let captureOutput = AVCaptureMetadataOutput()

        // 出力seesionを入れる
        captureSession.addOutput(captureOutput)

        // Capture出力のための、delegateとqueueを設定
        captureOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

        // 検出したいMetadataを設定する
        // QRコード、Barcodeを設定
        // 今後、分けるつもり
        captureOutput.metadataObjectTypes = [.qr, .ean8, .ean13]

        // PreviewLayerを作り、seesionに入れる
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Capture　Sessionを開始
        // 分けるつもり
        captureSession.startRunning()
    }
}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    //認識されたバーコードを処理
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 出力してみる
        print(output)
    }
}
