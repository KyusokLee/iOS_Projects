//
//  HomeItemCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/10/16.
//

import UIKit

// HomeVCの今週中賞味期限が切れるitemListに表示するTableViewCell
// Cellの中に、CollectionViewを設け、その中にitemのCollectionViewCellを格納した
class HomeItemCell: UITableViewCell {

    @IBOutlet weak var itemCollectionView: UICollectionView!
    private var filteredItemList = [ItemList]()
    private var filteredDayCount = [Int]()
    
    private let cellWidth: Int = 150
    private let cellHeight: Int = 180
    private let cellSpacing: Int = 15
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerXib()
        setCollectionView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func registerXib() {
        itemCollectionView.register(UINib(nibName: "HomeItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeItemCollectionViewCell")
    }
    
    private func setCollectionView() {
        // customFlowLayoutの代わりに、delegateFlowLayoutを用いた
//        let customFlowLayout = CarouselFlowLayout()
//
//        itemCollectionView.collectionViewLayout = customFlowLayout
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
        itemCollectionView.decelerationRate = .fast
        itemCollectionView.showsHorizontalScrollIndicator = false
    }
    
    // collectionViewに入れるデータをここで、configure
    func configure(with model: [ItemList], dayArray array: [Int]) {
        self.filteredItemList = model
        self.filteredDayCount = array
        
        print("filteredDayCount: \(filteredDayCount)")
        
        itemCollectionView.reloadData()
    }
    
}

extension HomeItemCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredItemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeItemCollectionViewCell", for: indexPath) as! HomeItemCollectionViewCell
        let item = filteredItemList[indexPath.row]
        let dayDifference = filteredDayCount[indexPath.row]

        cell.configure(userData: item, dayDifference: dayDifference)
        
        return cell
    }
    
}

extension HomeItemCell: UICollectionViewDelegateFlowLayout {
    // CollectionView Cellのsize設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 210)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}
