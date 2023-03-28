//
//  TableCollectionViewCell.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 17/11/22.
//  Copyright © 2022 Jonathan Viloria M. All rights reserved.
//

import UIKit

class TableCollectionViewCell: UICollectionViewCell {
    
    public static let identifier = "collTable"
    
    lazy var cardHolder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var btnChck: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(resizeImage(image: UIImage(named: "ic_check", in: Cnstnt.Path.framework, compatibleWith: nil)!, targetSize: CGSize(width: 40, height: 25)), for: .normal)
        return button
    }()
    
    lazy var btnPrw: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(resizeImage(image: UIImage(named: "eye-solid", in: Cnstnt.Path.framework, compatibleWith: nil)!, targetSize: CGSize(width: 40, height: 25)), for: .normal)
        return button
    }()
    
    lazy var btnEdit: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(resizeImage(image:UIImage(named: "pencil", in: Cnstnt.Path.framework, compatibleWith: nil)!, targetSize: CGSize(width: 40, height: 25)), for: .normal)
        return button
    }()
    
    lazy var btnDel: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(resizeImage(image: UIImage(named: "trash", in: Cnstnt.Path.framework, compatibleWith: nil)!, targetSize: CGSize(width: 40, height: 25)), for: .normal)
        return button
    }()
    
    lazy var actionsRow: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10.0
        stack.addArrangedSubview(btnChck)
        stack.addArrangedSubview(btnPrw)
        stack.addArrangedSubview(btnEdit)
        stack.addArrangedSubview(btnDel)
        return stack
    }()
    
    lazy var rowTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Prueba de la coleccion"
        return label
    }()
    
    lazy var scroll: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.addSubview(cardHolder)
        cardHolder.addSubview(rowTitle)
        cardHolder.addSubview(actionsRow)
        cardHolder.addSubview(scroll)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            cardHolder.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardHolder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cardHolder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardHolder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rowTitle.topAnchor.constraint(equalTo: cardHolder.topAnchor, constant: 8.0),
            rowTitle.leadingAnchor.constraint(equalTo: cardHolder.leadingAnchor, constant: 5.0),
            rowTitle.heightAnchor.constraint(equalToConstant: 30),
            actionsRow.topAnchor.constraint(equalTo: cardHolder.topAnchor, constant: 8.0),
            actionsRow.leadingAnchor.constraint(equalTo: rowTitle.trailingAnchor, constant: 5),
            actionsRow.trailingAnchor.constraint(equalTo: cardHolder.trailingAnchor, constant: -20),
            actionsRow.heightAnchor.constraint(equalToConstant: 30),
            scroll.topAnchor.constraint(equalTo: actionsRow.bottomAnchor, constant: 10),
            scroll.leadingAnchor.constraint(equalTo: cardHolder.leadingAnchor, constant: 15),
            scroll.trailingAnchor.constraint(equalTo: cardHolder.trailingAnchor, constant: -15),
            scroll.bottomAnchor.constraint(equalTo: cardHolder.bottomAnchor),
        ])
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
