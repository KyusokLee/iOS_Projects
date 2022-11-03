//
//  HomeItemCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/10/16.
//

import UIKit

// HomeVCの今週中賞味期限が切れるitemListに表示するTableViewCell
// Cellの中に、CollectionViewを設け、その中にitemのCollectionViewCellを格納した

// MARK: TableViewCellであるこのファイルでEmpty Viewの表示と非表示に関するロジックを処理する


class HomeItemCell: UITableViewCell {

    @IBOutlet weak var itemCollectionView: UICollectionView!
    
    @IBOutlet weak var emptyDataView: UIView! {
        didSet {
            self.emptyDataView.backgroundColor = .clear
            setShowEmptyView()
        }
    }
    
    @IBOutlet weak var emptyViewMainLabel: UILabel! {
        didSet {
            emptyViewMainLabel.text = "まだ、登録された商品がありません"
            emptyViewMainLabel.textColor = UIColor.systemGray.withAlphaComponent(0.6)
            emptyViewMainLabel.font = .systemFont(ofSize: 15, weight: .bold)
        }
    }
    
    @IBOutlet weak var emptyViewSubDescription: UILabel! {
        didSet {
            // labelのconstraintsは、text文の中の"登録し、"が１行の最後に来るように事前に設定した
            emptyViewSubDescription.text = "下記の➕ボタンで、新しい商品を登録し、賞味期限を管理してみましょう！"
            emptyViewSubDescription.textColor = UIColor.systemGray.withAlphaComponent(0.6)
            emptyViewSubDescription.font = .systemFont(ofSize: 13, weight: .medium)
        }
    }
    
    
    private var filteredItemList = [ItemList]()
    private var filteredDayCount = [Int]()
    
    private let cellWidth: Int = 150
    private let cellHeight: Int = 180
    private let cellSpacing: Int = 15
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerXib()
        setCollectionView()
        itemCollectionView.reloadData()
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
    
    // TODO: 🔥新しくnibファイルとコードを作成する方より、ここで、dataがあるかないかによってviewをhidden処理するのが効率的である
    // Error⚠️: View自体がhiddenになるけど、上に載せたlabelなどがhiddenされないerrorがあった
    private func setShowEmptyView() {
        if self.filteredItemList.isEmpty {
            self.emptyDataView.isHidden = false
        } else {
            self.emptyDataView.isHidden = true
        }
        
        self.emptyDataView.layoutIfNeeded()
    }
    
    // collectionViewに入れるデータをここで、configure
    func configure(with model: [ItemList], dayArray array: [Int]) {
        self.filteredItemList = model
        self.filteredDayCount = array
        
        print("filteredItemList: \(filteredItemList)")
        print("filteredDayCount: \(filteredDayCount)")
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
