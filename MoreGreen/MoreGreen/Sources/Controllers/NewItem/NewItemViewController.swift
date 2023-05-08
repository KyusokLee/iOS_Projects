//
//  NewItemViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit
import AVFoundation
import CoreData

// MARK: 新しいItemを生成する時に表示されるViewController
// cell1 : Image , Itemの名前を検知
// cell2 : 賞味期限の表示
// cell3 : Itemの詳細説明を記入できるように, create button, update button, delete Buttonも一緒に

// ⚠️Error: CameraVCからPopViewControllerしたとき、navigationBarが表示されない
// TODO: - 写真を商品の写真と賞味期限の写真といった２種類に分けるのではなく、1回の写真で全部完結するようにする
// 考えられるError: 画像として保存したい商品の写真が賞味期限が記入されている所と異なる場合が考えられる
// 解決策: 1. ボタンタップによる最初の写真撮りの画面は、賞味期限がある所を撮るように誘導する
//       2. そして、とった後、NewItemViewControllerに戻り、欲しい写真と異なる場合、他の写真を撮るようにする

// MARK: 🔥⚠️現在layoutの警告がでるところ -> HomeVCのcardView, NewItemViewControllerの '写真を撮る'のボタン -> 今後直す予定
// TODO: ⚠️もっと、cleanなコードにrefactoringすること🔥
// TODO: 0_ viewをtapして、keyboardをdismissできるようにする
// TODO: 1_ 商品の名前を直接記入できるようにする
// TODO: 2_漢字が混ざっている数字 (例：2022年10月)が Vision API (GCP)で認証できない　->　regex Expのコードの問題か、他の方法を探し中
// TODO: 3_ HIGを参考して、UIの改善に取り組む

protocol NewItemViewControllerDelegate: AnyObject {
    func addNewItemInfo()
}

//protocol NewItemMakeDelegate: AnyObject {
//    func makeNewItemFromThisView()
//}

class NewItemViewController: UIViewController {
       
    @IBOutlet weak var createItemTableView: UITableView!
    private(set) var presenter: NewItemViewPresenter!
    typealias PhotoType = (itemImage: Data, periodImage: Data)
    
