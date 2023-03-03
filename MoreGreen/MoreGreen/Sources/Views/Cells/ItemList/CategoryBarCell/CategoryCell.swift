//
//  CategoryCell.swift
//  MoreGreen
//
//  Created by Kyus'lee on 2022/11/06.
//

import UIKit

// MARK: 🔥Category Tabbarの中に格納される Category Collection View Cell

class CategoryCell: UICollectionViewCell {
    // cellのところで、idenfierを直接設定するようにした
    static let identifier = "CategoryCell"
    private var textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func setText(text: String) {
        self.textLabel.text = text
    }
    
    //クリックしたとき、textの色が変わるように
    override var isSelected: Bool {
        didSet {
            let selectedColor = UIColor(rgb: 0x36B700).withAlphaComponent(0.9)
            let defaultText = UIFont.systemFont(ofSize: 14)
            let boldText = UIFont.boldSystemFont(ofSize: 14)
            textLabel.font = isSelected ? boldText : defaultText
            textLabel.textColor = isSelected ? selectedColor : .gray
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addSubview(textLabel)
        setAutoLayout()
    }

    private func setAutoLayout() {
        NSLayoutConstraint.activate([
            textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}
