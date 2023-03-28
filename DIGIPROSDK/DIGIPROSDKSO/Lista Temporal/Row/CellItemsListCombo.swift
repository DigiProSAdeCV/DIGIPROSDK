//
//  CellItemsListCombo.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 25/10/22.
//  Copyright © 2022 Jonathan Viloria M. All rights reserved.
//

import UIKit

class CellItemsListCombo: UITableViewCell {
    
    static let ID = "CellItemsListCombo"
    
    lazy var nameItem: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(12))
        label.textAlignment = .left
        label.textColor = UIColor.black
        return label
    }()
    
    lazy var containerCell: UIView = {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 1.2
        view.backgroundColor = UIColor.gray
        return view
    }()
    
    lazy var cellInsideContainerCell : UIView = {
        let view : UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        addSubview(containerCell)
        addSubview(nameItem)
        containerCell.addSubview(cellInsideContainerCell)
        setAutoLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented - CellItemsListCombo")
    }
    
    private func setAutoLayout() {
        NSLayoutConstraint.activate([
            containerCell.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
            containerCell.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2),
            containerCell.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -2),
            containerCell.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),
            
            cellInsideContainerCell.topAnchor.constraint(equalTo: containerCell.topAnchor, constant: 2),
            cellInsideContainerCell.leadingAnchor.constraint(equalTo: containerCell.leadingAnchor, constant: 2),
            cellInsideContainerCell.trailingAnchor.constraint(equalTo: containerCell.trailingAnchor, constant: -2),
            cellInsideContainerCell.bottomAnchor.constraint(equalTo: containerCell.bottomAnchor, constant: -2),
            
            nameItem.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            nameItem.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            nameItem.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -35),
            nameItem.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            
        ])
    }
}
