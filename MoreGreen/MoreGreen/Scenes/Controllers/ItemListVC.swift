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
    var buttonCell = ButtonCell()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        registerCell()
        buttonCell.delegate = self
    }
    
    func setUpTableView() {
        itemListTableView.delegate = self
        itemListTableView.dataSource = self
        itemListTableView.separatorStyle = .singleLine
        itemListTableView.reloadData()
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
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newItemVC = NewItemVC.init(nibName: "NewItemVC", bundle: nil)
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

// tableViewの更新を行う
extension ItemListVC: ButtonDelegate {
    func didFinishSaveData() {
        // CoreDataの場合
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
