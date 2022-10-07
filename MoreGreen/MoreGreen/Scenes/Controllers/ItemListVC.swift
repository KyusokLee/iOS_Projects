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
    
    // それぞれのcellのDdayを計算したものが格納される配列
    var dayCount = [[Int]]()
    
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
        
        // DDayの設定のために、currentDateを常に求めるようにした
        fetchCurrentDate()
    }
    
    // ⚠️アプリを開いたときのcurrent dateとitemの賞味期限の差を求め、D-Dayをfetchする
    //ここで、全部currentDateに変える作業をする
    // ただし、fetchDataの後にする
    func fetchCurrentDate() {
        guard !itemList.isEmpty else {
            return
        }
        
        itemList.forEach { item in
            print(item.curDateString ?? "No curDateString")
            print(item.endDate!)
            
            var endDateIntArray = [Int]()
            endDateIntArray = endDateStringSplitToInt(Date: item.endDate)
            
            if endDateIntArray.isEmpty {
                // endDateが""であり、DateIntArrayが[]であったら、dayCount配列に空列[]を格納
                dayCount.append([])
            } else {
                // 年, 月, 日 の3つの要素があれば、ddayを行う
                if endDateIntArray.count == 3 {
                    let customDateComponents = DateComponents(year: endDateIntArray[0], month: endDateIntArray[1], day: endDateIntArray[2])
                    let endDate = Calendar.current.date(from: customDateComponents)!
                    let offsetComps = Calendar.current.dateComponents([.year, .month, .day], from: Date(), to: endDate)
                    if case let (y?, m?, d?) = (offsetComps.year, offsetComps.month, offsetComps.day) {
                        print("\(y)年 \(m)月 \(d)日ほど差があります。")
                        dayCount.append([y, m, d])
                    }
                }
            }
        }
        
        print(dayCount)
    }
    
    func endDateStringSplitToInt(Date endDate: String?) -> [Int] {
        guard let hasEndDate = endDate else {
            return []
        }
        
        if hasEndDate == "" {
            return []
        }
        
        let endDateArray = hasEndDate.split(separator: " ").map { String($0) }
        
        guard endDateArray.count == 3 else {
            return []
        }
        
        let endDateSplitArray = endDateArray.joined().map { String($0) }
        
        var resultIntDateArray = [Int]()
        var year = ""
        var month = ""
        var day = ""
        var index = 0
        
        for i in 0..<endDateSplitArray.count {
            print(endDateSplitArray[i])
            if endDateSplitArray[i] == "年" {
                for j in 0..<i {
                    year += endDateSplitArray[j]
                }
                //　iだと、"年"から始まるので、効率ではないと考えた
                index = i + 1
            } else if endDateSplitArray[i] == "月" {
                for j in index..<i {
                    month += endDateSplitArray[j]
                }
                index = i + 1
            } else if endDateSplitArray[i] == "日" {
                for j in index..<i {
                    day += endDateSplitArray[j]
                }
            } else {
                continue
            }
        }
        
        resultIntDateArray = [Int(year)!, Int(month)!, Int(day)!]
        return resultIntDateArray
    }
    
    func fetchEndDateCount(dayArray array: [Int]) {
        
    }
}

extension ItemListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // coreDataのデータがないと、0になる
        return self.itemList.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        cell.delegate = self
        
        let cellImageData = itemList[indexPath.row].itemImage ?? Data()
        let cellEndPeriod = itemList[indexPath.row].endDate ?? ""
        let cellDayCountArray = dayCount[indexPath.row]
        
        cell.dayCountArray = cellDayCountArray
        
        // ここでは、configureだけした
        // ここで、計算して入れてもいい
        cell.configure(with: cellImageData, hasDate: cellEndPeriod, dayCount: cellDayCountArray)
        
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

extension ItemListVC: ItemCellDelegate {
    func showDetailItemInfo() {
        print("tap detail button")
    }
}
