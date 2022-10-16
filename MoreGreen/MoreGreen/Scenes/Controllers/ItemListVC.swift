//
//  ItemListVC.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit
import CoreData
import UserNotifications

// Pushアラームを送るために、UserNotificationsをimport

// itemListから、newItemへの入りでエラーが生じる　(うまく画面が反映されない)
// Ddayは、CurretDayと登録した日付との差を計算する頻繁に変動する値であるため、CoreDataに入れずに計算して、cellをconfigureするlogicにした。

// TODO: ⚠️締切順にtableViewを更新する機能を開発する

enum DisplayType {
    case registerSort
    case endDateSort
}

class ItemListVC: UIViewController {
    
    @IBOutlet weak var itemListTableView: UITableView!
    @IBOutlet weak var itemDisplayTypeSegment: UISegmentedControl! {
        didSet {
            itemDisplayTypeSegment.backgroundColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.3)
            
        }
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var itemList = [ItemList]()
    var itemListCount = 0
    var newItemVC = NewItemVC()
    
    // Defaultは、CoreDataの登録順
    var displayType = DisplayType.registerSort
    
    // alarm 通知のための変数
    // UNUserNotificationCenter : アプリ、または、アプリのextensionからアラームに関連する全ての活動を管理する中央オブジェクトである
    let userNofificationCenter = UNUserNotificationCenter.current()
    
    // それぞれのcellのDdayを計算したものが格納される配列
    var dayCount = [[Int]]()
    
    // EndDate順の時に使う配列
    // MARK: ⚠️Error -> ただのdateだけソートすると、coredataの値が正しく格納されないから、新たなitemListを設けることにした
    var sortedDayCount = [[Int]]()
    var sortedItemList = [ItemList]()
    
    var dateFetchCount = 0
    
