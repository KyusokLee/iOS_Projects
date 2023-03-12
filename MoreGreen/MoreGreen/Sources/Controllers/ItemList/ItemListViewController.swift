//
//  ItemListViewController.swift
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

// TODO: 🔥⚠️Sticky Tab layout header viewを実装する予定
// ちょっと難しい
// 全体、開封済み、消費済み、期限切れの準にするつもり

// MARK: 🔥TableViewの横方向のscrollは、collectionViewの方が効率的
// TODO: 🔥Paging機能を実装するため、tableViewの代わりにcollectionViewを導入する予定 -> 途中の段階
// --> PagingCollectionViewにitemとしてItemListを入れる仕組み
// TODO: ⚠️🔥　(途中の段階)_ pin固定の状態をapp自体に保存させたいので、CoreDataを用いる
protocol PagingTabbarDelegate: AnyObject {
    func scrollToIndex(to index: Int)
}

enum DisplayType {
    case registerSort
    case endDateSort
}

class ItemListViewController: UIViewController {
    @IBOutlet weak var categoryTabbarView: CategoryTabbar! {
        didSet {
            categoryTabbarView.delegate = self
        }
    }
    @IBOutlet weak var indicatorView: UIView! {
        didSet {
            indicatorView.backgroundColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.9)
        }
    }
    
    @IBOutlet weak var indicatorLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var itemListTableView: UITableView!
    @IBOutlet weak var itemDisplayTypeSegment: UISegmentedControl! {
        didSet {
            itemDisplayTypeSegment.backgroundColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.3)
            
        }
    }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    var pageViewController = UIPageViewController()