    // ⚠️まだ、使うかどうか決めてない変数
    var imageData = Data()
    var itemName: String? = ""
    var endPeriodText = ""
    var recognizeState = false
    var failState = false
    var dDayText = ""
    // ⚠️cameraVCから、image Dataを受け取るためのproperty
    var photoData = Array(repeating: Data(), count: 2)
    var photoResultVC = PhotoResultViewController()
    var imageScale: CGAffineTransform?
    var imageScaleX: CGFloat?
    var imageScaleY: CGFloat?
    var hasCoreData = false
    var isPhotoResized = false
    var onceDeleted = false
    var hasItemNameText = false
    //⚠️賞味期限の文字認証を行う間に、ユーザの認識touchを受け取らないように
    var isDoingRecognize = false
    weak var loadingView: UIView?
    // imageの賞味期限や消費期限のconfigureのための変数
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedItemList: ItemList?
    weak var delegate: NewItemViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Create new item list with camera OCR or barcode")
        print(photoData)
        addKeyboardObserver()
        dismissKeyboardByTap()
        setUpTableView()
        registerXib()
        photoResultVC.delegate = self
        createItemTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        fetchCoreData()
        createItemTableView.reloadData()
        // navigation画面遷移によるnavigation barの隠しをfalseにする
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.loadViewIfNeeded()
    }
    
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(noti: Notification) {
        
    }
    
    @objc func keyboardWillHide(noti: Notification) {
        
    }
    
    func dismissKeyboardByTap() {
        let tapGesture = UITapGestureRecognizer(target: self.view, action: #selector(view.endEditing))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self)
    }
        
    private func setUpTableView() {
        createItemTableView.delegate = self
        createItemTableView.dataSource = self
        createItemTableView.separatorStyle = .none
    }
    
    // NewItemViewControllerをnavigation Controllerにさせるメソッド
    private func setNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.7)
        
        self.navigationItem.title = "商品登録"
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = textAttributes
        
        let dismissBarButton = UIBarButtonItem(image: UIImage(systemName: "multiply.circle")?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(dismissBarButtonTap))
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = dismissBarButton
        
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // viewWillAppearでviewが表示される寸前に行う処理をここのメソッドで記入
    func fetchCoreData() {
        print("cc")
        // coreDataがある場合、その情報をphotoDataに格納し、TableViewCellのデータをfetchするようにする
        if let selectedItem = selectedItemList {
            print("lets do fetch")
            if let image = selectedItem.itemImage {
                imageData = image
//                photoData[0] = imageData
            }
            
            if let endDate = selectedItem.endDate {
                print("has endDate")
                endPeriodText = endDate
//                photoData[1] = imageData
            }
            
            if let name = selectedItem.itemName {
                print("has ItemName")
                if name == "" {
                    itemName = "未記入"
                } else {
                    itemName = name
                }
            }
            
            createItemTableView.reloadData()
        } else {
            // CoreDataのデータがないなら、そのままreturn
            print("no data")
            return
        }
    }
    
    func customCurrentDateFormat(divider str: String) -> String {
        let formatter = DateFormatter()
        let curDate = Date()
        
        if str == "" {
            // endDateが空のままだと、curDateの変換はDefaultで-にする
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: curDate)
        } else {
            formatter.dateFormat = "yyyy\(str)MM\(str)dd"
            return formatter.string(from: curDate)
        }
    }
    
    func customEndDateFormat(endDate dateString: String, with divider: String) -> String {
        // mapでString配列にしてから、returnするときにjoinedで一つの文字列にする作業を行なった
        // imageの写真だけ撮ったときは、""をreturnするように
        guard dateString != "" else {
            return ""
        }
        
        var changedStr = dateString.map{ String($0) }
        
        if changedStr.first == " " {
            changedStr.remove(at: 0)
        }
        // yearが22とか21などの２桁の数字である場合
        // 先頭から0, 2を入れることで、 2022, 2021などに変換してから保存するように
        if changedStr[2] == divider {
            changedStr.insert("0", at: 0)
            changedStr.insert("2", at: 0)
        }
        
        if dateString == "" {
            return ""
        } else {
            var dividerCount = 1
            
            for i in 0..<changedStr.count {
                if changedStr[i] == divider {
                    switch dividerCount {
                    case 1:
                        changedStr[i] = "年 "
                        dividerCount += 1
                    case 2:
                        changedStr[i] = "月 "
                        dividerCount = 0
                    default:
                        break
                    }
                }
            }
            
            // CoreDataに登録するとき、"日"という文字が追加され続けるため、if文を設けた
            if changedStr.last != "日" {
                changedStr.append("日")
            }
            
            return changedStr.joined(separator: "")
        }
    }
    
    @objc func dismissBarButtonTap() {
        self.dismiss(animated: true)
    }
    
    private func registerXib() {
        // 各Cellを登録
        createItemTableView.register(UINib(nibName: "ItemImageCell", bundle: nil), forCellReuseIdentifier: "ItemImageCell")
        createItemTableView.register(UINib(nibName: "EndPeriodCell", bundle: nil), forCellReuseIdentifier: "EndPeriodCell")
        createItemTableView.register(UINib(nibName: "ButtonCell", bundle: nil), forCellReuseIdentifier: "ButtonCell")
    }