    // ⚠️今週に賞味期限が切れるitemの数
    var willEndThisWeekCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        registerCell()
        newItemVC.delegate = self
        setNavigationBar()
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        requestAuthPushNoti()
        fetchData()
        print("今週締切: \(willEndThisWeekCount)")
        requestSendPushNoti()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(itemList)
        print(dateFetchCount)
        fetchData()
        itemListTableView.reloadData()
    }
    
    func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.7)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = textAttributes
        
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func itemDisplayType() {
        if displayType == .registerSort {
            
        } else {
            itemListTableView.reloadData()
        }
    }
    
    // TODO: 🔥最初は、register順にdisplayして、coreDataに格納してから、endDate順のsortができるようにした
    // そのため、coreDateの順番を変えることはできないけど、新たな配列を用いて(ここでは、dayCount)ソートするようにした
    @IBAction func segmentSelect(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            displayType = .registerSort
        case 1:
            displayType = .endDateSort
        default:
            break
        }
        
        let startIndex = IndexPath(row: 0, section: 0)
        self.itemListTableView.scrollToRow(at: startIndex, at: .top, animated: true)
        itemListTableView.reloadData()
    }
    
    // Pushアラームのメソッド
    func requestAuthPushNoti() {
        let pushNotiOptions = UNAuthorizationOptions(arrayLiteral: [.badge, .sound, .alert])
        
        userNofificationCenter.requestAuthorization(options: pushNotiOptions) { (granted, error) in
            if let hasError = error {
                // アラームrequestのError
                print(#function, hasError)
            }
        }
        
    }
    
    // TODO: ⚠️途中の段階
    func requestSendPushNoti() {
        userNofificationCenter.removeAllPendingNotificationRequests()
        
        let alarmContent = UNMutableNotificationContent()
        alarmContent.title = "MoreGreen"
        alarmContent.body = "今日もMoreGreenと一緒に家の商品を管理しませんか？\n"
        alarmContent.body += "今週に賞味期限が切れる商品が \(willEndThisWeekCount)個あります。"
        
        let newNumber = UserDefaults.standard.integer(forKey: "AppBadgeNumber") + 1
        UserDefaults.standard.set(newNumber, forKey: "AppBadgeNumber")
        
        // こうすることで、アラームが来る度に badgeが+1になる
        alarmContent.badge = (newNumber) as NSNumber
        alarmContent.sound = UNNotificationSound.default
        // pushアラームを受けるときに、通知されるデータ
//        //userInfoを用いて、deep linkの実装が可能
//        alarmContent.userInfo = ["targetScene": "splash"]
        
        // TODO: ⚠️DateComponentsの指定 (CoreDataに合わせて設定するつもり)
        // 毎朝、9時00分00秒にalarmがくるように設定した
        let dateComponentsDay = DateComponents(
            calendar: Calendar.current,
            hour: 9,
            minute: 0,
            second: 0
        )

        print(dateComponentsDay)
        print("curDate: \(Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date()))")

        // alarmがtriggerされる時間の設定
        // 特定の時間及び日付にアラーム通知をpushするtrigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponentsDay, repeats: true)
        
        // ⚠️timeIntervalにする場合は、最低限60秒以上じゃないといけないらしい
        // push alarmの通知が正常にくることを確認した
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: true)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: alarmContent, trigger: trigger)
        
        userNofificationCenter.add(request) { (error) in
            if let hasError = error {
                print(hasError.localizedDescription)
            }
        }
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
    
    // fetchDataをした後に、requestSendメソッドを呼び出すようにする
    // ⚠️🔥こうすることで、backGroundでもitemの数を表示することができた
    func fetchData() {
        let fetchRequest: NSFetchRequest<ItemList> = ItemList.fetchRequest()
                
        let context = appDelegate.persistentContainer.viewContext
        do {
            self.itemList = try context.fetch(fetchRequest)
            // ここで、一回sortedItemListもfetchするように
            self.sortedItemList = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        // DDayの設定のために、currentDateを常に求めるようにした
        // CoreData上の問題はなかった -> ItemCellのfetchに問題があるようだ
        // この時点で、itemListにCoreDataのItemListが格納されることになる
        print(itemList)
        print(sortedItemList)
        itemListCount = self.itemList.count
        
        fetchCurrentDate()
        countNearEndDateItem()
    }
    
    // ⚠️アプリを開いたときのcurrent dateとitemの賞味期限の差を求め、D-Dayをfetchする
    // ここで、全部currentDateに変える作業をする
    // ただし、fetchDataの後にする
    func fetchCurrentDate() {
        guard !itemList.isEmpty else {
            return
        }
        
        // ✍️現在の日付をformatterで変換し、また、DateComponentsを用いて、Date型に変える作業を行う
        let timeZone = TimeZone.current
        print(timeZone)
        
        let curDateFormatter = DateFormatter()
        curDateFormatter.dateFormat = "yyyy-MM-dd"
        let curDate = Date()
        print(curDate)
        let nowDateStr = curDateFormatter.string(from: curDate)
        let formattedCurDate = curDateStringToDate(Date: nowDateStr)
        // なぜか、dayが-1されるが、以下のendDateComponentsの部分でもdayが-1されるため、これを使うことにした
        print("変換したDate: \(formattedCurDate)")
        
        //fetchDataするたびに、新しいdate情報がappendされるため、そこの処理を修正する必要がある
        // まだ、dateFetchCountが0のままとときだけ、以下の処理を行う
        if dateFetchCount == 0 {
            
            itemList.forEach { item in
                print(item.curDateString ?? "No curDateString")
                print(item.endDate!)
                
                var endDateIntArray = [Int]()
                endDateIntArray = endDateStringSplitToInt(Date: item.endDate)
                
                if endDateIntArray.isEmpty {
                    // endDateが""であり、DateIntArrayが[]であったら、dayCount配列に空列[]を格納
                    // MARK: ⚠️ 画面が表示されるたびに、新しく追加されるというエラーが出た
                    // ---> 修正中
                    dayCount.append([])
                    dateFetchCount += 1
                } else {
                    // 年, 月, 日 の3つの要素があれば、ddayを行う
                    if endDateIntArray.count == 3 {
                        let customDateComponents = DateComponents(timeZone: timeZone, year: endDateIntArray[0], month: endDateIntArray[1], day: endDateIntArray[2])
                        let endDate = Calendar.current.date(from: customDateComponents)!
                        // ⚠️endDate自体が1日遅れていることに気づいた
                        print("endDate: \(endDate)")
                        
                        // MARK: ⚠️fromのdataを変える必要がある
                        let offsetComps = Calendar.current.dateComponents([.year, .month, .day], from: formattedCurDate, to: endDate)
                        if case let (y?, m?, d?) = (offsetComps.year, offsetComps.month, offsetComps.day) {
                            print("\(y)年 \(m)月 \(d)日ほど差があります。")
                            // d + 1しないと、00時00分を基準にdayを計算するので、例えば 今日が9日で締切が11日である場合、D - 1になる
                            dayCount.append([y, m, d])
                            dateFetchCount += 1
                        }
                    }
                }
            }
        } else {
            // dateFetchを一回行なった後の処理
            // TODO: ⚠️データを削除すると、dateFetchCountが大きくなるから、fetchできないことになる
            // 毎度、dayCount配列をrefresh(初期化)する作業を行う方がより簡単である
            // なぜなら、CoreDataの配列から何番目のデータをdeleteしたのかを特定することが複雑であるためである。
            dayCount = [[Int]]()
            dateFetchCount = 0
            
            for i in 0..<itemList.count {
                var endDateIntArray = [Int]()
                endDateIntArray = endDateStringSplitToInt(Date: itemList[i].endDate)
                
                if endDateIntArray.isEmpty {
                    // endDateが""であり、DateIntArrayが[]であったら、dayCount配列に空列[]を格納
                    // MARK: ⚠️ 画面が表示されるたびに、新しく追加されるというエラーが出た
                    // ---> 修正中
                    dayCount.append([])
                    dateFetchCount += 1
                } else {
                    // 年, 月, 日 の3つの要素があれば、ddayを行う
                    if endDateIntArray.count == 3 {
                        // ⚠️dayを+1しないと、なぜか-1になる
                        let customDateComponents = DateComponents(timeZone: timeZone, year: endDateIntArray[0], month: endDateIntArray[1], day: endDateIntArray[2])
                        let endDate = Calendar.current.date(from: customDateComponents)!
                        let offsetComps = Calendar.current.dateComponents([.year, .month, .day], from: formattedCurDate, to: endDate)
                        if case let (y?, m?, d?) = (offsetComps.year, offsetComps.month, offsetComps.day) {
                            print("\(y)年 \(m)月 \(d)日ほど差があります。")
                            dayCount.append([y, m, d])
                            dateFetchCount += 1
                        }
                    }
                }
            }
        }
        
        // 勝手に追加されないことを確認した
        print(dayCount)
        print(itemListCount)
        print(dateFetchCount)
    }
    
    func curDateStringToDate(Date curDate: String) -> Date {
        // Date()の基本形式は、- (ハイフン)なので、ここで、ハイフンを指定した
        let timeZone = TimeZone.current
        let curDateArray = curDate.split(separator: "-").map { Int(String($0))! }
        
        guard curDateArray.count == 3 else {
            return Date()
        }
        
        let currentDateComponents = DateComponents(timeZone: timeZone, year: curDateArray[0], month: curDateArray[1], day: curDateArray[2])
        let curDate = Calendar.current.date(from: currentDateComponents)!
        
        return curDate
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
        print(endDateSplitArray)
        
        var resultIntDateArray = [Int]()
        var year = ""
        var month = ""
        var day = ""
        var index = 0
        
        for i in 0..<endDateSplitArray.count {
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
                // 日が最後なので、breakする
                break
            } else {
                continue
            }
        }
        
        resultIntDateArray = [Int(year)!, Int(month)!, Int(day)!]
        return resultIntDateArray
    }
    
    // TODO: ⚠️今週に賞味期限が切れるitemを数えて -> alarmに送るためのメソッド
    func countNearEndDateItem() {
        guard !dayCount.isEmpty else {
            return
        }
        
        for i in 0..<dayCount.count {
            guard dayCount[i].count == 3 else {
                continue
            }
            
            if 0 <= dayCount[i][2] && dayCount[i][2] <= 7 {
                willEndThisWeekCount += 1
            } else if dayCount[i][2] < 0 {
                willEndThisWeekCount -= 1
            }
        }
        
        if willEndThisWeekCount < 0 {
            willEndThisWeekCount = 0
        }
        
        // この後、sortCoreDateメソッドを呼び出す
        sortCoreDataByNearestEndDate()
    }
    
    // TODO: ⚠️🔥CoreDataをfetchしてから、賞味期限が早い順に並び替える時に使うためのメソッド
    func sortCoreDataByNearestEndDate() {
        guard !dayCount.isEmpty else {
            return
        }
        
        // 日付のデータがなかったら、dayCountは[]になる
        // sortを行うためのQueue
        let sortQueue = dayCount
        var dateSumQueue = [Int]()
        
        // dayCountの各要素を和を求め、dateSumeQueueにappendする
        for i in 0..<sortQueue.count {
            let sum = sortQueue[i].reduce(0, +)
            dateSumQueue.append(sum)
        }
        
        // tuple型の配列を設ける
        var dateSumArray = [(index: Int, sum: Int)]()
        
        // indexは、dayの和をdateSumArrayに格納する
        for i in 0..<dateSumQueue.count {
            // indexとsumを格納する
            dateSumArray.append((i, dateSumQueue[i]))
        }
        
        // TODO: ⚠️dateSumArrayをindexの和が小さい順にsortする
        dateSumArray.sort(by: { $0.sum < $1.sum })
        
        while dateSumArray.first?.sum == 0 {
            let firstValue = dateSumArray.removeFirst()
            dateSumArray.append(firstValue)
        }
        
        print(dateSumArray)
        
        // 上記までは、正しくソートされている
        
        //TODO: 🔥次は、itemListのデータをdateSumArrayのindexに合わせて並び替えを行う
        // sortedDayCountも、tableViewのreloadに使うため、ここで、データを格納するようにした
        sortedDayCount = Array(repeating: Array(repeating: Int(), count: 3), count: itemList.count)
        
        // MARK: ⚠️Error -> sortedItemListでは、coreDataが指定されない問題が生じた
        for i in 0..<itemList.count {
            sortedItemList[i] = itemList[dateSumArray[i].index]
            sortedDayCount[i] = sortQueue[dateSumArray[i].index]
        }
        
        print(sortedDayCount)
        print(sortedItemList)
    }
}

