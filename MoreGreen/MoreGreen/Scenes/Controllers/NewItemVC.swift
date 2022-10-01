//
//  NewItemVC.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit
import AVFoundation

// MARK: 新しいItemを生成する時に表示されるViewController
// cell1 : Image , Itemの名前を検知
// cell2 : 賞味期限の表示
// cell3 : Itemの詳細説明を記入できるように, create button, update button, delete Buttonも一緒に

// ⚠️Error: CameraVCからPopViewControllerしたとき、navigationBarが表示されない

class NewItemVC: UIViewController {
    
    @IBOutlet weak var createItemTableView: UITableView!
    private(set) var presenter: ItemInfoViewPresenter!
    typealias PhotoType = (itemImage: Data, periodImage: Data)
    
    // ⚠️まだ、使うかどうか決めてない変数
    var itemImage = UIImage()
    var takeItemImage = false
    var endPeriodText = ""
    var dDayText = ""
    // ⚠️cameraVCから、image Dataを受け取るためのproperty
    var photoData = Array(repeating: Data(), count: 2)
    var photoResultVC = PhotoResultVC()
    var imageScale: CGAffineTransform?
    var imageScaleX: CGFloat?
    var imageScaleY: CGFloat?
    var hasCoreData = false
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedItemList: ItemList?
    
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
    
    // Json parsingを用いて、imageをparsingする
    // 2つ目: OCR結果を用いて、賞味期限の表示
    func periodConfigure(with imageData: Data, index cellIndex: Int) {
        print("period configure")
        //        presenter = ItemViewPresenter(
        //            jsonParser: ProfileJSONParser(profileCreater: ProfileElementsCreater()),
        //            apiClient: GoogleVisonAPIClient(),
        //            view: self
        //        )
        //        // view: self -> protocol規約を守るviewの指定 (delegateと似たようなもの)
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
        print("save")
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
            
            cell.selectionStyle = .none
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! ButtonCell
            cell.delegate = self
            cell.selectionStyle = .none
            
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

extension NewItemVC: ResizePhotoDelegate {
    func resizePhoto(with imageData: Data, scaleX x: CGFloat, scaleY y: CGFloat) {
        imageScale = imageScale?.scaledBy(x: x, y: y)
        imageScaleX = x
        imageScaleY = y
        self.createItemTableView.reloadData()
        updateViewConstraints()
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

