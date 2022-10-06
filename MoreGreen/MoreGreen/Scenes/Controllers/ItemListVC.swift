//
//  ItemListVC.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit
import CoreData

// itemListから、newItemへの入りでエラーが生じる　(うまく画面が反映されない)
// Ddayは、CurretDayと登録した日付との差を計算する頻繁に変動する値であるため、CoreDataに入れずに計算して、cellをconfigureするlogicにした。

// TODO: ⚠️新しく作成したItemcellが直ちに反映されないことがある

class ItemListVC: UIViewController {
    
    @IBOutlet weak var itemListTableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var itemList = [ItemList]()
    var newItemVC = NewItemVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        registerCell()
        newItemVC.delegate = self
//        newItemVC.makeDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        fetchCurrentDate()
    }
    
    // ⚠️アプリを開いたときのcurrent dateとitemの賞味期限の差を求め、D-Dayをfetchする
    //ここで、全部currentDateに変える作業をする
    // ただし、fetchDataの後にする
    func fetchCurrentDate() {
        guard !itemList.isEmpty else {
            return
        }
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
        
        itemList.forEach { item in
            print(item.curDate!)
            print(item.endDate!)
//            if let hasCurDate = item.curDate {
//                let dateString = formatter.string(from: hasCurDate)
//                item.curDate = formatter.date(from: dateString)
//                print(item.curDate)
//            }
        }
    }
}

extension ItemListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // coreDataのデータがないと、0になる
        return self.itemList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        let cellImageData = itemList[indexPath.row].itemImage ?? Data()
        let cellEndPeriod = itemList[indexPath.row].endDate ?? ""
        
        cell.configure(with: cellImageData, hasDate: cellEndPeriod)
        
        
//        if let dateString = itemList[indexPath.row].endDate {
//            let formatter = ISO8601DateFormatter()
//            
//            if let isoDate = formatter.date(from: dateString) {
//                let customFormatter = DateFormatter()
//                customFormatter.dateFormat = "yyyy年 MM月 dd日"
//                
//                let customDateString = customFormatter.string(from: isoDate)
//                
//                cell.itemEndPeriod.text = customDateString
//            }
//            
//        }
        
        
        
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
