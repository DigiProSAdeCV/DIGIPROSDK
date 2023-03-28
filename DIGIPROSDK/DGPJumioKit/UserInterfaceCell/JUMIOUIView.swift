//
//  JUMIOUIView.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 26/02/23.
//  Copyright © 2023 Jonathan Viloria M. All rights reserved.
//

import UIKit

protocol JUMIOUIViewDelegate: AnyObject {
    func ocrJumioButtonAction()
    func editButtonAction()
    func btnInfoAction()
}

class JUMIOUIView: UIView {
    // MARK: Views
    public lazy var bgHabilitado: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var ocrJumioButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(ocrJumioButtonAction(_:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.lightGray
        button.setTitle("  Realizar OCR  ", for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        return button
    }()
    public lazy var editButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(editButtonAction(_:)), for: UIControl.Event.touchUpInside)
        button.backgroundColor = UIColor.lightGray
        button.setTitle("  Editar OCR  ", for: UIControl.State.normal)
        button.setTitleColor(UIColor.black, for: UIControl.State.normal)
        return button
    }()
    public lazy var btnInfo: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(btnInfoAction(_:)), for: UIControl.Event.touchUpInside)
        button.setTitle("?", for: UIControl.State.normal)
        return button
    }()
    
    public lazy var lblMoreInfo: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: ConfigurationManager.shared.fontLatoBlod, size: CGFloat(ConfigurationManager.shared.fontSizeBig))
        return label
    }()
    public lazy var lblRequired: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "*"
        label.font = UIFont(name: ConfigurationManager.shared.fontLatoBlod, size: CGFloat(ConfigurationManager.shared.fontSizeBig))
        label.textColor = UIColor.systemRed
        return label
    }()
    public lazy var lblMessage: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: ConfigurationManager.shared.fontLatoBlod, size: CGFloat(ConfigurationManager.shared.fontSizeBig))
        return label
    }()
    public lazy var lblTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: ConfigurationManager.shared.fontLatoBlod, size: CGFloat(ConfigurationManager.shared.fontSizeBig))
        return label
    }()
    public lazy var lblSubtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: ConfigurationManager.shared.fontLatoBlod, size: CGFloat(ConfigurationManager.shared.fontSizeBig))
        return label
    }()
    
    private weak var delegate: JUMIOUIViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addViewsToParent()
        
    }
    
    convenience init(delegate: JUMIOUIViewDelegate?) {
        self.init()
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: OBJC Functions
    @objc private func ocrJumioButtonAction(_ sender: UIButton) {
        delegate?.ocrJumioButtonAction()
    }
    @objc private func btnInfoAction(_ sender: UIButton) {
        delegate?.btnInfoAction()
    }
    @objc private func editButtonAction(_ sender: UIButton) {
        delegate?.editButtonAction()
    }
    
    // MARK: UI Configuration.
    public func addViewsToParent() {
        let secondaryViews: [UIView] = [
                                        bgHabilitado,
                                        ocrJumioButton,
                                        editButton,
                                        btnInfo,
                                        lblMoreInfo,
                                        lblRequired,
                                        lblMessage,
                                        lblTitle,
                                        lblSubtitle,
                                        ]
        secondaryViews.forEach({ self.addSubview($0) })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            bgHabilitado.topAnchor.constraint(equalTo: topAnchor),
            bgHabilitado.bottomAnchor.constraint(equalTo: bottomAnchor),
            bgHabilitado.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgHabilitado.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            lblRequired.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            lblRequired.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            lblRequired.heightAnchor.constraint(equalToConstant: 20),
            lblRequired.widthAnchor.constraint(equalToConstant: 20),
            
            btnInfo.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            btnInfo.trailingAnchor.constraint(equalTo: lblRequired.leadingAnchor, constant: -5),
            btnInfo.heightAnchor.constraint(equalToConstant: 20),
            btnInfo.widthAnchor.constraint(equalToConstant: 20),
            
            lblTitle.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            lblTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            lblTitle.heightAnchor.constraint(equalToConstant: 40),
            
            lblSubtitle.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: 8),
            lblSubtitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            lblSubtitle.heightAnchor.constraint(equalToConstant: 30),
            
            lblMoreInfo.topAnchor.constraint(equalTo: lblSubtitle.bottomAnchor, constant: 8),
            lblMoreInfo.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            lblMoreInfo.heightAnchor.constraint(equalToConstant: 30),
            
            editButton.topAnchor.constraint(equalTo: lblSubtitle.bottomAnchor, constant: 12),
            editButton.heightAnchor.constraint(equalToConstant: 36),
            editButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            editButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            ocrJumioButton.topAnchor.constraint(equalTo: lblSubtitle.bottomAnchor, constant: 12),
            ocrJumioButton.heightAnchor.constraint(equalToConstant: 36),
            ocrJumioButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            ocrJumioButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            lblMessage.topAnchor.constraint(equalTo: ocrJumioButton.bottomAnchor, constant: 10),
            lblMessage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            lblMessage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            //lblMessage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            
        ])
    }
    
}
