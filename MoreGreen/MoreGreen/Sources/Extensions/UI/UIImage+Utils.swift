//
//  UIImage_Extension.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/27.
//

import Foundation
import UIKit

// ⚠️途中の段階
extension UIImage {
    // 画像を90度回転させる
    var rotatedToUp: UIImage {
        // UIImageを加工する時の流れ: UIImage -> CGImage -> UIImage
        // 下のコードは、CGImageからUIImageに変換するコード
        // orientation: 元画像の方向を指定する
        // .up: スマホを横にして写真を撮った場合
        // .right: スマホを普通に(縦に)して写真を撮った場合
        
        // scale: 0.0にすると デバイスのscreenに合わせてscaleを生成してくれる (320 x 320みたいな)
        // scale パラメータに0.0を指定すると、デバイスにあわせて @2/@3の指定にしてくれる
        // そのため、0.0にすると思ったのと違ってファイルサイズが大きい 3.0などになる可能性もあるってこと
        // scale: 1.0 -> 320 X 320　(1x)ってこと
        // scale: 2.0 -> 640 X 640 (2x)
        // scale: 3.0 -> 960 X 960 (3x)
        let rotated = UIImage(cgImage: cgImage!, scale: 1.0, orientation: .up)
        
        // UIGraphicsBeginImageContextWithOptions:　絵を描いてUIImageとして保存する
        // bitmapの生成
        // 画像とテキストの合成も可能とさせる
        // size: 生成されるimageのサイズ (point単位である) -> つまり、 width * height * scaleってこと
        // opaque: imageの透明度の設定  -> falseにするときがperformance面で高い効果があるらしい
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        // draw作業するときのスタート座標を0, 0にするってこと
        //imageをresizingする
        // CGPoint(x: 0, y: 0) -> CGPoint.zeroでもいい
        rotated.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        
        //現在のbitmap graphic背景からimage持ってくる
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        // bitmap環境の除去
        UIGraphicsEndImageContext()
        
        // 大きさがresizeされたimageをreturn
        return rotatedImage!
    }
    
    var toUp: UIImage {
        let nonRotated = UIImage(cgImage: cgImage!, scale: 1.0, orientation: .right)
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        // draw作業するときのスタート座標を0, 0にするってこと
        //imageをresizingする
        // CGPoint(x: 0, y: 0) -> CGPoint.zeroでもいい
        nonRotated.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        
        //現在のbitmap graphic背景からimage持ってくる
        let notRotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        // bitmap環境の除去
        UIGraphicsEndImageContext()
        
        // 大きさがresizeされたimageをreturn
        return notRotatedImage!
    }
}
