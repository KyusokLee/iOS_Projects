//
//  ItemDetailVC.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/11/06.
//

import UIKit
import CoreData

// MARK: 🔥 ここのVCは、HomeVCの"もっと見る"をクリックすることでmoveされるVC
// MARK: - Life Cycle and Variables
final class ItemDetailViewController: UIViewController {
    
    var filteredItems = [ItemList]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        print("もっと見るボタンを押しました!")
    }
}

// MARK: - Logic and Function
private extension ItemDetailViewController {
    
}
