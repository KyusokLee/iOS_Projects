//
//  HomeViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit
import CoreData

// 📚MARK: 以下error修正ノート
// ⚠️Home VCの方で、Layout 警告がでてる
// heightを消すことで、一つのエラーを無くなった
// ⚠️しかし、まだ、contentOffsetの方で警告が出てる
// ⚠️Error : section 0で、headerとfooterが現れるエラーが発生した
// heightが0だと、tableViewの特性上、基本のdefaultの値として認識されたのが原因だった

// MARK: 🔥もっと、綺麗なコードにrefactoringする予定 -> itemListのCoreData反映から、表示させたいCoreDataだけをHomeVCに表示したい
// 解決策: CoreDataをfilteringすれば、いい話だった！
// 方法: CoreDataのUpdateする時によく使う -> Predicateを用いてfetchする
// TODO: 1_Sticky header viewを実装する予定
// TODO: 3_TableViewの3番目のcellには、グラフ統計を見せる予定
// TODO: 4_ HomeVCのところで、Push アラームをするようにしたい
// -> 理由: 7日以内に締め切れる商品だけアラーム通知するようにするには、ItemListVCよりここのVCでの処理がより簡単である

class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeTableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // 元となるCoreDataをfetchするための、配列
    var itemList = [ItemList]()
    // TODO: CoreData自体をfilterすることにした
    // 今週内 (7日以内)に賞味期限が切れる商品のデータだけを格納する配列
    var filteredItemList = [ItemList]()
    var itemListCount = 0
    // それぞれのcellのDdayを計算したものが格納される配列
    var dayCount = [[Int]]()
    // EndDate順の時に使う配列
    // MARK: - Error -> ただのdateだけソートすると、coredataの値が正しく格納されないから、新たなitemListを設けることにした
    // 元となるCoreDataの要素から、7日以内に賞味期限が切れる商品のdayCountだけを抽出して格納するための２次元配列
    // あえて、2次元配列にする必要があるかが疑問
    // ただの1次元配列にすると、メモリの時間計算量的により効率である
    // filteredDayCountをTableViewCellに引き渡し、CollectionViewCellのLayoutを設定するようにする
    var filteredDayCount = [Int]()
    // CoreDataに格納されているindexと日の差だけを格納するためのtuple型の配列
    var dayQueue = [(index: Int, dayDifference: Int)]()
    var willEndThisWeekCount = 0
    var dateFetchCount = 0
    var filterDateFetchCount = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("this is home view")
        setNavigationBar()
        setTableView()
        registerXib()
//        fetchData()
//        homeTableView.reloadData()
//        updateViewConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 画面が表示される度にfetchDataを行う
        fetchData()
        homeTableView.reloadData()
        updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // ⚠️navigationBarのappearanceはApp全体に共通して反映したいので、他のfileとして作った方がいいかもと思う
    private func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        // MARK: - AppAppearanceの実装で、ここでの実装はしなくてもよくなった