// MARK:🔥 UIViewControllerを返すメソッドの書き方は、初めてVCを開き出すときに適していると判断した

    // controllerを返すのではなく、ImageDataをfetchするだけのメソッド
    // cameraVCから写真を撮った後は、最初にここから始まる
    // 別にこのメソッドがなくてm動いている
    func fetchImageData(with imageData: Data, index cellIndex: Int) {
        self.photoData[cellIndex] = imageData
        if cellIndex == 1 {
            // endDateのperiodConfigureだけは、presenterを用いるので、メソッドを使う
            self.periodConfigure(with: imageData, index: cellIndex)
        }
        // byteが出力される
        print(photoData)
    }
    
    func resizeImageData(with imageData: Data) {
        
    }
    
    // 賞味期限の文字認識が終わるまで、loadingViewを表示する
    func showLoadingView(state checkState: Bool) {
        guard checkState else {
            return
        }
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        if let loadingView = self.loadingView {
            window?.addSubview(loadingView)
        } else {
            let loadingView = UIView(frame: UIScreen.main.bounds)
            loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            activityIndicator.center = loadingView.center
            activityIndicator.color = UIColor.white
            activityIndicator.style = UIActivityIndicatorView.Style.large
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            
            loadingView.addSubview(activityIndicator)
            
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
            titleLabel.center = CGPoint(x: activityIndicator.frame.origin.x + activityIndicator.frame.size.width / 2, y: activityIndicator.frame.origin.y + 90)
            titleLabel.textColor = UIColor.white
            titleLabel.textAlignment = .center
            titleLabel.text = "ただいま、文字認識を処理中です..."
            loadingView.addSubview(titleLabel)
            
            window?.addSubview(loadingView)
            self.loadingView = loadingView
        }
    }
    
    func hideloadingView(_ loadingView: UIView?, state recognizeState: Bool) {
        print("hide load!")
        guard !recognizeState else {
            return
        }
        print("do Hide load!")
        
        if let view = loadingView {
            DispatchQueue.main.async {
                view.removeFromSuperview()
            }
        } else {
            return
        }
    }
}

private extension NewItemViewController {
    // TODO: imageは2週類ある
    // 1つ目:　商品の写真だけを保存
    
    // 🔥Json parsingを用いて、imageをparsingする
    // 2つ目: OCR結果を用いて、賞味期限の表示
    func periodConfigure(with imageData: Data, index cellIndex: Int) {
        
        print("period configure")
        presenter = NewItemViewPresenter(
            textRecognizer: VisionTextRecognizer(itemInfoCreator: ItemElementsCreator()),
            view: self
        )
        // view: self -> protocol規約を守るviewの指定 (delegateと似たようなもの)
        // MARK: 🔥⚠️賞味期限のimageをloadして、賞味期限の文字を表示する処理をここで、行う
        if !isDoingRecognize {
            // DoingRecognizeをtrueに
            isDoingRecognize = true
            self.showLoadingView(state: isDoingRecognize)
            
            // periodImageLoadが終わるまで、hideloadingViewをいないから、syncとasyncで実装できそう
            DispatchQueue.main.async {
                self.periodImageLoad(with: imageData)
            }
        }
    }
    
    // 🔥画面への反映速度が遅い: loadをimageをここでやると、案の定画面への反映速度が若干遅かった
    // --> 修正したい方向性: cameraVCで写真を撮ったあと、すぐloadItemInfoをするようにすれば、より早く反映されるのではないかと考える
    // それとも、presenterを最初からVCのloadの時点(viewDidLoad)で定義する
    func periodImageLoad(with imageData: Data) {
        presenter.loadItemInfomation(from: CIImage(data: imageData)!)
    }
    // ⚠️カメラ撮影の権限をcheckするメソッド
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (granted: Bool) in
            if granted {
                print("camera: 権限許可")
            } else {
                print("camera: 権限拒否")
                // TODO: ⚠️　デバイスの設定から変更することが可能にする
            }
        }
    }
    
    func setImagePhotoEventAlert() -> UIAlertController {
        let alert = UIAlertController(title: "写真の更新を行います。", message: "", preferredStyle: .actionSheet)
        let newPhoto = UIAlertAction(title: "写真変更", style: .default) { _ in
            self.moveAgainToTakePhoto()
        }
        let back = UIAlertAction(title: "戻る", style: .cancel) { _ in
            print("back")
        }
        let cancel = UIAlertAction(title: "削除", style: .destructive) { _ in
            self.imageCancelAction()
        }
        alert.addAction(newPhoto)
        alert.addAction(cancel)
        alert.addAction(back)
        
        return alert
    }
    
    func moveAgainToTakePhoto() {
        let controller = CameraViewController.instantiate()
        controller.cellIndex = 0
        controller.delegate = self
        
        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .fullScreen
        // fullScreenであるが、1つ前のViewのサイズに合わせてpushされる
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func imageCancelAction() {
        // data型に初期化
        // ⚠️更新を行わないと、dataが削除されないようにしたい
        if let data = selectedItemList {
            data.itemImage = Data()
        } else {
            photoData[0] = Data()
        }
        
        createItemTableView.reloadData()
    }
}

