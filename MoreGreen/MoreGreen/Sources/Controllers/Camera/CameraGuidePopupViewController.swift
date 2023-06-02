//
//  CameraGuidePopupViewController.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2023/03/11.
//

import UIKit
import CoreData

protocol CameraGuidePopupDelegate: AnyObject {
    func shouldShowCameraGuideViewAgain()
    func shouldHideCameraGuideView()
}

// MARK: - Life Cycle and Variables
final class CameraGuidePopupViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
        
    weak var delegate: CameraGuidePopupDelegate?
    var checkState = [CheckState]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScreen()
    }
}

// MARK: - Function and Logic
private extension CameraGuidePopupViewController {
    @IBAction func didTapCancelButton(_ sender: Any) {
        // 今後もCameraGuideViewが表示されるように
        saveCameraGuideViewCheckState(enabled: true)
        delegate?.shouldShowCameraGuideViewAgain()
        self.dismiss(animated: true)
    }
    
    // checkButton -> CoreDataのcheckStateをTrueにする
    @IBAction func didTapCheckButton(_ sender: Any) {
        print("check state true!")
        // 今後、CameraGuideViewが表示されないように
        saveCameraGuideViewCheckState(enabled: false)
        delegate?.shouldHideCameraGuideView()
        self.dismiss(animated: true)
    }
    
    // ここで、ViewのUIを確率する
    func setUpScreen() {
        setUpPopUpView()
        setUpCheckImageView()
        setUpTitleLabel()
        setUpDescriptionLabel()
        setUpCancelButton()
        setUpCheckButton()
    }
    
    func setUpPopUpView() {
        popupView.backgroundColor = UIColor.white
        popupView.layer.cornerRadius = 8
        popupView.layer.masksToBounds = true
    }
    
    func setUpCheckImageView() {
        let image = UIImage(systemName: "checkmark.circle")?.withTintColor(UIColor(rgb: 0x36B700).withAlphaComponent(0.6), renderingMode: .alwaysOriginal)
        checkImageView.image = image
    }
    
    func setUpTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.text = "今後、表示しない"
        titleLabel.textAlignment = .center
    }
    
    func setUpDescriptionLabel() {
        descriptionLabel.font = .systemFont(ofSize: 15, weight: .light)
        descriptionLabel.textColor = .black
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "左上のはてなマークを押すと、カメラの使用方法を確認できます"
        descriptionLabel.textAlignment = .center
    }
    
    func setUpCancelButton() {
        cancelButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.7)
        cancelButton.setTitle("取り消す", for: .normal)
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .light)
    }
    
    func setUpCheckButton() {
        checkButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
        checkButton.setTitle("確認", for: .normal)
        checkButton.setTitleColor(.white, for: .normal)
        checkButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
    }
    
    // CameraGuideViewのcheckStateの状態を保存 (CoredataのChectStateを更新、保存する)
    // ⚠️途中の段階: checkStateの中で、showCameraGuideといったtypeだけ利用したいのに、全部持ってくる必要があるのか
    // 考えられる解決策: CoreDataじゃなく、singleToneでsharingするといいかもって思った
    // CoreDataで新しく保存するとかじゃなくて、Bool Typeを更新するだけなんで、appendとかのデータの追加はいらない
    func saveCameraGuideViewCheckState(enabled: Bool) {
        let fetchRequest: NSFetchRequest<CheckState> = CheckState.fetchRequest()
        let context = appDelegate.persistentContainer.viewContext
        do {
            let results = try context.fetch(fetchRequest)
            print("localに保存されているcheckstate: ", results)
            // 既存の設定値を読み込む
            if let checkState = results.first {
                // 既存の設定をUpdate
                checkState.setValue(enabled, forKey: "showCameraGuideView")
            } else {
                // 設定値がないのであれば、新しく設定を生成
                let entity = NSEntityDescription.entity(forEntityName: "CheckState", in: context)!
                let checkState = NSManagedObject(entity: entity, insertInto: context)
                checkState.setValue(enabled, forKey: "showCameraGuideView")
            }
            
            //　Dataを更新
            appDelegate.saveContext()
        } catch let error {
            print("Could not fetch. \(error.localizedDescription)")
        }
    }
}