//        appearance.backgroundColor = UIColor.white
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.black.withAlphaComponent(0.7)]
        
        // .noneではなく、""でbackButtonのtitleを無くす
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.compactAppearance = appearance
        self.navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.prefersLargeTitles = false
        // navigationBarにアイテム
        let settingImage = UIImage(systemName: "gearshape")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        let settingBarButton = UIBarButtonItem(image: settingImage, style:.plain, target: self, action: #selector(tapSettingBarButton))
        self.navigationItem.title = "Home"
        self.navigationItem.rightBarButtonItem = settingBarButton
    }
        
    private func setTableView() {
        homeTableView.delegate = self
        homeTableView.dataSource = self
//        homeTableView.separatorStyle = .none
        homeTableView.sectionHeaderTopPadding = .zero
        homeTableView.sectionFooterHeight = .zero
    }
    
    private func registerXib() {
        homeTableView.register(UINib(nibName: "HomeCardViewCell", bundle: nil), forCellReuseIdentifier: "HomeCardViewCell")
        homeTableView.register(UINib(nibName: "HomeItemCell", bundle: nil), forCellReuseIdentifier: "HomeItemCell")
        // Custom Headerのregister
        homeTableView.register(UINib(nibName: "HomeCustomHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "HomeCustomHeader")
    }
    
    // coreDataからデータを抽出するためのlogic
    //　まずは、CoreDataをfetch
    func fetchData() {
        let fetchRequest: NSFetchRequest<ItemList> = ItemList.fetchRequest()
        let context = appDelegate.persistentContainer.viewContext
        do {
            self.itemList = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        // DDayの設定のために、currentDateを常に求めるようにした
        // CoreData上の問題はなかった -> ItemCellのfetchに問題があるようだ
        // この時点で、itemListにCoreDataのItemListが格納されることになる
        print(itemList)
        itemListCount = self.itemList.count
        fetchCurrentDate()
        countNearEndDateItem()
    }
    
    func fetchCurrentDate() {
        guard !itemList.isEmpty else {
            return
        }
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
        if dateFetchCount == 0 {
            itemList.forEach { item in
                print(item.curDateString ?? "No curDateString")
                print(item.endDate!)
                
                var endDateIntArray = [Int]()
                endDateIntArray = endDateStringSplitToInt(Date: item.endDate)
                
                if endDateIntArray.isEmpty {
                    // endDateが""であり、DateIntArrayが[]であったら、dayCount配列に空列[]を格納
                    dayCount.append([])
                    dateFetchCount += 1
                } else {
                    // 年, 月, 日 の3つの要素があれば、ddayを行う
                    if endDateIntArray.count == 3 {
                        let customDateComponents = DateComponents(timeZone: timeZone, year: endDateIntArray[0], month: endDateIntArray[1], day: endDateIntArray[2])
                        let endDate = Calendar.current.date(from: customDateComponents)!
                        // ⚠️endDate自体が1日遅れていることに気づいた
                        print("endDate: \(endDate)")
                        
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
            // ⚠️データを削除すると、dateFetchCountが大きくなるから、fetchできないことになる
            // 毎度、dayCount配列をrefresh(初期化)する作業を行う方がより簡単である
            // なぜなら、CoreDataの配列から何番目のデータをdeleteしたのかを特定することが複雑であるためである。
            dayCount = [[Int]]()
            dateFetchCount = 0
            
            for i in 0..<itemList.count {
                var endDateIntArray = [Int]()
                endDateIntArray = endDateStringSplitToInt(Date: itemList[i].endDate)
                
                if endDateIntArray.isEmpty {
                    // endDateが""であり、DateIntArrayが[]であったら、dayCount配列に空列[]を格納
                    dayCount.append([])
                    dateFetchCount += 1
                } else {
                    // 年, 月, 日 の3つの要素があれば、ddayを行う
                    if endDateIntArray.count == 3 {
                        // ⚠️dayを+1しないと、なぜか-1になる
                        let customDateComponents = DateComponents(
                            timeZone: timeZone,
                            year: endDateIntArray[0],
                            month: endDateIntArray[1],
                            day: endDateIntArray[2]
                        )
                        let endDate = Calendar.current.date(from: customDateComponents)!
                        let offsetComps = Calendar.current.dateComponents(
                            [.year, .month, .day],
                            from: formattedCurDate,
                            to: endDate
                        )
                        // if case letは、caseのタイプを先に書く
                        if case let (y?, m?, d?) = (offsetComps.year, offsetComps.month, offsetComps.day) {
                            print("\(y)年 \(m)月 \(d)日ほど差があります。")
                            dayCount.append([y, m, d])
                            dateFetchCount += 1
                        }
                    }
                }
            }
        }
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
            // そもそも、賞味期限が切れたものをcountしないように処理logicを修正すればいい
            // なぜなら、dayCountは、メソッドが呼び出される度にupdateされるため
            guard dayCount[i][0] == 0 && dayCount[i][1] == 0 && dayCount[i][2] >= 0 else {
                continue
            }
            
            // MARK: ⚠️以下のような処理だと、 賞味期限が切れるまで、1年以上の余裕がある商品とか、１ヶ月以上の余裕がある商品も全部Countされることになる
            // そのため、[i][0], [i][1]が両方とも0のときに実行されるようにguard文を設けた
            if 0 <= dayCount[i][2] && dayCount[i][2] <= 7 {
                // MARK: 🔥ここで、filteredDayCount配列に入れてもいいが、coreDataのfetchが難しい
                // 理由: そのindexに合わせてCoreDataのindexを新しいCoreDataの配列に格納する必要があるからだ
                willEndThisWeekCount += 1
            }
            // なにも、countにヒットしなかったら、そのまま０になる
        }
        
        // この後、sortCoreDateメソッドを呼び出す
        filterDayCount()
    }
    
    //TODO: 🔥CoreDataをfetchしてから、賞味期限今週中に切れるもの(D - 7以下)だけをfilterするためのメソッド
    func filterDayCount() {
        guard !dayCount.isEmpty else {
            // TODO: 🔥Daycountがないんだったら、他のviewを表示するように修正する予定
            return
        }
        
        if filterDateFetchCount != 0 {
            // 勝手に配列に格納されないよう、初期化を行う
            dayQueue = [(index: Int, dayDifference: Int)]()
        }
        
        // dayCountの日の差だけを判別して、dayQueueにappendする
        for i in 0..<dayCount.count {
            guard dayCount[i].count == 3 else {
                continue
            }
            
            guard dayCount[i][0] == 0 && dayCount[i][1] == 0 && dayCount[i][2] >= 0 else {
                continue
            }
            
            let dayDifference = dayCount[i][2]
            // 7日内にあるものだけをappendする
            if 0 <= dayDifference && dayDifference <= 7 {
                dayQueue.append((i, dayDifference))
            }
        }
        // TODO: ⚠️dayQueueに格納されたindexを用いてCoreDataをfilterする
        // まず、最も期限が近いものを先頭にくるようにsortする
        // また、filterしたCoreDataのindexに合わせてdayQueueに格納した、dayDifferenceをCollection View CellのDDayのUILabelにconfigureする
        // 期限が短いものを一番先頭に来るようにsortする
        dayQueue.sort(by: { $0.dayDifference < $1.dayDifference })
        filterCoreDataByNearestDay()
    }
    
    // TODO: 🔥predicateを用いたCoreDataのfilter
    // このメソッドでは、ただCoreDataから7日以内に賞味期限が切れる商品のデータを格納すればいい
    // MARK: ⚠️ filteredItemListにずっとdataが任意に足されるエラーが生じた
    // ⚠️fetchを行う処理に条件付きの制限を与える必要がある
    func filterCoreDataByNearestDay() {
        // Coredataにデータなかったら、return
        guard !itemList.isEmpty else {
            return
        }
        
        // 正しく表示されないのは、ここのコードのせいだった
        // ⚠️なぜなら、dayQueueがemptyであると、returnしてしまったせいで、下記のようなfilterItemListの更新が行われなかったからだ
//        guard !dayQueue.isEmpty else {
//            return
//        }
        
        if filterDateFetchCount != 0 {
            // 勝手に配列に格納されないよう、初期化を行う
            filteredItemList = [ItemList]()
            filteredDayCount = [Int]()
            filterDateFetchCount = 0
        }
        
        let fetchRequest: NSFetchRequest<ItemList> = ItemList.fetchRequest()
        
        // uuidをfetchすれば、上手くarrayに格納することができる
        for i in 0..<dayQueue.count {
            let (index, dayDifference) = dayQueue[i]
            
            guard let hasUUID = itemList[index].uuid else {
                continue
            }
            
            fetchRequest.predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
            
            do {
                // filteredDataは、[ItemList]　配列typeである
                let filteredData = try context.fetch(fetchRequest)
                
                filteredItemList.append(filteredData.first!)
                filteredDayCount.append(dayDifference)
                filterDateFetchCount += 1
                appDelegate.saveContext()
            } catch {
                print(error)
            }
        }
    }
    
    @objc func tapSettingBarButton() {
        // navigationBarButtonのタップから表示されるView controller
        print("tap setting Button")
        guard let controller = UIStoryboard(
            name: "Setting",
            bundle:nil
        ).instantiateViewController(
            withIdentifier: "SettingViewController"
        ) as? SettingViewController else {
            fatalError("SettingViewController could not be found.")
        }
        
        // ⚠️MARK: nibファイルはあるが、navigationControllerのentry pointが連結されてない
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
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
            return 250
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
            guard let header = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: "HomeCustomHeader"
            ) as? HomeCustomHeader else {
                fatalError("Cannot find HomeCustomHeader")
            }
            
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
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "HomeCardViewCell",
                for: indexPath
            ) as? HomeCardViewCell else {
                fatalError("Cannot find HomeCardViewCell")
            }
            cell.selectionStyle = .none

            return cell
        case 1:
            // TODO: 🔥filteredItemListがない場合の分岐をここで行う
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "HomeItemCell",
                for: indexPath
            ) as? HomeItemCell else {
                fatalError("Cannot find HomeItemCell")
            }
            //collectionViewCellのクリックdelegate
            cell.cellDelegate = self
            
            // sortedされたItemListを渡す
            cell.configure(with: filteredItemList, dayArray: filteredDayCount)
            cell.selectionStyle = .none

            return cell
        default:
            return UITableViewCell()
        }
    }
}

// ここで、presentの作業をする
extension HomeViewController: CollectionViewCellDelegate {
    func collectionView(collectionViewCell: HomeItemCollectionViewCell?, index: Int, didTappedInTableViewCell: HomeItemCell) {
        let index = index
        let filteredItem = filteredItemList[index]
        print("item index: \(index)")
        print("filteredItem: \(filteredItem)")
        
        guard let controller = UIStoryboard(name: "NewItem", bundle: nil).instantiateViewController(
            withIdentifier: "NewItemViewController"
        ) as? NewItemViewController else {
            fatalError("Cannot find NewItemViewController or NewItem")
        }
        
        controller.delegate = self
        controller.selectedItemList = filteredItem
        
        // navigation VCとしてmodal presentする方法
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationCapturesStatusBarAppearance = true
        // fullScreenで表示させる方法
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.title = "商品詳細"
        
        // itemListのcell clickと同様な View Presentの挙動にした方が統一感があると考える
        self.present(navigationController, animated: true)
    }
    
}

extension HomeViewController: NewItemViewControllerDelegate {
    func addNewItemInfo() {
        self.fetchData()
        self.homeTableView.reloadData()
        updateViewConstraints()
    }
}
