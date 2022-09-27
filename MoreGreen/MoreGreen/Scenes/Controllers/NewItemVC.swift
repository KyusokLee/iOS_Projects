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

class NewItemVC: UIViewController {
    
    @IBOutlet weak var createViewTitle: UILabel! {
        didSet {
            createViewTitle.text = "食品登録"
            createViewTitle.tintColor = .black
            createViewTitle.font = .systemFont(ofSize: 20, weight: .bold)
        }
    }
    @IBOutlet weak var dismissButton: UIButton! {
        didSet {
            dismissButton.setImage(UIImage(systemName: "multiply.circle")?.withRenderingMode(.alwaysOriginal), for: .normal)
            dismissButton.tintColor = UIColor.systemGray.withAlphaComponent(0.7)
        }
    }
    
    @IBOutlet weak var createItemTableView: UITableView!
    private(set) var presenter: ItemInfoViewPresenter!
    
    // ⚠️まだ、使うかどうか決めてない変数
    var itemImage = UIImage()
    var endPeriodText = ""
    var dDayText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Create new item list with camera OCR and barcode")
        setUpTableView()
        registerCell()
    }
    
    private func setUpTableView() {
        createItemTableView.delegate = self
        createItemTableView.dataSource = self
        createItemTableView.separatorStyle = .none
    }
    
    private func registerCell() {
        // 各Cellを登録
        createItemTableView.register(UINib(nibName: "ItemImageCell", bundle: nil), forCellReuseIdentifier: "ItemImageCell")
        createItemTableView.register(UINib(nibName: "EndPeriodCell", bundle: nil), forCellReuseIdentifier: "EndPeriodCell")
        createItemTableView.register(UINib(nibName: "ButtonCell", bundle: nil), forCellReuseIdentifier: "ButtonCell")
    }
    
    static func instantiate(with imageData: Data, index tag: Int) -> NewItemVC {
        let controller = UIStoryboard(name: "NewItemVC", bundle: nil).instantiateInitialViewController() as! NewItemVC
        controller.loadViewIfNeeded()
        
        if tag == 0 {
            controller.imageConfigure(with: imageData)
        } else {
            controller.periodConfigure(with: imageData)
        }
        
        return controller
    }
    

    @IBAction func dismissTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

private extension NewItemVC {
    // TODO: imageは2週類ある
    // 1つ目:　商品の写真だけを保存
    // 2つ目: OCR結果を用いて、賞味期限の表示
    func imageConfigure(with imageData: Data) {
//        presenter = ItemViewPresenter(
//            jsonParser: ProfileJSONParser(profileCreater: ProfileElementsCreater()),
//            apiClient: GoogleVisonAPIClient(),
//            view: self
//        )
//        // view: self -> protocol規約を守るviewの指定 (delegateと似たようなもの)
        
    }
    
    func periodConfigure(with imageData: Data) {
        
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
    func takeImagePhotoScreen() {
        let cameraVC = CameraVC.instantiate()
        cameraVC.cellIndex = 0
        let navigation = UINavigationController(rootViewController: cameraVC)
        navigation.modalPresentationStyle = .fullScreen
        self.present(navigation, animated: true)
    }
}

extension NewItemVC: EndPeriodCellDelegate {
    func takeEndPeriodScreen() {
        let cameraVC = CameraVC.instantiate()
        cameraVC.cellIndex = 1
        
        let navigation = UINavigationController(rootViewController: cameraVC)
        navigation.modalPresentationStyle = .fullScreen
        self.present(navigation, animated: true)
    }
}

extension NewItemVC: ButtonDelegate {
    func didFinishSaveData() {
        print("save")
    }
}

extension NewItemVC: CameraVCDelegate {
    // CameraVCで撮った写真を反映させる
    func didFinishTakePhoto(with imageData: Data, index cellIndex: Int) {
        if cellIndex == 0 {
            itemImage = UIImage(data: imageData) ?? <#default value#>
        } else {
            
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
            cell.resultItemImageView.image = itemImage
            
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