extension NewItemViewController: ItemImageCellDelegate {
    // 長押しで、削除、写真変更などが可能となる
    func longPressImageViewEvent() {
        self.present(setImagePhotoEventAlert(), animated: true)
    }
    
    //　撮った写真を確認できるようにして、また、写真を撮り直すことも可能とするメソッド
    func tapImageViewEvent() {
        // indexが0の写真を見せるので、固定的に0を記入した
        var itemImageData = Data()
        if let image = selectedItemList?.itemImage {
            itemImageData = image
        } else {
            itemImageData = photoData[0]
        }
        
        let controller = PhotoResultViewController.instantiate(with: itemImageData)
        controller.resultImageData = itemImageData
        controller.modalPresentationStyle = .overCurrentContext
        self.present(controller, animated: true)
    }
    
    // image 上のbuttonを通したcamera VCへの画面遷移
    // navigationのpushを用いた方法
    func takeItemImagePhoto() {
        requestCameraPermission()
        let controller = CameraViewController.instantiate()
        controller.cellIndex = 0
        controller.delegate = self
        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .fullScreen
        // fullScreenであるが、1つ前のViewのサイズに合わせてpushされる
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // ただのbuttonを通したcamera VCへの画面遷移
    func takeImagePhotoScreen() {
        requestCameraPermission()
        let controller = CameraViewController.instantiate()
        controller.cellIndex = 0
        controller.delegate = self
        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(controller, animated: true)
    }
}
// EndPeriodCell Delegate関連
// TextField関連メソッドあり
extension NewItemViewController: EndPeriodCellDelegate {
    func writeItemName(textField: UITextField) {
        // Error: 新たなitemを登録するとき、doneが押せるようになっているが、一回入力の後は、doneボタンを押せないようになっている
        // 解決: EndPeriodCellでdidSetの段階から、メソッドを書くことでエラーを治すことができた
        //MARK: 🔥最初に入った時は、itemNameは nilになり、一回でも入力を行ったのであれば、Optional("")になる
        textField.delegate = self
        print("itemName: \(String(describing: itemName))")
        itemName = textField.text ?? nil
        // ここで、reloadDataを書くと、テキストを入力するたびにreloadDataされるため、キーボードがずっとdismissとpresentを繰り返すことになる
        createItemTableView.layoutIfNeeded()
    }
    
    func takeEndPeriodScreen() {
        requestCameraPermission()
        let controller = CameraViewController.instantiate()
        controller.cellIndex = 1
        controller.delegate = self
        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(controller, animated: true)
    }
}

// textFieldのdelegateに関するメソッド
extension NewItemViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if itemName == nil || itemName == "" {
            hasItemNameText = false
            print("textState: \(hasItemNameText)")
        } else {
            hasItemNameText = true
            print("textState: \(hasItemNameText)")
        }
        // MARK: 🔥reloadDataをすると、textFieldのtextが全部消されることになる
        // 🌈解決策: 特定のrowsだけをreloadDataするようにし、buttonのstateのdataをreloadするようにした
        self.createItemTableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
    }
}

// 作成、更新、削除のボタンからデータを反映する
extension NewItemViewController: ButtonDelegate {
    // DataをCoreDataにsaveする
    func didFinishSaveData() {
        // 選択されたもの(既存のitemデータ)がないときだけ、save可能だからguardを採択した
        guard selectedItemList == nil else {
            return
        }
        print("save")
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "ItemList", in: context) else {
            return
        }
        guard let object = NSManagedObject(entity: entityDescription, insertInto: context) as? ItemList else {
            return
        }
        // endDateの区別文字に合わせて、保存するendDateのStringを異なる形でCoreDataに保存する
        var divider = ""
        var curDateString = ""
        
        // MARK: ✍️ここの部分でendDateをCoreDateに保存するように
        // curDateStringとendDate(string型)のdata格納はここの分岐で行うようにした
        if failState {
            object.endDate = ""
            // endDateがないデータであれば(itemImageだけある場合)、default値としてcurDateをHyphenを入れた値で保存する
            divider = "-"
            curDateString = self.customCurrentDateFormat(divider: divider)
        } else {
            // MARK: - ちょっとここら辺のコード減らしたい
            if endPeriodText.contains(".") {
                divider = "."
            }
            
            if endPeriodText.contains("-") {
                divider = "-"
            }
            
            if endPeriodText.contains("/") {
                divider = "/"
            }
            
            curDateString = self.customCurrentDateFormat(divider: divider)
            object.endDate = customEndDateFormat(endDate: endPeriodText, with: divider)
        }
        