//    var pageModel = PageModel()
//    let tabsCount = 4
////    let tabsCount = 4; #warning ("< 1 causes Crash!")
    
    var itemList = [ItemList]()
    var itemListCount = 0
    var newItemViewController = NewItemViewController()
    
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
    
    // TODO: 🔥⚠️CoreDataに格納されているindexとpinされたかどうかを格納するためのtuple型の配列
    var pinnedQueue = [(index: Int, pinned: Bool)]()
    var pinnedItemList = [ItemList]()
    
    // TODO: ⚠️今週内 (7日以内)に賞味期限が切れる商品のデータだけを格納する配列
    var itemsWillEndList = [ItemList]()
    var dateFetchCount = 0
    
    // ⚠️今週に賞味期限が切れるitemの数
    var willEndThisWeekCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        registerXib()
        newItemViewController.delegate = self
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
        
        DispatchQueue.main.async {
            self.itemListTableView.reloadData()
        }
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
    
    // MARK: ⚠️処理logicを追加する予定
    func itemDisplayType() {
        if displayType == .registerSort {
            itemListTableView.reloadData()
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
        
        // CoreDataに何も格納されてないのであれば、Scrollの処理を無視するように
        // 理由: tableViewに何も入っていないと、scrollToRowがcrackを発生する
        if !itemList.isEmpty {
            let startIndex = IndexPath(row: 0, section: 0)
            self.itemListTableView.scrollToRow(at: startIndex, at: .top, animated: true)
        }
        
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
        
        // MARK: ⚠️ここで、badgeの数が思う通りに表示されないエラーが生じた
        // 今後、修正するつもり
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
    
    func registerXib() {
        itemListTableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
    }
    
//    func setUpPagingViewController() {
//        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
//        pageViewController.dataSource = self
//        pageViewController.delegate = self
//    }
    
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
        
        // MARK: ⚠️ここの部分修正する必要ある
        if willEndThisWeekCount < 0 {
            willEndThisWeekCount = 0
        }
        
        // この後、sortCoreDateメソッドを呼び出す
        sortCoreDataByNearestEndDate()
    }
    
    //🔥CoreDataをfetchしてから、賞味期限が早い順に並び替える時に使うためのメソッド
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
        // 期限が過ぎたら、一番上に出てくる
        dateSumArray.sort(by: { $0.sum < $1.sum })
        // dataがないitem情報を格納した配列
        var noEndDateArray = [(index: Int, sum: Int)]()
        // endDateが過ぎているものの配列
        var overEndDateArray = [(index: Int, sum: Int)]()
        // 🔥while文を効率よく回すためのindex
        var index = 0
        
        while !dateSumArray.isEmpty && dateSumArray[index].sum <= 0 {
            if dateSumArray[index].sum == 0 && sortQueue[dateSumArray[index].index].isEmpty {
                // EndDateのものがない要素の処理
                let firstValue = dateSumArray.remove(at: index)
                noEndDateArray.append(firstValue)
            } else if dateSumArray.first!.sum < 0 {
                // 賞味期限がもう切れているものの処理
                let firstValue = dateSumArray.removeFirst()
                // 先頭から入れることで、D + 2のitemが D + 1の後ろに来る
                overEndDateArray.insert(firstValue, at: 0)
            } else if dateSumArray[index].sum == 0 && !sortQueue[dateSumArray[index].index].isEmpty {
                // EndDateの情報が入っており、dateSumArrayのsumが0である
                //MARK: ⚠️Error->最初から d-0であり、dataがあるものだったら、処理を終了させることになる
                index += 1
                // TODO: ⚠️ ここで、index out of range error が生じた
                // 理由: sumが0の要素が一番最後にあるとき、errorが生じたと考える
                // 🌈解決: whileの条件に !dateSumArray.isEmptyを書くことで、エラーを無くした
                if dateSumArray[index].sum > 0 {
                    // 次の要素のsumが０より大きかったら、while文を出る
                    break
                } else {
                    // 次の要素のsumが0であるか、または、０より小さかったら、while文をcontinueする
                    continue
                }
            }
        }
       
        // 先に endDateが過ぎているものをdateSumArrayに足す
        if !overEndDateArray.isEmpty {
            dateSumArray += overEndDateArray
        }
        
        // EndDateがないものを一番下に入れる
        // 何も入っていないときは、処理を無視するように
        if !noEndDateArray.isEmpty {
            dateSumArray += noEndDateArray
        }
        
        //TODO: 🔥次は、itemListのデータをdateSumArrayのindexに合わせて並び替えを行う
        // sortedDayCountも、tableViewのreloadに使うため、ここで、データを格納するようにした
        sortedDayCount = Array(repeating: Array(repeating: Int(), count: 3), count: itemList.count)
        
        // MARK: ⚠️Error -> sortedItemListでは、coreDataが指定されない問題が生じた
        for i in 0..<itemList.count {
            sortedItemList[i] = itemList[dateSumArray[i].index]
            sortedDayCount[i] = sortQueue[dateSumArray[i].index]
        }
    }
    
    // TODO: 途中の段階⚠️_🔥pinのボタンを押されたら呼び出されるメソッド
    // 既存のtableViewから当てはまるindexを削除し、そのデータを一番上に格納する作業
    // CoreDataと関わっているため、複雑
    func sortCoreDateByPinState() {
        // displayTypeによって、固定されるCellのcoreDataは異なるデータが格納されている
        if displayType == .registerSort {
            
        } else {
            
        }
        
        
    }
    
    // swipeでdeleteを押したら呼び出されるメソッド
    func setDeleteCellAlert(selectedItem item: ItemList) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "商品のデータを消しますか?", preferredStyle: .alert)
        let back = UIAlertAction(title: "戻る", style: .cancel) { _ in
            print("modoru!")
        }
        
        let delete = UIAlertAction(title: "削除", style: .destructive) { _ in
            print("delete!")
            self.doCellDelete(selectedItem: item)
        }
        
        alert.addAction(back)
        alert.addAction(delete)
        
        return alert
    }
    
    func doCellDelete(selectedItem item: ItemList) {
        guard let hasUUID = item.uuid else {
            return
        }
        
        let fetchRequest: NSFetchRequest<ItemList> = ItemList.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
        
        do {
            let loadedData = try context.fetch(fetchRequest)
            if let loadFirstData = loadedData.first {
                context.delete(loadFirstData)
                appDelegate.saveContext()
            }
        } catch {
            print(error)
        }
        
        self.fetchData()
        self.itemListTableView.reloadData()
        updateViewConstraints()
    }
}

