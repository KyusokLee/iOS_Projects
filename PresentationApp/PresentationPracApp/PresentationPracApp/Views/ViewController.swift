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
        slide(title: "Welcome to This App",
              subTitle: "Slide Presentation Tokyo ver."),
        slide(title: "Try to scroll the view which is presented horizontally",
              subTitle: "Tokyo Tower.."),
        slide(title: "Would you find the location of Tokyo tower in map?", subTitle: "If you want to find, slide these views until last pages!"),
        slide(title: "Apple Mapで「東京タワー」を表示します",
              subTitle: "右にスライド")
    ]
    
    var intervals: [CGFloat] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Slideを準備する: loading
        self.getSlides { success in
            // 各スライドのx位置を計算してpagesをセットアップする
            self.intervals = self.getIntervals(pages: self.slides.count)
            self.presentationScrollView.delegate = self
            self.setUpSlideScrollView(slides: self.presentationSlides)
            self.presentationPageControl.numberOfPages = self.slides.count
            self.presentationPageControl.currentPage = 0
            self.presentationPageControl.isUserInteractionEnabled = false
            self.view.bringSubviewToFront(self.presentationPageControl)
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
            // initializerを作らずに他のfileで活用できる
            let slide = Bundle.main.loadNibNamed("presentationSlide",
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
    // 100 -> 200 -> 300...になっていく
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
    
    //MARK: 🔥slide scroll viewのsetup
    func setUpSlideScrollView(slides: [PresentationSlideView]) {
        // 実際の内容(Size)（画面View + 残りのスライド）のscroll viewを設定する
        presentationScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height - 100)
        // scrollViewのscollを可能に
        // 🎖isPagingEnabledを trueにすることで、一つのviewごとに止まるように設定する
        presentationScrollView.isPagingEnabled = true
        
        // 各スライドのx位置を設定し、それをscroll Viewに追加する
        for i in 0 ..< slides.count {
            presentationSlides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0,width: view.frame.width,height: view.frame.height)
            presentationScrollView.addSubview(presentationSlides[i])
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    // ユーザのscrollを行うたびに、呼び出されるメソッド
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 現在のscroll Offset値を取得
        let maximumHorizontalOffset = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset = scrollView.contentOffset.x
        
        let maximumVerticalOffset = scrollView.contentSize.height - view.frame.height
        let currentVerticalOffset = scrollView.contentOffset.y
        
        let percentageHorizontalOffset = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset = currentVerticalOffset / maximumVerticalOffset
        
        let percentOffset = CGPoint(x: percentageHorizontalOffset,
                                    y: percentageVerticalOffset)
        print(percentOffset.x)
    }
}