        // ⚠️Stringとして保存した方がDDayなどの日付の差の計算が容易である
        object.itemName = itemName
        object.curDateString = curDateString
        object.curDate = Date()
        object.uuid = UUID()
        //imageDataは、itemの写真だけを入れるから、photoData[0]を格納する
        // selectedされたとき、fetchimageすればいい
        
        //　なにもデータがない時 (Data()の初期化のまま)
        if photoData[0] != Data() {
            object.itemImage = photoData[0]
        } else {
            object.itemImage = Data()
        }
        
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.saveContext()
        self.delegate?.addNewItemInfo()
        
//        // このVCをpresentしたVCを指定する
//        guard let rootVC = self.presentingViewController else {
//            return
//        }
//
//        if rootVC != TabBarController() {
//            print(rootVC)
//        }
        // rootVCが全部 TabBarControllerになっている
        
        // dismissするとともに、itemListVCに行きたい
        self.dismiss(animated: true)
    }
    
    func didFinishUpdateData() {
        print("update")
        guard let selectedItem = selectedItemList else {
            return
        }
        let fetchRequest: NSFetchRequest<ItemList> = ItemList.fetchRequest()
        guard let uuid = selectedItem.uuid else {
            return
        }
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", uuid as CVarArg)
        do {
            let loadedData = try context.fetch(fetchRequest)
            // endDateの区別文字に合わせて、保存するendDateのStringを異なる形でCoreDataに保存する
            var divider = ""
            var curDateString = ""
            
            if let image = selectedItemList?.itemImage {
                loadedData.first?.itemImage = image
            } else {
                loadedData.first?.itemImage = photoData[0]
            }
            
            // MARK: ✍️ここの部分でendDateをCoreDateに保存するように
            // curDateStringとendDate(string型)のdata格納はここの分岐で行うようにした
            if failState {
                loadedData.first?.endDate = ""
                // endDateがないデータであれば(itemImageだけある場合)、default値としてcurDateをHyphenを入れた値で保存する
                divider = "-"
                curDateString = self.customCurrentDateFormat(divider: divider)
            } else {
                if endPeriodText.contains(".") {
                    divider = "."
                }
                
                if endPeriodText.contains("-") {
                    divider = "-"
                }
                
                if endPeriodText.contains("/") {
                    divider = "/"
                }
                
                curDateString = self.customCurrentDateFormat(divider: divider)
                loadedData.first?.endDate = customEndDateFormat(endDate: endPeriodText, with: divider)
            }
            
            loadedData.first?.itemName = itemName
            loadedData.first?.curDateString = curDateString
            loadedData.first?.curDate = Date()
            
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            appDelegate.saveContext()
            
        } catch {
            print(error)
        }
        
        self.delegate?.addNewItemInfo()
        self.dismiss(animated: true)
    }
    
    func didFinishDeleteData() {
        print("delete")
        guard let selectedItem = selectedItemList else {
            return
        }
        guard let uuid = selectedItem.uuid else {
            return
        }
        
        let fetchRequest: NSFetchRequest<ItemList> = ItemList.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", uuid as CVarArg)
        do {
            let loadedData = try context.fetch(fetchRequest)
            if let firstLoadedData = loadedData.first {
                context.delete(firstLoadedData)
                
                let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
                appDelegate.saveContext()
            }
        } catch {
            print(error)
        }
        
        self.delegate?.addNewItemInfo()
        self.dismiss(animated: true)
    }
    
    func showsErrorAlert(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let check = UIAlertAction(title: "確認", style: .default) { _ in
            self.dismiss(animated: true)
        }
        alertController.addAction(check)
        return alertController
    }
}