extension ItemListViewController: UITableViewDelegate, UITableViewDataSource {
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
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        cell.delegate = self
        
        var cellItemName = ""
        var cellImageData = Data()
        var cellEndPeriod = ""
        var cellDayCountArray = [Int]()
        
        // TODO: ⚠️Ddayの状況に合わせて、cellの背景色を違くする処理を追加
        
        if displayType == .registerSort {
            cellItemName = itemList[indexPath.row].itemName ?? ""
            cellImageData = itemList[indexPath.row].itemImage ?? Data()
            cellEndPeriod = itemList[indexPath.row].endDate ?? ""
            cellDayCountArray = dayCount[indexPath.row]
            
            let daySum = cellDayCountArray.reduce(0, +)
            
            // ⚠️ERROR: itemCellでbackgroundColorを行うと、正しく表示されない
            // 🌈解決策: ここで、背景色の設定を行うようにした
            if daySum < 0 {
                cell.backgroundColor = UIColor(rgb: 0x751717).withAlphaComponent(0.1)
            } else if daySum == 0 {
                if cellDayCountArray.isEmpty {
                    cell.backgroundColor = UIColor.white
                } else {
                    cell.backgroundColor = UIColor(rgb: 0xFFB74D).withAlphaComponent(0.1)
                }
            } else {
                cell.backgroundColor = UIColor.white
            }
        } else {
            cellItemName = sortedItemList[indexPath.row].itemName ?? ""
            cellImageData = sortedItemList[indexPath.row].itemImage ?? Data()
            cellEndPeriod = sortedItemList[indexPath.row].endDate ?? ""
            cellDayCountArray = sortedDayCount[indexPath.row]
            
            let daySum = cellDayCountArray.reduce(0, +)
            
            // ⚠️ERROR: ここでbackgroundColorを行うと、正しく表示されない
            // 🌈解決策: cell.configureで背景の色も行うようにする
            if daySum < 0 {
                cell.backgroundColor = UIColor(rgb: 0x751717).withAlphaComponent(0.1)
            } else if daySum == 0 {
                if cellDayCountArray.isEmpty {
                    cell.backgroundColor = UIColor.white
                } else {
                    cell.backgroundColor = UIColor(rgb: 0xFFB74D).withAlphaComponent(0.1)
                }
            } else {
                cell.backgroundColor = UIColor.white
            }
        }
        
        // ここでは、configureだけした
        // ここで、計算して入れてもいい
        cell.configure(with: cellImageData, hasItemName: cellItemName, hasDate: cellEndPeriod, dayCount: cellDayCountArray)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = UIStoryboard(name: "NewItem", bundle: nil).instantiateViewController(withIdentifier: "NewItemViewController") as? NewItemViewController else {
            fatalError("NewItemViewController could not be found")
        }
        controller.delegate = self
        if displayType == .registerSort {
            controller.selectedItemList = itemList[indexPath.row]
        } else {
            controller.selectedItemList = sortedItemList[indexPath.row]
        }
        let navigationNewItemVC = UINavigationController(rootViewController: controller)
        navigationNewItemVC.modalPresentationCapturesStatusBarAppearance = true
        // fullScreenで表示させる方法
        navigationNewItemVC.modalPresentationStyle = .fullScreen
        self.present(navigationNewItemVC, animated: true) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    // 🔥TableView CellのSwipe処理に関するメソッド
    // 左スワイプ (1: 固定, 2: 未定??)
    // 削除する時は、alertも一緒に表示するように
    // 実装完了
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // tableViewは共通のものであるため、indexPathの指定は、分岐しなくてもいいようだ
        // しかし、そのCellにPinのイメージを反映しないといけないので、cellの指定が必要
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        if displayType == .registerSort {
            print(indexPath.row)
        } else {
            print(indexPath.row)
        }
        let fix = UIContextualAction(style: .normal, title: nil) { (action, view, completion) in
            if cell.pinState == .normal {
                print("fix!")
                cell.pinState = .pinned
            } else {
                print("no fix!")
                cell.pinState = .normal
            }
            // itemListを並び変える作業をする
            // -> pinされたものを一番上に表示
            // ->　pinされたものを元の位置に戻す作業は、fetchの部分で行う
            completion(true)
        }
        
