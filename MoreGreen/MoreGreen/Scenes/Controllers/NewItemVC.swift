//
//  NewItemVC.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit

class NewItemVC: UIViewController {
    
    @IBOutlet weak var createViewTitle: UILabel! {
        didSet {
            createViewTitle.text = "食品登録"
            createViewTitle.tintColor = .black
            createViewTitle.font = .systemFont(ofSize: 20, weight: .bold)
        }
    }
    @IBOutlet weak var dismissButton: UIButton! {
        didSet {
            dismissButton.setImage(UIImage(systemName: "multiply.circle")?.withRenderingMode(.alwaysOriginal), for: .normal)
            dismissButton.tintColor = UIColor.systemGray.withAlphaComponent(0.7)
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Create new item list with camera OCR and barcode")
        // Do any additional setup after loading the view.
    }
    

    @IBAction func dismissTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
