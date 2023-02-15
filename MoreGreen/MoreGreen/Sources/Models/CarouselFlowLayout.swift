//
//  CarouselFlowLayout.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/10/18.
//

import UIKit

// collectionView Cellを横方向にscrollするときに、animationやUIにeffectを与えるために、作成した Custom FlowLayout
class CarouselFlowLayout: UICollectionViewFlowLayout {
    
    private var firstTime: Bool = false
    public var spacing: CGFloat = 15
    
    override func prepare() {
        super.prepare()
        
        guard !firstTime else {
            return
        }
        
        guard let hasCollectionView = self.collectionView else {
            return
        }
        
        let collectionViewSize = hasCollectionView.bounds
        print(collectionViewSize)
        
        itemSize = CGSize(width: 150, height: 180)
        self.minimumLineSpacing = spacing
        scrollDirection = .horizontal
        
        firstTime = true
    }
    
    
}
