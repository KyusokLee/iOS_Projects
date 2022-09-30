//
//  PhotoResultVC.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/30.
//

import UIKit

// ✍️撮った写真を画面に反映するためのtest VC
// ❗️PhotoResultへの反映は可能だった

class PhotoResultVC: UIViewController {
    
    @IBOutlet weak var resultImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    static func instantiate(with imageData: Data, index cellIndex: Int) -> PhotoResultVC {
        // controllerの指定
        let controller = UIStoryboard(name: "PhotoResultView", bundle: nil).instantiateViewController(withIdentifier: "PhotoResultVC") as! PhotoResultVC
        controller.loadViewIfNeeded()
        controller.configure(with: imageData)
        
        return controller
    }

}

private extension PhotoResultVC {
    func configure(with imageData: Data) {
        print("success to take a photo!")
        
        setUpNavigationBar(from: imageData)
    }
    
    func setUpNavigationBar(from imageData: Data) {
        let image = UIImage(data: imageData)?.toUp
        resultImageView.image = image
        
        navigationItem.title = "写真結果の画面"
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
    }
}
