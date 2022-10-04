//
//  NewItemVC.swift
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

// MARK: 🔥⚠️現在layoutの警告がでるところ -> HomeVCのcardView, NewItemVCの '写真を撮る'のボタン -> 今後直す予定


protocol NewItemVCDelegate: AnyObject {
    func addNewItemInfo()
}

//protocol NewItemMakeDelegate: AnyObject {
//    func makeNewItemFromThisView()
//}

class NewItemVC: UIViewController {
    
    @IBOutlet weak var createItemTableView: UITableView!
    private(set) var presenter: ItemInfoViewPresenter!
    typealias PhotoType = (itemImage: Data, periodImage: Data)
    
    // ⚠️まだ、使うかどうか決めてない変数
    var imageData = Data()
    var endPeriodText = ""
    var recognizeState = false
    var failState = false
    var dDayText = ""
    
    // ⚠️cameraVCから、image Dataを受け取るためのproperty
    var photoData = Array(repeating: Data(), count: 2)
    var photoResultVC = PhotoResultVC()
    var imageScale: CGAffineTransform?
    var imageScaleX: CGFloat?
    var imageScaleY: CGFloat?
    var hasCoreData = false
    var isPhotoResized = false
    var onceDeleted = false
    
    // imageの賞味期限や消費期限のconfigureのための変数
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedItemList: ItemList?
    weak var delegate: NewItemVCDelegate?
//    weak var makeDelegate: NewItemMakeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Create new item list with camera OCR and barcode")
        print(photoData)
        
        if let hasItemList = selectedItemList {
            print(hasItemList)
        }
        
        setUpTableView()
        registerCell()
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
    
    private func setUpTableView() {
        createItemTableView.delegate = self
        createItemTableView.dataSource = self
        createItemTableView.separatorStyle = .none
    }
    
    // NewItemVCをnavigation Controllerにさせるメソッド
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
        if let hasData = selectedItemList {
            if let hasImageData = hasData.itemImage {
                imageData = hasImageData
            } else {
                return
            }
            
            if let hasEndDate = hasData.endDate {
                endPeriodText = hasEndDate
            } else {
                return
            }
            createItemTableView.reloadData()
        } else {
            // CoreDataのデータがないなら、そのままreturn
            return
        }
    }
    
    @objc func dismissBarButtonTap() {
        self.dismiss(animated: true)
    }
    
    private func registerCell() {
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
}

private extension NewItemVC {
    // TODO: imageは2週類ある
    // 1つ目:　商品の写真だけを保存
    // ⚠️imageと商品の名前も認証を行うつもりである
//    func imageConfigure(with imageData: Data, index cellIndex: Int) {
//        print("image configure")
//
//        let indexPath = IndexPath(row: cellIndex, section: cellIndex)
//        let cell = createItemTableView.dequeueReusableCell(withIdentifier: "ItemImageCell", for: indexPath) as! ItemImageCell
//        let image = UIImage(data: imageData)
//        cell.itemPhoto = image ?? UIImage()
//        createItemTableView.reloadData()
//    }
    
    // 🔥Json parsingを用いて、imageをparsingする
    // 2つ目: OCR結果を用いて、賞味期限の表示
    func periodConfigure(with imageData: Data, index cellIndex: Int) {
        print("period configure")
        presenter = ItemInfoViewPresenter(
            jsonParser: EndDateJSONParser(itemInfoCreater: ItemElementsCreator()),
            apiClient: GoogleVisonAPIClient(),
            itemView: self
        )
        // view: self -> protocol規約を守るviewの指定 (delegateと似たようなもの)
        periodImageLoad(with: imageData)
    }
    
    // 🔥画面への反映速度が遅い: loadをimageをここでやると、案の定画面への反映速度が若干遅かった
    // --> 修正したい方向性: cameraVCで写真を撮ったあと、すぐloadItemInfoをするようにすれば、より早く反映されるのではないかと考える
    // それとも、presenterを最初からVCのloadの時点(viewDidLoad)で定義する
    func periodImageLoad(with imageData: Data) {
        presenter.loadItemInfo(from: imageData.base64EncodedString())
    }
    // ⚠️カメラ撮影の権限をcheckするメソッド
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (granted: Bool) in
            if granted {
                print("camera: 権限許可")
            } else {
                print("camera: 権限拒否")
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
        let cameraVC = CameraVC.instantiate()
        cameraVC.cellIndex = 0
        cameraVC.delegate = self
        
        let navigation = UINavigationController(rootViewController: cameraVC)
        navigation.modalPresentationStyle = .fullScreen
        // fullScreenであるが、1つ前のViewのサイズに合わせてpushされる
        navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    func imageCancelAction() {
        // data型に初期化
        // ⚠️更新を行わないと、dataが削除されないようにしたい
        if let hasData = selectedItemList {
            hasData.itemImage = Data()
        } else {
            photoData[0] = Data()
        }
        
        createItemTableView.reloadData()
    }
}

extension NewItemVC: ItemImageCellDelegate {
    // 長押しで、削除、写真変更などが可能となる
    func longPressImageViewEvent() {
        self.present(setImagePhotoEventAlert(), animated: true)
    }
    
    //　撮った写真を確認できるようにして、また、写真を撮り直すことも可能とするメソッド
    func tapImageViewEvent() {
        // indexが0の写真を見せるので、固定的に0を記入した
        let resultImageVC = PhotoResultVC.instantiate(with: photoData[0])
        resultImageVC.resultImageData = photoData[0]
        
        resultImageVC.modalPresentationStyle = .overCurrentContext
        self.present(resultImageVC, animated: true)
    }
    