        if cell.pinState == .normal {
            fix.image = UIImage(systemName: "pin.fill")?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
            fix.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.7)
        } else {
            fix.image = UIImage(systemName: "pin.slash.fill")?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
            fix.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.7)
        }
        let actionConfigure = UISwipeActionsConfiguration(actions: [fix])
        actionConfigure.performsFirstActionWithFullSwipe = false
        
        return actionConfigure
    }
    
    // 右スワイプ (1:消費済み、2:削除)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var targetItem: ItemList?
        
        let delete = UIContextualAction(style: .destructive, title: "削除") { (action, view, completion) in
            print("delete")
            if self.displayType == .registerSort {
                targetItem = self.itemList[indexPath.row]
                self.present(self.setDeleteCellAlert(selectedItem: targetItem!), animated: true)
            } else {
                targetItem = self.sortedItemList[indexPath.row]
                self.present(self.setDeleteCellAlert(selectedItem: targetItem!), animated: true)
            }
            
//            self.present(setDeleteCellAlert(selectedItem: targetItem), animated: true)
            completion(true)
        }
        
        // 消費済みを押すと、cellになんらかのUIを表示するようにしたい
        let isConsumpted = UIContextualAction(style: .normal, title: "消費済み") { (action, view, completion) in
            print("is consumpted")
            completion(true)
        }
        
        isConsumpted.backgroundColor = UIColor(rgb: 0x388E3C).withAlphaComponent(0.7)
        
        let actionConfigure = UISwipeActionsConfiguration(actions: [delete, isConsumpted])
        actionConfigure.performsFirstActionWithFullSwipe = false
        
        return actionConfigure
    }
}

//// pagingVC関連メソッド
//extension ItemList: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
//    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        if let currentVCIndex = pageModel.pages {
//
//        }
//    }
//
//    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        <#code#>
//    }
//
//
//}

// tableViewの更新を行う
extension ItemListViewController: NewItemViewControllerDelegate {
    func addNewItemInfo() {
        print("add New Item On List!")
        self.fetchData()
        self.itemListTableView.reloadData()
        updateViewConstraints()
    }
}

// tableViewの更新を行う
extension ItemListViewController: ButtonDelegate {
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

extension ItemListViewController: ItemCellDelegate {
    func showDetailItemInfo() {
        print("tap detail button")
    }
}

// 該当のイベントを受け取るVCから処理を行う
// TODO: 🔥⚠️ここの部分で、Tabbar indicatorの動きが呼び出されていることがわかる
// このメソッドで、Tabbar Tapに関するイベントを明記すること
extension ItemListViewController: PagingTabbarDelegate {
    // Tabbarをclickしたとき、contents Viewを移動する
    func scrollToIndex(to index: Int) {
        print("click", index)
        indicatorLeadingConstraint.constant = itemDisplayTypeSegment.bounds.width * CGFloat(index) / 3
        itemListTableView.reloadData()
        itemListTableView.layoutIfNeeded()
    }
}

// Tabbar CollectionView 関連メソッド
extension ItemListViewController: UICollectionViewDelegateFlowLayout {
    // Scrollが実行されるとき、indicator Viewを移動させる
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 単純に中身をscrollするとき、indicator Viewを移動させるメソッド
        print("Slide Scroll Event is implemented")
        indicatorLeadingConstraint.constant = scrollView.contentOffset.x / 3
        print(indicatorLeadingConstraint.constant)
    }
    
    // Scrollが終わったとき、ページを計算してTabを移動させる
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let page = Int(targetContentOffset.pointee.x / scrollView.frame.width)
        categoryTabbarView.scroll(to: page)
    }
    
//    // MARK: ⚠️まだ、PageCollectionViewは実装完了してない
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: pageCollectionView.bounds.width, height: pageCollectionView.bounds.height)
//    }
    
}

