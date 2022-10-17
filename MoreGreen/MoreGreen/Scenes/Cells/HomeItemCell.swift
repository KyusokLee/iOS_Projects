//
//  HomeItemCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/10/16.
//

import UIKit

class HomeItemCell: UITableViewCell {

    @IBOutlet weak var itemCollectionView: UICollectionView!
    private var sortedItemList = [ItemList]()
    
    private let cellWidth: Int = 150
    private let cellHeight: Int = 180
    private let cellSpacing: Int = 15
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func registerXib() {
        itemCollectionView.register(UINib(nibName: "HomeItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HomeItemCollectionViewCell")
    }
    
    private func setCollectionView() {
        itemCollectionView.delegate = self
        itemCollectionView.dataSource = self
        itemCollectionView.decelerationRate = .fast
        itemCollectionView.showsHorizontalScrollIndicator = false
    }
    
    // collectionViewに入れるデータをここで、configure
    func configure(with model: [ItemList]) {
        self.sortedItemList = model
        itemCollectionView.reloadData()
    }
    
}

extension HomeItemCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedItemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeItemCollectionViewCell", for: indexPath) as! HomeItemCollectionViewCell
        let item = sortedItemList[indexPath.row]
        
        cell.configure(userDate: item)
        
        return cell
    }
    
    
}
