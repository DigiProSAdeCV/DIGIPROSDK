//
//  CustomView+CheckAndList.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 05/09/22.
//  Copyright © 2022 Jonathan Viloria M. All rights reserved.
//

import UIKit

class CustomView: UIView {
    // MARK: Solo pensado para checkbox o radio - no para combo.
    var data: CustomData? {
        didSet {
            guard let data = data else { return }
            if data.tipo == "radio" || data.tipo == "checkbox" {
                labelTitleText.text = data.title
            } else if data.tipo == "combo" {
                btnCheck.setTitle(data.title, for: []);
            }
            btnCheck.tag = data.id
            if data.tipo == "radio" {
                btnCheck.isMultipleSelectionEnabled = false;
            } else {
                btnCheck.isMultipleSelectionEnabled = true;
                btnCheck.isIconSquare = true
                btnCheck.iconSelected = UIImage(named: "ic_checkBox", in: Cnstnt.Path.framework, compatibleWith: nil)!
            }
            
            if data.tipo == "combo" {
                imageInList.isHidden = true
                labelTitleText.isHidden = true
            } else {
                imageInList.isHidden = false
            }
        }
    }
    
    lazy var btnCheckWithAnchor: CGFloat = 50
    lazy var btnCheckHeightAnchor: CGFloat = 45
    
