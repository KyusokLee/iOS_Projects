//
//  VisionPracticeViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/07/11.
//

import UIKit
import Vision

// Visionフレームワークを使って、指Actionを認識させるための練習用 File
// ZOZO MeetUpのyoutube urlを見ながら参照すること
class VisionPracticeViewController: UIViewController {
    
    var handPoseRequest = VNDetectHumanHandPoseRequest()

//    let handler = VNImageRequestHandler(
//        cmSampleBuffer: CMSampleBuffer
//    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handPoseRequest.maximumHandCount = 1 // 認識する手の数
        

        // Do any additional setup after loading the view.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
