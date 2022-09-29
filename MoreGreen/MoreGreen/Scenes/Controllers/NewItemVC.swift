//
//  NewItemVC.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit

// MARK: 新しいItemを生成する時に表示されるViewController
// cell1 : Image , Itemの名前を検知
// cell2 : 賞味期限の表示
// cell3 : Itemの詳細説明を記入できるように, create button, update button, delete Buttonも一緒に

// ⚠️Error: CameraVCからPopViewControllerしたとき、navigationBarが表示されない

class NewItemVC: UIViewController {
    
    @IBOutlet weak var createItemTableView: UITableView!
    private(set) var presenter: ItemInfoViewPresenter!
    private var cameraVC = CameraVC()
    
    // ⚠️まだ、使うかどうか決めてない変数
    var itemImage = UIImage()
    var takeItemImage = false
    var endPeriodText = ""
    var dDayText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Create new item list with camera OCR and barcode")
        cameraVC.delegate = self
        setUpTableView()
        registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        navigationController?.setNavigationBarHidden(false, animated: false)
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
    
    @objc func dismissBarButtonTap() {
        self.dismiss(animated: true)
    }
    
    private func registerCell() {
        // 各Cellを登録
        createItemTableView.register(UINib(nibName: "ItemImageCell", bundle: nil), forCellReuseIdentifier: "ItemImageCell")
        createItemTableView.register(UINib(nibName: "EndPeriodCell", bundle: nil), forCellReuseIdentifier: "EndPeriodCell")
        createItemTableView.register(UINib(nibName: "ButtonCell", bundle: nil), forCellReuseIdentifier: "ButtonCell")
    }
    
//    // MARK: ❗️このメソッドは、新しくVCへの画面遷移するときに適している判断した
//    static func instantiate(with imageData: Data, index tag: Int) -> NewItemVC {
//        // 🔥initialじゃなく、camera VCに行ってから、また戻るパータンなので、instatiate initialではない
//        let controller = UIStoryboard(name: "NewItemVC", bundle: nil).instantiateViewController(withIdentifier: "NewItemVC") as! NewItemVC
//        controller.loadViewIfNeeded()
//
//        if tag == 0 {
//            controller.imageConfigure(with: imageData)
//            return controller
//        } else {
//            controller.periodConfigure(with: imageData)
//            return controller
//        }
//    }
    
    // static funcだと、このファイルで作成した他のメソッドへアクセスできない
    // controller インスタンスを作るとアクセス可能
    static func cellConfigure(with imageData: Data, index cellIndex: Int) -> NewItemVC {
        let controller = UIStoryboard(name: "NewItemVC", bundle: nil).instantiateViewController(withIdentifier: "NewItemVC") as! NewItemVC
        controller.loadViewIfNeeded()
        
        if cellIndex == 0 {
            controller.itemImage = UIImage(data: imageData)!
            controller.takeItemImage = true
            controller.imageConfigure(with: imageData, index: cellIndex)
        } else {
            controller.periodConfigure(with: imageData, index: cellIndex)
        }
        
        return controller
    }
}

private extension NewItemVC {
    // TODO: imageは2週類ある
    // 1つ目:　商品の写真だけを保存
    func imageConfigure(with imageData: Data, index cellIndex: Int) {
        print("image configure")
        
        let indexPath = IndexPath(row: cellIndex, section: cellIndex)
        let cell = createItemTableView.dequeueReusableCell(withIdentifier: "ItemImageCell", for: indexPath) as! ItemImageCell
        let image = UIImage(data: imageData)?.toUp
        cell.resultItemImageView.image = image
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
        
    }
    
//    func specifyCell(index tag: Int) -> UITableViewCell {
//        switch tag {
//        case 0:
//            let cell = UINib(nibName: "ItemImageCell", bundle: nil) as! UITableViewCell
//
//            return cell
//        case 1:
//            let cell = UINib(nibName: "EndPeriodCell", bundle: nil) as! EndPeriodCell
//
//            return cell
//
//        default:
//            return UITableViewCell()
//        }
}

extension NewItemVC: ItemImageCellDelegate {
    // image 上のbuttonを通したcamera VCへの画面遷移
    // navigationのpushを用いた方法
    func takeItemImagePhoto() {
        let cameraVC = CameraVC.instantiate()
        cameraVC.cellIndex = 0
        let navigation = UINavigationController(rootViewController: cameraVC)
        navigation.modalPresentationStyle = .fullScreen
        // fullScreenであるが、1つ前のViewのサイズに合わせてpushされる
        navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    // ただのbuttonを通したcamera VCへの画面遷移
    func takeImagePhotoScreen() {
        let cameraVC = CameraVC.instantiate()
        cameraVC.cellIndex = 0
        let navigation = UINavigationController(rootViewController: cameraVC)
        navigation.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(cameraVC, animated: true)
    }
}

extension NewItemVC: EndPeriodCellDelegate {
    func takeEndPeriodScreen() {
        let cameraVC = CameraVC.instantiate()
        cameraVC.cellIndex = 1
        
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
}

extension NewItemVC: CameraVCDelegate {
    // CameraVCで撮った写真を反映させる
    func didFinishTakePhoto(with imageData: Data, index cellIndex: Int) {
        if cellIndex == 0 {
            // cellを特定
            print("NewItemVC: cell index 0")
            var indexPath: IndexPath
            indexPath = IndexPath(row: cellIndex, section: cellIndex)
            
            
            itemImage = UIImage(data: imageData)!.toUp
        } else {
            // cellIndexが1の時は、賞味期限の方を処理
        }
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
            return UITableView().estimatedRowHeight
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
            return UITableView().estimatedRowHeight
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
            if takeItemImage {
                cell.resultItemImageView.image = itemImage
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
            
            return cell
            
        default:
            return UITableViewCell()
            
        }
        
        
    }
    
    
}
