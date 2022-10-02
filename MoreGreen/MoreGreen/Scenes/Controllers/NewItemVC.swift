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

protocol NewItemVCDelegate: AnyObject {
    func addNewItemInfo()
}



class NewItemVC: UIViewController {
    
    @IBOutlet weak var createItemTableView: UITableView!
    private(set) var presenter: ItemInfoViewPresenter!
    typealias PhotoType = (itemImage: Data, periodImage: Data)
    
    // ⚠️まだ、使うかどうか決めてない変数
    var itemImage = UIImage()
    var takeItemImage = false
    
    var endPeriodText = ""
    var recognizeState = false
    var dDayText = ""
    
    // ⚠️cameraVCから、image Dataを受け取るためのproperty
    var photoData = Array(repeating: Data(), count: 2)
    var photoResultVC = PhotoResultVC()
    var imageScale: CGAffineTransform?
    var imageScaleX: CGFloat?
    var imageScaleY: CGFloat?
    var hasCoreData = false
    
    // imageの賞味期限や消費期限のconfigureのための変数
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedItemList: ItemList?
    weak var delegate: NewItemVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Create new item list with camera OCR and barcode")
        print(photoData)
        setUpTableView()
        registerCell()
        photoResultVC.delegate = self
        createItemTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
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
    
    func fetchCoreData() {
        if let hasData = selectedItemList {
            
        } else {
            hasCoreData = false
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
////    // MARK: ❗️cameraVCからのデータをconfigureさせるメソッド
//    // MARK: このようなメソッドの書き方は、初めてVCを開き出すときに適していると判断した
//    // static funcだと、このファイルで作成した他のメソッドへアクセスできない
//    // controller インスタンスを作るとアクセス可能
//    static func cellConfigure(with imageData: Data, index cellIndex: Int) -> NewItemVC {
//        // controllerの指定
//        let controller = UIStoryboard(name: "NewItemVC", bundle: nil).instantiateViewController(withIdentifier: "NewItemVC") as! NewItemVC
//        controller.loadViewIfNeeded()
//
//        if cellIndex == 0 {
//            controller.itemImage = UIImage(data: imageData)!
//            controller.takeItemImage = true
//            controller.imageConfigure(with: imageData, index: cellIndex)
//        } else {
//            controller.periodConfigure(with: imageData, index: cellIndex)
//        }
//
//        controller.createItemTableView.reloadData()
//
//        return controller
//    }
    
    // controllerを返すのではなく、ImageDataをfetchするだけのメソッド
    func fetchImageData(with imageData: Data, index cellIndex: Int) {
        if cellIndex == 0 {
            self.photoData[cellIndex] = imageData
        } else {
            self.photoData[cellIndex] = imageData
            self.periodConfigure(with: imageData, index: cellIndex)
        }
        
        print(photoData)
    }
    
    func resizeImageData(with imageData: Data) {
        
    }
}

private extension NewItemVC {
    // TODO: imageは2週類ある
    // 1つ目:　商品の写真だけを保存
    func imageConfigure(with imageData: Data, index cellIndex: Int) {
        print("image configure")
        print(takeItemImage)
        
        let indexPath = IndexPath(row: cellIndex, section: cellIndex)
        let cell = createItemTableView.dequeueReusableCell(withIdentifier: "ItemImageCell", for: indexPath) as! ItemImageCell
        let image = UIImage(data: imageData)
        cell.itemPhoto = image!
        createItemTableView.reloadData()
    }
    
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
        createItemTableView.reloadData()
    }
    // カメラ撮影の権限をcheckするメソッド
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
        let alert = UIAlertController(title: "", message: "写真の更新", preferredStyle: .actionSheet)
        
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
        photoData[0] = Data()
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
        
        object.endDate = endPeriodText
        object.curDate = Date()
        object.uuid = UUID()
        //imageDataは、itemの写真だけを入れるから、photoData[0]を格納する
        // selectedされたとき、fetchimageすればいい
        object.itemImage = photoData[0]
        
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.saveContext()
        
        self.delegate?.addNewItemInfo()
        self.dismiss(animated: true)
    }
    
    func didFinishUpdateData() {
        print("update")
    }
    
    func didFinishDeleteData() {
        print("delete")
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
            return 200
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
            return UITableView().estimatedRowHeight
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
            
            let imageData = photoData[indexPath.row]
            let resultImage = UIImage(data: photoData[indexPath.row])
            
            if let hasImage = resultImage {
                cell.imageData = imageData
                cell.itemPhoto = hasImage
                cell.configure(with: hasImage, scaleX: imageScaleX, scaleY: imageScaleY)
            } else {
                cell.imageData = imageData
                cell.configure(with: resultImage, scaleX: 1.0, scaleY: 1.0)
            }
            
            cell.selectionStyle = .none
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "EndPeriodCell", for: indexPath) as! EndPeriodCell
            cell.delegate = self
            
            // 何もないとき
            if endPeriodText.count != 0 {
                cell.configure(with: endPeriodText, checkState: recognizeState)
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
            } else {
                cell.createButton.isHidden = false
//                cell.createButton.isEnabled = false
//                cell.createButton.backgroundColor = UIColor(rgb: 0xC0DFFD)
            }
            
            if photoData[0] == Data() && photoData[1] == Data() {
                cell.createButton.isEnabled = false
                cell.createButton.backgroundColor = UIColor(rgb: 0xC0DFFD)
            } else {
                cell.createButton.isEnabled = true
                cell.createButton.backgroundColor = UIColor(rgb: 0x0095F6)
            }
            
            if !hasCoreData {
                cell.deleteButton.isHidden = true
                cell.updateButton.isHidden = true
            } else {
                cell.deleteButton.isHidden = false
                cell.updateButton.isHidden = false
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
        
        self.endPeriodText = endDate.endDate ?? unrecognizedMsg
        self.createItemTableView.reloadData()
    }
    
    // Google APIへのnetWork 接続Error
    func networkError() {
        self.endPeriodText = "ネットワークアクセスに失敗しました"
        self.createItemTableView.reloadData()
    }
    
    // 文字(賞味期限や消費期限)の認識に失敗
    func failToRecognize() {
        self.endPeriodText = "文字認識に失敗しました"
        self.createItemTableView.reloadData()
    }
    
    
}


        
//        if cellIndex == 0 {
//            // cellを特定
//            print("NewItemVC: cell Index 0")
////            var indexPath: IndexPath
////            indexPath = IndexPath(row: cellIndex, section: cellIndex)
////
////
////            itemImage = UIImage(data: imageData)!.toUp
//        } else {
//            // cellIndexが1の時は、賞味期限の方を処理
//            print("NewItemVC: cell Index 1")
//        }

