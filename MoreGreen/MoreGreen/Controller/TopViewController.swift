//
//  ViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/20.
//

import UIKit

// MARK: APP logic
// カメラで商品の写真を撮る
// MVP🔥 1-1. 賞味期限の OCR (GCP)
// MVP🔥 1-2. 商品のバーコードを読み込む
// 1-2(1). Yahoo search APIや外部の商品番号登録APIとfetchする (GCP 後、 他のAPI)
// MVP🔥 1-3. 画面に表示
// MVP🔥 1-4. Core Dataを導入し、保存するように
// MVP🔥 1-5. dataのCRUDを可能に
// MVP🔥 1-6.　アラーム通知
// 1-7. 家族との共有システム (家の商品をより効率的に管理しよう)
// 1-8. 経済的な費用を計算するように
// 1-9. Callenderを導入し、月別のデータを見れるように

class TopViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("change VC name and Storyboard")
    }
    
    // メモリのwarningを通知
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

