//
//  FEHeaderView.swift
//  DIGIPROSDK
//
//  Created by Jorge Alfredo Cruz Acuña on 27/02/23.
//  Copyright © 2023 Jonathan Viloria M. All rights reserved.
//

import UIKit
import Foundation

public class FEHeaderView: UIView{
    
    //PUBLIC
    public var txttitulo: String = ""
    public var txtsubtitulo: String = ""
    public var txthelp: String = ""
    public var attibuteString: String = ""
    public var isInfoToolTipVisible = false
    public var toolTip: EasyTipView?
    public var viewInfoHelp : UIView? = nil
    
    //SIMPLE
    public var hiddenTit: Bool = false
    public var hiddenSubtit: Bool = false
    public var heightHeader: CGFloat = 0.0
    public var required: Bool = false
    // MARK: OBJECTS
    public var lblRequired: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "*"
        lbl.textColor = Cnstnt.Color.red2
        lbl.font = UIFont(name: ConfigurationManager.shared.fontLatoBlod, size: CGFloat(ConfigurationManager.shared.fontSizeBig))
        lbl.textAlignment = .center
        return lbl
    }()
    
    public var btnInfo: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "iconfinder_help.png", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        btn.addTarget(self, action: #selector(setAyuda(_:)), for: .touchUpInside)
        return btn
    }()
    
    public var lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = ""
        lbl.isHighlighted = true
        lbl.highlightedTextColor = Cnstnt.Color.dark
        lbl.textColor = Cnstnt.Color.dark
        lbl.font = UIFont(name: ConfigurationManager.shared.fontLatoBlod, size: CGFloat(ConfigurationManager.shared.fontSizeHeight))
        lbl.isHidden = true
        return lbl
    }()
    
    public var lblSubtitle: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = ""
        lbl.textColor = Cnstnt.Color.gray
        lbl.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        lbl.isHidden = true
        return lbl
    }()
    
    public var lblMessage: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = ""
        lbl.textColor = Cnstnt.Color.red2
        lbl.isHidden = true
        return lbl
    }()
    lazy var stackContainer: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 5
        return stack
    }()
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       // setupView()
    }
    
    public func setupView() {
        addSubview(stackContainer)
       // stackContainer.addSubview(lblRequired)
        addSubview(btnInfo)
        stackContainer.addArrangedSubview(lblTitle)
        stackContainer.addArrangedSubview(lblSubtitle)
        stackContainer.addArrangedSubview(lblMessage)
    }
    
    private func setupConstraints() {
            NSLayoutConstraint.activate([
                stackContainer.topAnchor.constraint(equalTo: topAnchor),
                stackContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                btnInfo.topAnchor.constraint(equalTo: topAnchor),
                btnInfo.trailingAnchor.constraint(equalTo: trailingAnchor),
                btnInfo.widthAnchor.constraint(equalToConstant: 25.0),
                btnInfo.heightAnchor.constraint(equalToConstant: 25.0),
                
           /*
            lblRequired.topAnchor.constraint(equalTo: self.topAnchor, constant: 7),
            lblRequired.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 11),
            
            lblTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            lblTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            lblTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            
            // Subtitle
            lblSubtitle.leadingAnchor.constraint(equalTo: self.lblTitle.trailingAnchor, constant: 20),
            lblSubtitle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            lblSubtitle.topAnchor.constraint(equalTo: self.lblRequired.bottomAnchor, constant: 2.5),
            
            // Message
            lblMessage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            lblMessage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            lblMessage.topAnchor.constraint(equalTo: self.lblTitle.bottomAnchor, constant: 10),
            
            // Info
            btnInfo.topAnchor.constraint(equalTo: self.lblSubtitle.bottomAnchor, constant: -15),
            btnInfo.leadingAnchor.constraint(equalTo: self.lblMessage.trailingAnchor, constant: -20),
            btnInfo.widthAnchor.constraint(equalToConstant: 25.0),
            btnInfo.heightAnchor.constraint(equalToConstant: 25.0),*/
        ])
        
    }
    
    // MARK: Set - Title Text
    public func setTitleText(_ text:String) {
        txttitulo = text
        lblTitle.isHidden = text == "" ? true : false
        lblTitle.text = text
    }
    
    // MARK: Set - Subtitle Text
    public func setSubtitleText(_ text:String) {
        txtsubtitulo = text
        lblSubtitle.isHidden = text == "" ? true : false
        lblSubtitle.text = text
    }
    
    // MARK: Set - Message
    public func setMessage(_ string: String) {
        lblMessage.isHidden = string == "" ? true : false
        lblMessage.text = string
        lblMessage.font =  string.count > 60 ? UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))?.withSize(10) :  UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
    }
    
    public func setHelpText(_ string: String){
        txthelp = string
    }
    
    // MARK: Set - TextStyle
    public func setTextStyle(_ style: String) {
        lblTitle.font = self.lblTitle.font.setStyle(style)
        lblSubtitle.font = self.lblSubtitle.font.setStyle(style)
        lblMessage.font = self.lblSubtitle.font.setStyle(style)
    }
    
    // MARK: Set - Decoration
    public func setDecoration(_ decor: String) {
        self.lblTitle.attributedText = self.lblTitle.text?.setDecoration(decor)
        self.lblSubtitle.attributedText = self.lblSubtitle.text?.setDecoration(decor)
    }
    
    // MARK: Set - Alignment
    public func setAlignment(_ align: String) {
        self.lblTitle.textAlignment = self.lblTitle.setAlignment(align)
        self.lblSubtitle.textAlignment = self.lblSubtitle.setAlignment(align)
    }
    
    // MARK: Set - OcultarTitulo
    public func setOcultarTitulo(_ bool: Bool) {
        self.lblTitle.isHidden = bool
    }

    
    // MARK: Set - OcultarSubtitulo
    public func setOcultarSubtitulo(_ bool: Bool) {
        self.lblSubtitle.isHidden = bool
    }
    
    // MARK: Set - Requerido
    public func setRequerido(_ bool: Bool){
        required = bool
        if bool{
            self.lblTitle.textColor = Cnstnt.Color.red2
            self.lblTitle.text = "* \(txttitulo)"
        }else{
            self.lblTitle.textColor = Cnstnt.Color.gray
            self.lblTitle.text = txttitulo
        }
    }
    
    // MARK: Set - Height From Titles
    public func setHeightFromTitles() {
       /* let ttl = self.lblTitle.calculateMaxLines2(((self.frame.width) - 50), aux: self.lblTitle.font)
        let sttl = self.lblSubtitle.calculateMaxLines2(((self.frame.width) - 50), aux: self.lblSubtitle.font)
        
        self.lblTitle.numberOfLines = ttl
        self.lblSubtitle.numberOfLines = sttl
        var httl: CGFloat = 0
        var hsttl: CGFloat = 0
        let hmsg: CGFloat = 0
        if hiddenTit{
            if ttl != 0{
                self.heightHeader -= self.lblTitle.font.lineHeight * CGFloat(ttl)
            }
        }else{
            if ttl > 10{
                httl = (CGFloat(ttl) * self.lblTitle.font.lineHeight)
                httl -= 250
            }else{
                httl = (CGFloat(ttl) * self.lblTitle.font.lineHeight) - self.lblSubtitle.font.lineHeight
            }
        }
        if hiddenSubtit {
            if sttl != 0{
                self.heightHeader -= self.lblSubtitle.font.lineHeight * CGFloat(sttl)
            }
        }else{
            if sttl > 10 {
                hsttl = (CGFloat(sttl) * self.lblSubtitle.font.lineHeight)
                hsttl -= 250
            }else{
                hsttl = (CGFloat(sttl) * self.lblSubtitle.font.lineHeight) - self.lblSubtitle.font.lineHeight
            }
           
        }
        
        self.heightHeader = httl + hsttl + hmsg
        if self.heightHeader == 0 && (!self.lblRequired.isHidden || self.txthelp != "")
        {   self.heightHeader = 30 }
        heightHeader = 84 + CGFloat(heightHeader)*/
    }
    
    // MARK: Set - Ayuda
    @objc public func setAyuda(_ sender: Any) {
        self.btnInfo.isHidden = false
        self.toogleToolTip(self.txthelp)
    }
    
    // MARK: ShowDismiss - alertHelp
    public func toogleToolTip(_ help: String) {
        if self.isInfoToolTipVisible{
            self.toolTip?.dismiss()
            self.isInfoToolTipVisible = false
        }else{
            self.toolTip = EasyTipView(text: help, preferences: EasyTipView.globalPreferences)
            self.toolTip?.show(forView: self.btnInfo, withinSuperview: viewInfoHelp)
            self.isInfoToolTipVisible = true
        }
    }
    
}