extension ItemListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // coreDataのデータがないと、0になる
        
        // displayTypeに合わせて、異なるデータを表示する
        if self.displayType == .registerSort {
            return self.itemList.count
        } else {
            return self.sortedItemList.count
        }
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
        
        var cellImageData = Data()
        var cellEndPeriod = ""
        var cellDayCountArray = [Int]()
        
        if displayType == .registerSort {
            cellImageData = itemList[indexPath.row].itemImage ?? Data()
            cellEndPeriod = itemList[indexPath.row].endDate ?? ""
            cellDayCountArray = dayCount[indexPath.row]
        } else {
            cellImageData = sortedItemList[indexPath.row].itemImage ?? Data()
            cellEndPeriod = sortedItemList[indexPath.row].endDate ?? ""
            cellDayCountArray = sortedDayCount[indexPath.row]
        }
        
        // ここでは、configureだけした
        // ここで、計算して入れてもいい
        cell.configure(with: cellImageData, hasDate: cellEndPeriod, dayCount: cellDayCountArray)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newItemVC = UIStoryboard(name: "NewItemVC", bundle: nil).instantiateViewController(withIdentifier: "NewItemVC") as! NewItemVC
        
        newItemVC.delegate = self
        
        if displayType == .registerSort {
            newItemVC.selectedItemList = itemList[indexPath.row]
        } else {
            newItemVC.selectedItemList = sortedItemList[indexPath.row]
        }
        
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
        self.fetchData()
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