extension NewItemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // sectionの数を設定しないと、cellを登録しても、表示されない
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return UITableView.automaticDimension
        case 1:
            return UITableView.automaticDimension
        case 2:
            return UITableView.automaticDimension
        default:
            return 0
        }
    }
    
    // ❗️estimatedHeightは実際より大きく設定しましょう
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 400
        case 1:
            return 350
        case 2:
            return 200
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cell の情報がsection別に入る
        let section = indexPath.section
        switch section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ItemImageCell",
                for: indexPath
            ) as? ItemImageCell else {
                fatalError("Cannot find ItemImageCell")
            }
            // cell 関連のメソッド
            // ⚠️不確実 cell delegateをここで定義?
            cell.delegate = self
            // dataで渡す形
            
            // ⚠️CoreDataとのfetchをした後、そのまま、cellに返すように
            // TODO: ここの部分をrefactoringする必要があると考える
            if let selectedItem = selectedItemList {
                // configureを通して、imageをfetchするので、ifの分岐は要らない
                print(selectedItem)
                //CoreDataがあったとしても、写真を変えることができるので、imageDataがあるかどうかを確認して、再びfetchを行う
                // CoreDataに入っているやつ
                if selectedItem.itemImage != Data() {
                    if photoData[indexPath.row] != Data() {
                        cell.configure(with: photoData[indexPath.row], scaleX: imageScaleX, scaleY: imageScaleY)
                        cell.imageData = photoData[indexPath.row]
                    } else {
                        // ItemListのcellから受け取るか、写真がない
                        let imageData = selectedItem.itemImage ?? Data()
                        cell.configure(with: imageData, scaleX: imageScaleX, scaleY: imageScaleY)
                        cell.imageData = imageData
                    }
                } else {
                    //写真の更新を行う -> 初期化された場合
                    // 写真の更新を行い -> 写真を新しく撮った
                    if photoData[indexPath.row] != Data() {
                        cell.configure(with: photoData[indexPath.row], scaleX: imageScaleX, scaleY: imageScaleY)
                        cell.imageData = photoData[indexPath.row]
                    } else {
                        // 写真がない
                        cell.configure(with: Data(), scaleX: imageScaleX, scaleY: imageScaleY)
                        cell.imageData = Data()
                    }
                }
            } else {
                // CoreDataにない時
                let imageData = photoData[indexPath.row]
                
                if isPhotoResized {
                    cell.configure(with: imageData, scaleX: imageScaleX, scaleY: imageScaleY)
                } else {
                    cell.configure(with: imageData, scaleX: 1.0, scaleY: 1.0)
                }
            }
            
            cell.selectionStyle = .none
            
            return cell
            
        case 1:
            // ⚠️途中の段階: 賞味期限のcellでの処理をもっと書く必要がある
            // TODO: 🔥CoreDataにあるデータの場合、文字が反映されないerrorが生じた
            // MARK: 🔥itemNameで少しエラーが生じる
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "EndPeriodCell",
                for: indexPath
            ) as? EndPeriodCell else {
                fatalError("EndPeriodCell Could not be found.")
            }
            cell.delegate = self
            
            // CoreDataがあるとき (ItemListのcellのclickよりviewをpresentした場合)
            if let selectedItem = selectedItemList {
                // CoreDataのデータをfetchするように
                if let itemName = selectedItem.itemName {
                    var isOnlySpaceStr = true
                    let splitName = itemName.map { String($0) }
                    
                    for i in 0..<splitName.count {
                        if splitName[i] != " " {
                            isOnlySpaceStr = false
                            break
                        }
                    }
                    
                    if isOnlySpaceStr {
                        // 保存できないように！
                    } else {
                        // 保存できるように！
                    }
                    
                    self.itemName = itemName
                    
                } else {
                    // itemNameがない時 (nil)
                    self.itemName = selectedItem.itemName
                }
                
                if selectedItem.endDate != "" {
                    // ""これもendDataがあることになる
                    // endDateが必ずあるときだけ、この処理をするので、checkStateは直ちにtrueにしてあげた
                    
                    if selectedItem.endDate! == self.endPeriodText {
                        let fetchEndDate = selectedItem.endDate!
                        cell.configure(
                            with: fetchEndDate,
                            itemName: self.itemName,
                            checkState: true,
                            failure: false
                        )
                    } else {
                        // CoreDataのendDateと新しく撮ったendDateが異なる場合
                        let fetchEndDate = self.endPeriodText
                        cell.configure(
                            with: fetchEndDate,
                            itemName: self.itemName,
                            checkState: recognizeState,
                            failure: failState
                        )
                    }
                } else {
                    // endDateが入ってないとき
                    // Data()があるけど、endDateは入ってない
                    // endPeriodTextが""になっている
                    cell.configure(
                        with: self.endPeriodText,
                        itemName: self.itemName,
                        checkState: false,
                        failure: true
                    )
                }
            } else {
                // CoreDataがないとき (新しく商品登録を行う場合)
                // TODO: 🔥文字認識に失敗したとき、"文字認識に失敗した日として表示される"ことを防ぐ
                // CoreDataではなく、新しいitemを作成するとき
                // ここの処理をする
                if photoData[1] == Data() {
                    
                } else {
                    
                }
                
                self.itemName = nil
                cell.configure(
                    with: self.endPeriodText,
                    itemName: self.itemName,
                    checkState: recognizeState,
                    failure: failState
                )
            }
            
            cell.selectionStyle = .none
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ButtonCell",
                for: indexPath
            ) as? ButtonCell else {
                fatalError("ButtonCell Could not be found")
            }
            cell.delegate = self
            cell.selectionStyle = .none
            
            // dataがあるときだけ、save ButtonをisEnabledをtrueにして、活性化にする
            // TODO: ⚠️一つ以上のデータ(賞味期限、もしくは、商品のimage)があれば、buttonのクリックができるようにする
            
            // 選択したitemがある -> すでにCoreData上に格納したデータがあるってこと
            if selectedItemList != nil {
                cell.createButton.isHidden = true
                cell.updateButton.isHidden = false
                cell.deleteButton.isHidden = false
            } else {
                cell.createButton.isHidden = false
                cell.updateButton.isHidden = true
                cell.deleteButton.isHidden = true
            }
            //商品のimageデータとperiodデータ両方ともない(Data()の初期化のまま)と create button 押せないように
            // TODO: 🔥商品名が記入されたら、createButtonのdisable状態をenable状態に
            // ここのtextFieldがに書いたitemNameとcreateButtonのボタンの連動でエラーが生じた
            if photoData[0] == Data() && photoData[1] == Data() && !hasItemNameText {
                cell.createButton.isEnabled = false
                cell.createButton.backgroundColor = UIColor(rgb: 0xC0DFFD)
            } else {
                cell.createButton.isEnabled = true
                cell.createButton.backgroundColor = UIColor(rgb: 0x0095F6)
            }
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
}

