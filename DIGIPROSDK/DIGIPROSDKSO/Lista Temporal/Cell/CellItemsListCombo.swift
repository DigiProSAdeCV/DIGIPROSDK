//
//  CellItemsListCombo.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 01/06/22.
//  Copyright © 2022 Jonathan Viloria M. All rights reserved.
//

import UIKit

class CellItemsListCombo: UITableViewCell {

    static let ID = "CellItemsListCombo"
    
    var nameItem: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(12))
        label.textAlignment = .left
        label.textColor = UIColor.black
        return label
    }()
      
    let checkItem: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.image = UIImage(named: "ic_check", in: Cnstnt.Path.framework, compatibleWith: nil)
        img.tintColor = UIColor.black
        return img
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        self.addSubview(nameItem)
        self.addSubview(checkItem)
        setAutoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented - CellItemsListCombo")
    }
    
    private func setAutoLayout() {
        NSLayoutConstraint.activate([
            nameItem.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            nameItem.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            nameItem.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -35),
            nameItem.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            checkItem.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            checkItem.heightAnchor.constraint(equalToConstant: 30),
            checkItem.widthAnchor.constraint(equalToConstant: 30),
            checkItem.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5)
        ])
    }
}
