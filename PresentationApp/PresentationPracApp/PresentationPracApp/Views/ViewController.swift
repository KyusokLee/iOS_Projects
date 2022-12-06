//
//  ViewController.swift
//  PresentationPracApp
//
//  Created by Kyus'lee on 2022/12/06.
//

import UIKit

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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
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

}

