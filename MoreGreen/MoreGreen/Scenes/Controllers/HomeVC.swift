//
//  HomeVC.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit

// TODO: ⚠️Home VCの方で、Layout 警告がでてる
// heightを消すことで、一つのエラーを無くなった
// ⚠️しかし、まだ、contentOffsetの方で警告が出てる

class HomeVC: UIViewController {
    
    @IBOutlet weak var homeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("this is home view")
        setUpTableView()
        registerCell()
        homeTableView.reloadData()
        updateViewConstraints()
    }
    
    private func setUpTableView() {
        homeTableView.delegate = self
        homeTableView.dataSource = self
    }
    
    private func registerCell() {
        homeTableView.register(UINib(nibName: "HomeCardViewCell", bundle: nil), forCellReuseIdentifier: "HomeCardViewCell")
    }


}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return UITableView.automaticDimension
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 200
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCardViewCell", for: indexPath) as! HomeCardViewCell
            cell.selectionStyle = .none

            return cell

        default:
            return UITableViewCell()
        }
    }


}

