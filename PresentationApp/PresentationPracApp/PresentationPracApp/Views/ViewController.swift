//
//  ViewController.swift
//  PresentationPracApp
//
//  Created by Kyus'lee on 2022/12/06.
//

import UIKit

struct slide {
    var title = String()
    var subTitle = String()
}

class ViewController: UIViewController {
    
    @IBOutlet weak var presentationScrollView: UIScrollView!
    @IBOutlet weak var presentationPageControl: UIPageControl!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var continueButton: UIButton! {
        didSet {
            continueButton.layer.cornerRadius = continueButton.frame.width / 2
            continueButton.isUserInteractionEnabled = false
            continueButton.isHidden = true
        }
    }
    
    // MARK: ⚠️slideを実装中
    // 途中の段階
    var presentationSlides: [PresentationSlideView] = []
    var slides: [slide] = [
        slide(title: "Hello",
              subTitle: "Tokyo!"),
        slide(title: "Prac",
              subTitle: "yes!")
    ]
    
    var intervals: [CGFloat] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Slideを準備する: loading
        self.getSlides { success in
            print(1)
        }
        
        setUpBackgroundImageView()
        setUpPresentationScrollView()
        setPresentationContentSize()
    }

    // Scroll Viewをviewのsafe Areaの両端に合わせる
    func setUpPresentationScrollView() {
        let scrollView = presentationScrollView
        scrollView?.translatesAutoresizingMaskIntoConstraints = false
        scrollView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        scrollView?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        scrollView?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        
    }
    
    // presentationScrollViewのcontentSizeの設定を行う
    func setPresentationContentSize() {
        presentationScrollView.contentSize = CGSize(width: presentationScrollView.contentSize.width, height: 0)
        presentationScrollView.automaticallyAdjustsScrollIndicatorInsets = false
        presentationScrollView.alwaysBounceVertical = false
        presentationScrollView.alwaysBounceHorizontal = true
        presentationScrollView.isDirectionalLockEnabled = true
    }
    
    func setUpBackgroundImageView() {
        let viewHeight = view.frame.size.height
        let imageWidth = viewHeight * 1.4
        let padding: CGFloat = 10
        
        backgroundImageView.alpha = 0.5
        backgroundImageView.frame = CGRect(x: 0, y: -padding, width: imageWidth, height: viewHeight + padding * 2)
    }
    
    // スライドを作る
    func getSlides(completion: @escaping (Bool) -> ()) {
        for i in 0..<slides.count {
            // use the xib file created for the slide
            let slide = Bundle.main.loadNibNamed("PresentationSlideView",
                                                 owner: self,
                                                 options: nil)?.first as! PresentationSlideView
            // Labelのsetup
            slide.titleLabel.text = slides[i].title
            slide.subTitleLabel.text = slides[i].subTitle
            
            // 配列にslideを格納する
            self.presentationSlides.append(slide)
            
            // 全てのslidesが追加されて、完了されるとき
            if presentationSlides.count == slides.count {
                completion(true)
            }
        }
    }
    
    // Scroll Viewの中にある各スライドのx軸のpositionの値を取得する
    func getIntervals(pages: Int) -> [CGFloat] {
        var intervals: [CGFloat] = []
        let floatPages = CGFloat(pages) - 1
        
        // scroll viewの左端: 0, 右端: 1
        for i in stride(from: 0.0, through: 1.0, by: (1 / floatPages)) {
            // multiply and divide by 100 to switch between Int and CGFloat
            intervals.append(CGFloat(i))
        }
        
        
        return intervals
    }

}

