//
//  ItemListVC.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/09/22.
//

import UIKit

class ItemListVC: UIViewController {
    
    @IBOutlet weak var itemListTableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        registerCell()
    }
    
    func setUpTableView() {
        itemListTableView.delegate = self
        itemListTableView.dataSource = self
        itemListTableView.separatorStyle = .singleLine
        itemListTableView.reloadData()
    }
    
    func registerCell() {
        itemListTableView.register(UINib(nibName: "ItemCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
    }

}

extension ItemListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