// delegateがなぜかここに映らない
extension NewItemViewController: CameraViewControllerDelegate {
    // CameraVCで撮った写真を反映させる
    // Cameraを取った後は、このメソッドを処理する
    func didFinishTakePhoto(with imageData: Data, index cellIndex: Int) {
        print("didFinishTakePhoto!")
        self.fetchImageData(with: imageData, index: cellIndex)
        self.createItemTableView.reloadData()
        updateViewConstraints()
    }
}

// この機能は反映されない
extension NewItemViewController: ResizePhotoDelegate {
    func resizePhoto(with imageData: Data, scaleX x: CGFloat, scaleY y: CGFloat) {
        isPhotoResized = true
        imageScale = imageScale?.scaledBy(x: x, y: y)
        imageScaleX = x
        imageScaleY = y
        self.createItemTableView.reloadData()
        updateViewConstraints()
    }
}

extension NewItemViewController: TextRecognizeResultView {
    func shouldShowTextRecognizeResult(with results: String) {
        self.recognizeState = true
        self.endPeriodText = results
        failState = false
        //🔥loadingViewをhideする処理をここで呼び出す
        self.isDoingRecognize = false
        self.hideloadingView(self.loadingView, state: self.isDoingRecognize)
        self.createItemTableView.reloadData()
    }
    
    func shouldShowRecognitionFailFeedback() {
        DispatchQueue.main.async {
            self.present(
                self.showsErrorAlert(title: "テキスト認証失敗", message: "テキスト認証に失敗しました。もう一度確認してください。"),
                animated: true
            )
            self.recognizeState = false
            self.endPeriodText = "文字認識に失敗しました"
            self.failState = true
            //🔥loadingViewをhideする処理をここで呼び出す
            self.isDoingRecognize = false
            self.hideloadingView(self.loadingView, state: self.isDoingRecognize)
            self.createItemTableView.reloadData()
        }
    }
}
