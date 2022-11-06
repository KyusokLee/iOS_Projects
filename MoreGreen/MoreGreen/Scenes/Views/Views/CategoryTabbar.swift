//
//  CategoryTabbar.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/11/06.
//

import UIKit

class CategoryTabbar: UIView {
    let tabBarNameArray: [String] = ["全体", "消費済み", "期限切れ"]
    weak var delegate: PagingTabbarDelegate?
    static let nibName = "CategoryTabbar"
    var view: UIView!
    
    // ページを表示するtabbar
    

    
    func scroll(to index: Int) {
        
    }
    
    func setSizeOfCollectionViewCell(width: CGFloat, height: CGFloat) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        // flowlayoutのupdateを直ちに行うメソッド
        flowLayout.invalidateLayout()
        
    }
    
    
    
    
}


extension CategoryTabbar: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabBarNameArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        setSizeOfCollectionViewCell(width: <#T##CGFloat#>, height: <#T##CGFloat#>)
    }
    
    
}

extension CategoryTabbar: UICollectionViewDelegateFlowLayout {
    // cellをclickしたときcontents Viewを該当のindexに移動させる
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.scrollToIndex(to: indexPath.row)
    }
}
