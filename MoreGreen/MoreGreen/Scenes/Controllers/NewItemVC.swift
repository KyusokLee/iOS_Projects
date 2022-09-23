//
//  NewItemVC.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit

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
    
    
    
    
    private(set) var presenter: ItemViewPresenter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Create new item list with camera OCR and barcode")
        // Do any additional setup after loading the view.
    }
    
    private func setUpTableView() {
        createItemTableView.delegate = self
        createItemTableView.dataSource = self
        createItemTableView.separatorStyle = .none
    }
    
    private func registerCell() {
        
        
        
    }
    
    static func instantiate(with imageData: Data) -> NewItemVC {
        let controller = UIStoryboard(name: "NewItemVC", bundle: nil).instantiateInitialViewController() as! NewItemVC
        controller.loadViewIfNeeded()
        controller.configure(with: imageData)
        return controller
    }
    

    @IBAction func dismissTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

private extension NewItemVC {
    func configure(with imageData: Data) {
//        presenter = ItemViewPresenter(
//            jsonParser: ProfileJSONParser(profileCreater: ProfileElementsCreater()),
//            apiClient: GoogleVisonAPIClient(),
//            view: self
//        )
//        // view: self -> protocol規約を守るviewの指定 (delegateと似たようなもの)
        setUpNavigationBar(from: imageData)
    }

    func setUpNavigationBar(from imageData: Data) {
        // private extensionで指定したここだけ使える UIImageのメソッド
        let image = UIImage(data: imageData)
//        resultImageView.image = image
        navigationItem.title = "簡易プロフィール画面"
        let textAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
}

extension NewItemVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cell の情報がsection別に入る
    }
    
    
}
