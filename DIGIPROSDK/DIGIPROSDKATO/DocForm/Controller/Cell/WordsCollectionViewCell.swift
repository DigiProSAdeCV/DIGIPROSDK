//
//  WordsCollectionViewCell.swift
//  DocForm
//
//  Created by Jose Eduardo Rodriguez on 11/01/23.
//

import UIKit

final class PDFOCRCollectionViewCell: UICollectionViewCell {
    static let NSIdentifier: String = "PDFOCRCollectionViewCell"
    lazy var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        titleLabel.textColor = UIColor.black
        titleLabel.layer.cornerRadius = 8
        contentView.layer.cornerRadius = 5
        contentView.layer.shadowColor = UIColor.label.cgColor
        contentView.layer.shadowOffset = CGSize(width: -1, height: 1)
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.gray.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = contentView.bounds
        titleLabel.font = .italicSystemFont(ofSize: 13)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.titleLabel.backgroundColor = UIColor.lightGray
            } else {
                self.titleLabel.backgroundColor = UIColor.white
            }
        }
    }
}

final class HeaderForSectionsReusableView: UICollectionReusableView {
    static let ReusableViewIdentifier: String = "HeaderForSections"
    static let headerKind : String = "headerKind"
    lazy var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.textColor = UIColor.black
        titleLabel.font = .italicSystemFont(ofSize: 15)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds
    }
}
