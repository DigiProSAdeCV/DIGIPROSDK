//
//  RequestSuccessView.swift
//  EConsubanco
//
//  Created by Carlos Mendez Flores on 07/04/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation
import UIKit

class RequestSuccessView: UIView {
    
    // MARK: VARIABLES
    
    lazy var backgroundHeader: UIImageView = {
        let imageAsset = UIImage(named: "headerBackground")
        let logoProperties = UIImageView(image: imageAsset)
        logoProperties.translatesAutoresizingMaskIntoConstraints = false
        return logoProperties
    }()
    
  
    let line: UIView = {
        let configLine = UIView()
        configLine.backgroundColor = UIColor(red: 255/255, green: 172/255, blue: 68/255, alpha: 1.0)
        configLine.translatesAutoresizingMaskIntoConstraints = false
        return configLine
    }()
    
    
    lazy var logoConsubanco: UIImageView = {
        let imageAsset = UIImage(named: "principal_logo_icon")
        let logoProperties = UIImageView(image: imageAsset)
        logoProperties.translatesAutoresizingMaskIntoConstraints = false
        return logoProperties
    }()
    
    lazy var flightIcon: UIImageView = {
        let imageAsset = UIImage(named: "fly")
        let logoProperties = UIImageView(image: imageAsset)
        logoProperties.translatesAutoresizingMaskIntoConstraints = false
        return logoProperties
    }()
    
  
    
    let auxText: UILabel = {
        let titleProperties = UILabel()
        titleProperties.text = "Solicitud Enviada"
        titleProperties.translatesAutoresizingMaskIntoConstraints = false
        titleProperties.numberOfLines = 0
        titleProperties.textColor = UIColor(red: 32/255, green: 38/255, blue: 69/255, alpha: 1.0)
        titleProperties.font = UIFont.boldSystemFont(ofSize: 16)
        titleProperties.textAlignment = .center
        titleProperties.backgroundColor = .clear
        return titleProperties
    }()
    
    let auxText2: UILabel = {
        let titleProperties = UILabel()
        titleProperties.text = "Tu solicitud ha sido enviada"
        titleProperties.translatesAutoresizingMaskIntoConstraints = false
        titleProperties.numberOfLines = 0
        titleProperties.textColor = UIColor(red: 32/255, green: 38/255, blue: 69/255, alpha: 1.0)
        titleProperties.font = UIFont.boldSystemFont(ofSize: 16)
        titleProperties.textAlignment = .center
        return titleProperties
    }()
    
    let folio: UILabel = {
        let titleProperties = UILabel()
        let orangeColor = UIColor(red: 226/255, green: 137/255, blue: 62/255, alpha: 1.0)
        titleProperties.text = "Folio 34676"
        titleProperties.translatesAutoresizingMaskIntoConstraints = false
        titleProperties.numberOfLines = 0
        titleProperties.textColor = orangeColor
        titleProperties.font = UIFont.boldSystemFont(ofSize: 16)
        titleProperties.textAlignment = .center
        return titleProperties
    }()
    
    let auxText3: UILabel = {
        let titleProperties = UILabel()
        titleProperties.text = "Estatus en proceso de validación."
        titleProperties.translatesAutoresizingMaskIntoConstraints = false
        titleProperties.numberOfLines = 0
        titleProperties.textColor = UIColor(red: 32/255, green: 38/255, blue: 69/255, alpha: 1.0)
        titleProperties.font = UIFont.boldSystemFont(ofSize: 16)
        titleProperties.textAlignment = .center
        return titleProperties
    }()
    
    let verticalStackForText: UIStackView = {
        let configVerticalStack = UIStackView()
        configVerticalStack.axis = .vertical
        configVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        configVerticalStack.backgroundColor = .white
        configVerticalStack.distribution = .fillEqually
        return configVerticalStack
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle("Aceptar", for: .normal)
        let orangeColor = UIColor(red: 226/255, green: 137/255, blue: 62/255, alpha: 1.0)
        button.backgroundColor = orangeColor
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 0
        return button
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    private func setView() {
        setSubviews()
        setAutolayout()
        addStackView()
    }
    
    private func setSubviews() {
        self.addSubview(backgroundHeader)
        self.addSubview(logoConsubanco)
        self.addSubview(auxText)
        self.addSubview(verticalStackForText)
        self.addSubview(line)
        self.addSubview(acceptButton)
        self.addSubview(flightIcon)
    }
    
    private func addStackView() {
        verticalStackForText.addArrangedSubview(auxText2)
        verticalStackForText.addArrangedSubview(folio)
        verticalStackForText.addArrangedSubview(auxText3)
    }
    
    private func setAutolayout() {
        
        NSLayoutConstraint.activate([
            backgroundHeader.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            backgroundHeader.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0),
            backgroundHeader.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            logoConsubanco.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            logoConsubanco.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.10),
            logoConsubanco.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.10),
            logoConsubanco.centerYAnchor.constraint(equalTo: self.backgroundHeader.centerYAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            line.topAnchor.constraint(equalTo: self.backgroundHeader.bottomAnchor, constant: 0),
            line.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.90),
            line.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            line.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.005)
        ])
        
        NSLayoutConstraint.activate([
            auxText.topAnchor.constraint(equalTo: self.line.bottomAnchor, constant: 32),
            auxText.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            flightIcon.leadingAnchor.constraint(equalTo: auxText.trailingAnchor, constant: 0),
            flightIcon.heightAnchor.constraint(equalTo: self.auxText.heightAnchor),
            flightIcon.widthAnchor.constraint(equalTo: self.auxText.heightAnchor),
            flightIcon.topAnchor.constraint(equalTo: self.line.bottomAnchor, constant: 32)
        ])
        
        
        NSLayoutConstraint.activate([
            verticalStackForText.topAnchor.constraint(equalTo: self.auxText.bottomAnchor, constant: 32),
            verticalStackForText.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.80),
            verticalStackForText.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.30),
            verticalStackForText.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            acceptButton.topAnchor.constraint(equalTo: self.verticalStackForText.bottomAnchor, constant: 32),
            acceptButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.75),
            acceptButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.070),
            acceptButton.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        
    }
    
    
}