    lazy var cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    lazy var btnCheck: DLRadioButton = {
        let radioButton = DLRadioButton()
        radioButton.titleLabel?.isHidden = true
        radioButton.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 0.03)
        radioButton.setTitleColor(UIColor.white, for: .normal)
        radioButton.setTitleColor(UIColor.darkGray, for: .selected)
        radioButton.titleLabel!.adjustsFontForContentSizeCategory = true
        radioButton.titleLabel!.lineBreakMode = .byWordWrapping;
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        radioButton.titleLabel!.numberOfLines = 0
        radioButton.backgroundColor = .white
        radioButton.iconColor = UIColor.black
        radioButton.indicatorColor = UIColor.black
        radioButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center;
        return radioButton
    }()
    
    lazy var labelTitleText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
        label.numberOfLines = 3
        return label
    }()
    
    lazy var imageInList: UIImageView = {
        var image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
     
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.addSubview(cardView)
        cardView.addSubview(btnCheck)
        cardView.addSubview(imageInList)
        cardView.addSubview(labelTitleText)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setAutoLayout(imageUbication: String) {
        // MARK: De acuerdo si va - up/left/right/bottom
        
        cardViewConstraints()
        
        switch imageUbication {
        case "up":
           // setHeightCell(height: 60)
            imageUp()
        case "down":
          //  setHeightCell(height: 60)
            imageDown()
        case "right":
          //  setHeightCell(height: 40)
            imageInRight()
        case "left":
          //  setHeightCell(height: 40)
            imageInLeft()
        default:
            print("Opcion no valida.")
        }
    }
    
    public func getHeightCell(imageUbication: String)->Int{
      
        if data?.tipo == "radio" || data?.tipo == "checkbox" {
            switch imageUbication {
            case "up":
                return 60
            case "down":
                return 60
            case "right":
                return 40
            case "left":
                return 40
            default:
                return 50
            }
        } else if data?.tipo == "combo" {
            return 50
        }else{
            return 50
        }
    }
    
    public func setHeightCell(height: Int){
       /* if data?.tipo == "radio" || data?.tipo == "checkbox" {
            cardView.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
        } else if data?.tipo == "combo" {
            cardView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        */
    }
    
    /// This function sets an UIView that will be set as the parent of other elements
    private func cardViewConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: self.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            cardView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        imageInList.isHidden = false
    }
    /// When the JSON does not contain the Valor property
    public func notContainImage() {
        DispatchQueue.main.async {
            self.imageInList.isHidden = true
            self.cardViewConstraints()
        }
        NSLayoutConstraint.activate([
            btnCheck.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            btnCheck.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10.0),
            btnCheck.widthAnchor.constraint(equalToConstant: btnCheckWithAnchor),
            btnCheck.heightAnchor.constraint(equalToConstant: btnCheckHeightAnchor),
            btnCheck.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 5),
            btnCheck.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -5),
            
            labelTitleText.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            labelTitleText.leadingAnchor.constraint(equalTo: btnCheck.trailingAnchor, constant: 10.0),
        ])
    }
    
    private func imageInRight() {
        NSLayoutConstraint.activate([
            btnCheck.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            btnCheck.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            btnCheck.widthAnchor.constraint(equalToConstant: btnCheckWithAnchor),
            btnCheck.heightAnchor.constraint(equalToConstant: btnCheckHeightAnchor),
            btnCheck.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 5),
            btnCheck.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -5),
            
            labelTitleText.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            labelTitleText.leadingAnchor.constraint(equalTo: btnCheck.trailingAnchor, constant: 5),
            
            imageInList.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            imageInList.leadingAnchor.constraint(equalTo: labelTitleText.trailingAnchor, constant: 10),
            imageInList.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            imageInList.heightAnchor.constraint(equalToConstant: 35),
            imageInList.widthAnchor.constraint(equalToConstant: 35),
        ])
    }
    
    private func imageInLeft() {
        NSLayoutConstraint.activate([
            btnCheck.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            btnCheck.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            btnCheck.widthAnchor.constraint(equalToConstant: btnCheckWithAnchor),
            btnCheck.heightAnchor.constraint(equalToConstant: btnCheckHeightAnchor),
            btnCheck.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 5),
            btnCheck.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -5),
            
            imageInList.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            imageInList.leadingAnchor.constraint(equalTo: btnCheck.trailingAnchor, constant: 5),
            imageInList.heightAnchor.constraint(equalToConstant: 35),
            imageInList.widthAnchor.constraint(equalToConstant: 35),

            labelTitleText.leadingAnchor.constraint(equalTo: imageInList.trailingAnchor, constant: 10),
            labelTitleText.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            labelTitleText.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10)
        ])
    }
    
    private func imageDown() {
        NSLayoutConstraint.activate([
            btnCheck.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            btnCheck.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            btnCheck.widthAnchor.constraint(equalToConstant: btnCheckWithAnchor),
            btnCheck.heightAnchor.constraint(equalToConstant: btnCheckHeightAnchor),
            
            labelTitleText.topAnchor.constraint(equalTo: cardView.topAnchor),
            labelTitleText.leadingAnchor.constraint(equalTo: btnCheck.trailingAnchor, constant: 5),
            labelTitleText.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            
            imageInList.topAnchor.constraint(equalTo: labelTitleText.bottomAnchor),
            imageInList.leadingAnchor.constraint(equalTo: labelTitleText.leadingAnchor),
            imageInList.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            imageInList.widthAnchor.constraint(equalToConstant: 45),
            imageInList.heightAnchor.constraint(equalToConstant: 45),
        ])
        
    }
    
    private func imageUp() {
        NSLayoutConstraint.activate([
            btnCheck.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            btnCheck.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            btnCheck.widthAnchor.constraint(equalToConstant: btnCheckWithAnchor),
            btnCheck.heightAnchor.constraint(equalToConstant: btnCheckHeightAnchor),
            
            imageInList.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageInList.widthAnchor.constraint(equalToConstant: 45),
            imageInList.heightAnchor.constraint(equalToConstant: 45),
            imageInList.leadingAnchor.constraint(equalTo: btnCheck.trailingAnchor, constant: 5),
            
            labelTitleText.topAnchor.constraint(equalTo: imageInList.bottomAnchor),
            labelTitleText.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            labelTitleText.leadingAnchor.constraint(equalTo: imageInList.leadingAnchor),
            labelTitleText.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
        ])
    }
    
    public func constraintsForComboDinamicoConfiguration() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: self.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            cardView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            btnCheck.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            btnCheck.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            btnCheck.heightAnchor.constraint(equalToConstant: btnCheckHeightAnchor),
            btnCheck.widthAnchor.constraint(equalToConstant: btnCheckWithAnchor),

            labelTitleText.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            labelTitleText.leadingAnchor.constraint(equalTo: btnCheck.trailingAnchor, constant: 5.0),
        ])
    }
}
