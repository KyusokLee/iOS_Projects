//
//  ItemListVC.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit
import CoreData

class ItemListVC: UIViewController {
    
    @IBOutlet weak var itemListTableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var itemList = [ItemList]()
    var newItemVC = NewItemVC()
    var isTrue = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        registerCell()
        newItemVC.delegate = self
//        newItemVC.makeDelegate = self
        fetchData()
        itemListTableView.reloadData()
    }
    
    // TableViewをIBOutletにしたので、viewが現れないと delegateできない
    func setUpTableView() {
        itemListTableView.delegate = self
        itemListTableView.dataSource = self
        itemListTableView.separatorStyle = .singleLine
    }
    
    func registerCell() {
        itemListTableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
    }
    
    func fetchData() {
        let fetchRequest: NSFetchRequest<ItemList> = ItemList.fetchRequest()
                
        let context = appDelegate.persistentContainer.viewContext
        do {
            self.itemList = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
    }

}

extension ItemListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // coreDataのデータがないと、0になる
        return self.itemList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        cell.itemEndPeriod.text = itemList[indexPath.row].endDate
        cell.itemImageView.image = UIImage(data: itemList[indexPath.row].itemImage ?? Data())
        
        if let dateString = itemList[indexPath.row].endDate {
            let formatter = ISO8601DateFormatter()
            
            if let isoDate = formatter.date(from: dateString) {
                let customFormatter = DateFormatter()
                customFormatter.dateFormat = "yyyy年 MM月 dd日"
                
                let customDateString = customFormatter.string(from: isoDate)
                
                cell.itemEndPeriod.text = customDateString
            }
            
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newItemVC = UIStoryboard(name: "NewItemVC", bundle: nil).instantiateViewController(withIdentifier: "NewItemVC") as! NewItemVC
        
        newItemVC.delegate = self
        newItemVC.selectedItemList = itemList[indexPath.row]
        
        let navigationNewItemVC = UINavigationController(rootViewController: newItemVC)
        
        navigationNewItemVC.modalPresentationCapturesStatusBarAppearance = true
        // fullScreenで表示させる方法
        navigationNewItemVC.modalPresentationStyle = .fullScreen
        
        self.present(navigationNewItemVC, animated: true) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// tableViewの更新を行う
extension ItemListVC: NewItemVCDelegate {
    func addNewItemInfo() {
        print("add New Item On List!")
        self.fetchData()
        self.itemListTableView.reloadData()
        updateViewConstraints()
    }
}

// tableViewの更新を行う
extension ItemListVC: ButtonDelegate {
    func didFinishSaveData() {
        // CoreDataの場合
        print("from button delegate: add new Item!")
        self.fetchData()
        self.itemListTableView.reloadData()
        updateViewConstraints()
    }

    func didFinishUpdateData() {
        self.itemListTableView.reloadData()
        updateViewConstraints()
    }

    func didFinishDeleteData() {
        self.itemListTableView.reloadData()
        updateViewConstraints()
    }
}
