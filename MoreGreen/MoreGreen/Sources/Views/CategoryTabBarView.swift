//
//  CategoryTabbar.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/11/06.
//

import UIKit

// MARK: 📚🔥他のファイルで定義したCollectionViewオブジェクトの連動方法
// step1. まずは、指定したswiftファイルにIBOutletをコードで直接記入する。
// step2. 次に、コードで書いたIBOutletをStoryboardに右dragで繋げる
// -->上記のstepで、Stotyboard上のオブジェクトを他のfileに連動することができる

class CategoryTabBarView: UIView, UICollectionViewDataSource {
    let tabBarNameArray: [String] = ["全体", "消費済み", "期限切れ"]
    weak var delegate: PagingTabbarDelegate?
    static let nibName = "CategoryTabBarView"
    var view: UIView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabBarNameArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        setSizeOfCollectionViewCell(width: categoryCollectionView.bounds.width, height: categoryCollectionView.bounds.height)
        guard let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else { return UICollectionViewCell()}
        categoryCell.setText(text: tabBarNameArray[indexPath.row])
        return categoryCell
    }
    
    // ページを表示するtabbar
    @IBOutlet weak var categoryCollectionView: UICollectionView! {
        didSet {
            categoryCollectionView.dataSource = self
            categoryCollectionView.delegate = self
            categoryCollectionView.register(UINib(nibName: CategoryCell.identifier, bundle: nil), forCellWithReuseIdentifier: CategoryCell.identifier)
            categoryCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: [])
        }
    }
    
    // Contents　Viewに合わせて、pageを変えてくれるコード
    func scroll(to index: Int) {
        categoryCollectionView.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: [])
    }
    
    func setSizeOfCollectionViewCell(width: CGFloat, height: CGFloat) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: width / 3, height: height)
        // flowlayoutのupdateを直ちに行うメソッド
        // reloadDataじゃなく、invalidateLayoutを採択した理由は、データソース内のデータが変更されるわけじゃないから、invalidateLayoutを用いた
        flowLayout.invalidateLayout()
        self.categoryCollectionView.collectionViewLayout = flowLayout
    }
}

extension CategoryTabBarView: UICollectionViewDelegateFlowLayout {
    // cellをclickしたときcontents Viewを該当のindexに移動させる
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.scrollToIndex(to: indexPath.row)
    }
}
