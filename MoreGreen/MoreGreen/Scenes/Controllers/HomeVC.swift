//
//  HomeVC.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit

// TODO: ⚠️Home VCの方で、Layout 警告がでてる
// heightを消すことで、一つのエラーを無くなった
// ⚠️しかし、まだ、contentOffsetの方で警告が出てる
// ⚠️Error : section 0で、headerとfooterが現れるエラーが発生した
// heightが0だと、tableViewの特性上、基本のdefaultの値として認識されたのが原因だった

class HomeVC: UIViewController {
    
    @IBOutlet weak var homeTableView: UITableView!
    var itemList = [ItemList]()
    var sortedItemList = [ItemList]()
    var itemListCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("this is home view")
        setUpTableView()
        registerCell()
        homeTableView.reloadData()
        updateViewConstraints()
    }
        
    func setUpTableView() {
        homeTableView.delegate = self
        homeTableView.dataSource = self
//        homeTableView.separatorStyle = .none
        homeTableView.sectionHeaderTopPadding = .zero
        homeTableView.sectionFooterHeight = .zero
    }
    
    func registerCell() {
        homeTableView.register(UINib(nibName: "HomeCardViewCell", bundle: nil), forCellReuseIdentifier: "HomeCardViewCell")
        homeTableView.register(UINib(nibName: "HomeItemCell", bundle: nil), forCellReuseIdentifier: "HomeItemCell")
        // Custom Headerのregister
        homeTableView.register(UINib(nibName: "HomeCustomHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "HomeCustomHeader")
    }


}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // sectionの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return UITableView.automaticDimension
        case 1:
            return UITableView.automaticDimension
        default:
            return 0
        }
    }
    
    // sectionごとのheaderの高さの設定
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 50
        } else {
            return homeTableView.sectionHeaderTopPadding
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            // これを200にすると、すごい警告でるのに、TablieViewCellのnibで設定したcellの高さより大きくすると、errorが出なくなった
            // 理由: estimatedHeightは見積りで実際の値より大きくすることで、パソコンが認識することが可能となるっぽい
            // この見積もりの値と実際の値を比較し、調整を行う流れになるようだ
            return 250
        case 1:
            return 200
        default:
            return 0
        }
    }
    
    // ここらへんでちょっとエラーが生じる
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0:
            return nil
        case 1:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HomeCustomHeader") as! HomeCustomHeader
            
            //ios14以降のbackground colorの設定方法
            var backgroundConfiguration = UIBackgroundConfiguration.listPlainHeaderFooter()
            backgroundConfiguration.backgroundColor = UIColor.white
            header.backgroundConfiguration = backgroundConfiguration
            
            return header
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCardViewCell", for: indexPath) as! HomeCardViewCell
            cell.selectionStyle = .none

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeItemCell", for: indexPath) as! HomeItemCell
            // sortedされたItemListを渡す
            cell.configure(with: sortedItemList)
            
            
            cell.selectionStyle = .none

            return cell
        default:
            return UITableViewCell()
        }
    }
}

