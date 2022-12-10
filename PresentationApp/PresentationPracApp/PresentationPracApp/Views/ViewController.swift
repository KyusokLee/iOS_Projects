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
            // isHiddenも可能
            continueButton.alpha = 0.0
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
    
    // 間隔の配列
    var intervals: [CGFloat] = []
    // スタート時点を定義
    var startingPoint = CGFloat()
    // ページnumberを指定
    var pageIndex: Int = 0
    
    //東京タワーをgoogle上で検索したページURL
    var pracUrl = URL(string: "https://www.google.com/search?q=%E6%9D%B1%E4%BA%AC%E3%82%BF%E3%83%AF%E3%83%BC&rlz=1C5CHFA_enJP991JP991&oq=%E6%9D%B1%E4%BA%AC%E3%82%BF%E3%83%AF%E3%83%BC&aqs=chrome.0.0i355i512j46i175i199i512j0i512l5j46i512j0i512l2.2156j0j1&sourceid=chrome&ie=UTF-8")
    

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
            // スライド機能を実現するnib fileを作成
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
    
    // 最後のページでbuttonを表示するメソッド
    func displayButton(display: Bool) {
        // True: ボタン表示 ,  false: ボタン非表示
        self.continueButton.isUserInteractionEnabled = display
        // alpha（透明度)を用いて、ボタンをhideする
        // isHiddenでもいい
        let alpha = display == true ? 1.0 : 0.0
        // ゆっくりとbuttonの色を変えてあげるように、UIView.animateを用いた
        UIView.animate(withDuration: 0.4, delay: 0) {
            self.continueButton.alpha = alpha
        }
    }
    
    // 最後のページで出てくるボタンを押すと呼び出されるメソッド
    @IBAction func continueButtonAction(_ sender: Any) {
        // safari ページで開くように！
        if let url = self.pracUrl {
            UIApplication.shared.open(url)
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    // ユーザのscrollを行うたびに、呼び出されるメソッド
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 現在のページのindexを取得
        let pageIndex = self.pageIndex
        let firstIndex = pageIndex
        let lastIndex = slides.count - 1
        
        // 現在のscroll Offset値を取得
        let maximumHorizontalOffset = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset = scrollView.contentOffset.x
        
        let maximumVerticalOffset = scrollView.contentSize.height - view.frame.height
        let currentVerticalOffset = scrollView.contentOffset.y
        
        let percentageHorizontalOffset = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset = currentVerticalOffset / maximumVerticalOffset
        
        let percentOffset = CGPoint(x: percentageHorizontalOffset,
                                    y: percentageVerticalOffset)
        //  4つのスライドがあり、1つの値を3つの間隔に分割する必要がある場合、 予想される間隔は、0, 0.33、0.66、1または0、0.34, 0.67, 1のいずれかであり、技術的に数値の四捨五入に関しては、両方の結果どっちも正しい可能性がある。よって、 percentOffset.xがインターバルで常に対応する数値を見つける最善の方法は、percentOffset.xとの差が0.01未満の最初のインターバルを使用すること！
        
        // こうすることで、ページを指でスライドするに伴って、page Controlも変わるようになる
        self.pageIndex = intervals.firstIndex(where: { abs($0 - percentOffset.x) < 0.01 }) ?? firstIndex
        // pageの更新
        presentationPageControl.currentPage = self.pageIndex
        // ボタンを表示
        self.displayButton(display: firstIndex == lastIndex)
        
        // MARK: 🔥HARD...
        // 少し理解で聞いてない部分,,,ネットの資料を参考にした
        // TODO: 🌱以下_ スライドの拡大と縮小に関する計算
        let slideRatio = 1 / CGFloat(lastIndex)
        let slidingRight = (intervals[firstIndex]) < percentOffset.x ? true : false
        // 🔥ただのremainderではなく、truncationRemainderを使った理由
        // 例
        // 13.0.truncatingRemainder(dividingBy: 5)  // 3
        // 13.0.remainder(dividingBy: 5)            // -2
        // 13.0 / 5 = 2.6
        // truncationRemainderは、2を選択して、余りが3となり
        // remainderは、3（四捨五入で切り上げ）を選択して、13 - 5 * 3 = -2となる
        
        let rem = percentOffset.x.truncatingRemainder(dividingBy: slideRatio) / slideRatio
        let x = rem == 0 || intervals.contains(where: { abs($0-percentOffset.x)<0.01 }) ? 0 : rem
        let scale = abs(x > 0 ? ( x > 1 ? 1 : x ) : 1 + x)
        let firstX = slidingRight ? ( 1 - scale > 0 ? 1 - scale : 1) : scale
        
        presentationSlides[firstIndex].stackView.transform = CGAffineTransform(scaleX: firstX, y: firstX)
        
        // define size of next slide, if any
        let right = firstIndex != lastIndex ? Int(pageIndex)+1 : nil
        let left = firstIndex != 0 ? Int(pageIndex)-1 : nil
        let secondIndex: Int? = slidingRight ? right : left
        
        if let second = secondIndex {
            // calculate the second slide's scale
            let secondX = slidingRight ? scale : ( 1-scale > 0 ? 1-scale : 1)
            presentationSlides[second].stackView.transform = CGAffineTransform(scaleX: secondX, y: secondX)
            // calculate the background's frame changes
            let backgroundWidth = backgroundImageView.frame.size.width
            let offset: CGFloat = -percentOffset.x * (backgroundWidth - view.frame.size.width)
            backgroundImageView.frame.origin.x = startingPoint + offset
        }
        
        print(percentOffset.x)
    }
}