    // image 上のbuttonを通したcamera VCへの画面遷移
    // navigationのpushを用いた方法
    func takeItemImagePhoto() {
        requestCameraPermission()
        
        let cameraVC = CameraVC.instantiate()
        cameraVC.cellIndex = 0
        cameraVC.delegate = self
        
        let navigation = UINavigationController(rootViewController: cameraVC)
        navigation.modalPresentationStyle = .fullScreen
        // fullScreenであるが、1つ前のViewのサイズに合わせてpushされる
        navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    // ただのbuttonを通したcamera VCへの画面遷移
    func takeImagePhotoScreen() {
        requestCameraPermission()
        
        let cameraVC = CameraVC.instantiate()
        cameraVC.cellIndex = 0
        cameraVC.delegate = self
        
        let navigation = UINavigationController(rootViewController: cameraVC)
        navigation.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(cameraVC, animated: true)
    }
}

extension NewItemVC: EndPeriodCellDelegate {
    func takeEndPeriodScreen() {
        requestCameraPermission()
        
        let cameraVC = CameraVC.instantiate()
        cameraVC.cellIndex = 1
        cameraVC.delegate = self
        
        let navigation = UINavigationController(rootViewController: cameraVC)
        navigation.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(cameraVC, animated: true)
    }
}

// 作成、更新、削除のボタンからデータを反映する
extension NewItemVC: ButtonDelegate {
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
        
        if failState {
            object.endDate = ""
        } else {
            object.endDate = endPeriodText
        }
        
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
        guard let hasData = selectedItemList else {
            return
        }
        
        let fetchRequest: NSFetchRequest<ItemList> = ItemList.fetchRequest()
        
        guard let hasUUID = hasData.uuid else {
            return
        }
        
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
        
        do {
            let loadedData = try context.fetch(fetchRequest)
            
            loadedData.first?.itemImage = photoData[0]
            
            if failState {
                loadedData.first?.endDate = "データなし"
            } else {
                loadedData.first?.endDate = endPeriodText
            }
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
        guard let hasData = selectedItemList else {
            return
        }
        
        guard let hasUUID = hasData.uuid else {
            return
        }
        
        let fetchRequest: NSFetchRequest<ItemList> = ItemList.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
        
        do {
            let loadedData = try context.fetch(fetchRequest)
            if let loadFirstData = loadedData.first {
                context.delete(loadFirstData)
                
                let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
                appDelegate.saveContext()
            }
        } catch {
            print(error)
        }
        
        self.delegate?.addNewItemInfo()
        self.dismiss(animated: true)
        
    }
}

extension NewItemVC: UITableViewDelegate, UITableViewDataSource {
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
            return 100
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cell の情報がsection別に入る
        let section = indexPath.section
        
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemImageCell", for: indexPath) as! ItemImageCell
            // cell 関連のメソッド
            // ⚠️不確実 cell delegateをここで定義?
            cell.delegate = self
            // dataで渡す形
            
            if let hasData = selectedItemList {
                // configureを通して、imageをfetchするので、ifの分岐は要らない
                cell.configure(with: hasData.itemImage ?? Data(), scaleX: imageScaleX, scaleY: imageScaleY)
                cell.imageData = hasData.itemImage ?? Data()
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "EndPeriodCell", for: indexPath) as! EndPeriodCell
            cell.delegate = self
            
            if let hasData = selectedItemList {
                if let hasEndDate = hasData.endDate {
                    // endDateが必ずあるときだけ、この処理をするので、checkStateは直ちにtrueにしてあげた
                    let fetchEndDate = hasEndDate
                    cell.configure(with: fetchEndDate, checkState: true, failure: false)
                }
            }
            
            // 何もないとき
            if endPeriodText.count != 0 {
                cell.configure(with: endPeriodText, checkState: recognizeState, failure: failState)
            }
            
            cell.selectionStyle = .none
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! ButtonCell
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
            if photoData[0] == Data() && photoData[1] == Data() {
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
extension NewItemVC: CameraVCDelegate {
    // CameraVCで撮った写真を反映させる
    func didFinishTakePhoto(with imageData: Data, index cellIndex: Int) {
        print("didFinishTakePhoto!")
        
        self.fetchImageData(with: imageData, index: cellIndex)
        self.createItemTableView.reloadData()
        updateViewConstraints()
    }
}

// この機能は反映されない
extension NewItemVC: ResizePhotoDelegate {
    func resizePhoto(with imageData: Data, scaleX x: CGFloat, scaleY y: CGFloat) {
        isPhotoResized = true
        imageScale = imageScale?.scaledBy(x: x, y: y)
        imageScaleX = x
        imageScaleY = y
        self.createItemTableView.reloadData()
        updateViewConstraints()
    }
}

extension NewItemVC: ItemInfoView {
    // 認証とネットワークアクセスに成功した時
    func successToShowItemInfo(with endDate: EndDate) {
        //image Viewからのデータをpresenterから受け取ってimageをfetchする
        let unrecognizedMsg = "日付を読み取れませんでした"
        
        self.recognizeState = true
        self.endPeriodText = endDate.endDate ?? unrecognizedMsg
        
        if self.endPeriodText == unrecognizedMsg {
            failState = true
        } else {
            failState = false
        }
        
        self.createItemTableView.reloadData()
    }
    
    // Google APIへのnetWork 接続Error
    func networkError() {
        self.recognizeState = false
        self.endPeriodText = "ネットワークアクセスに失敗しました"
        self.createItemTableView.reloadData()
    }
    
    // 文字(賞味期限や消費期限)の認識に失敗
    func failToRecognize() {
        self.recognizeState = false
        self.endPeriodText = "文字認識に失敗しました"
        self.createItemTableView.reloadData()
    }
}

