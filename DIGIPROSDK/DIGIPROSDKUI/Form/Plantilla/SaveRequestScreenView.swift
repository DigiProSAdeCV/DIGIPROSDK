//
//  SaveRequestScreenView.swift
//  EConsubanco
//
//  Created by Carlos Mendez Flores on 22/07/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation
import UIKit


class SaveRequestScreenView: UIView {
    
    lazy var backgroundHeader: UIImageView = {
        let imageAsset = UIImage(named: "headerBackground")
        let logoProperties = UIImageView(image: imageAsset)
        logoProperties.translatesAutoresizingMaskIntoConstraints = false
        return logoProperties
    }()
    
    lazy var logoConsubanco: UIImageView = {
        let imageAsset = UIImage(named: "principal_logo_icon")
        let logoProperties = UIImageView(image: imageAsset)
        logoProperties.translatesAutoresizingMaskIntoConstraints = false
        logoProperties.contentMode = .scaleAspectFill
        return logoProperties
    }()
    
    let line: UIView = {
        let configLine = UIView()
        configLine.backgroundColor = UIColor(red: 255/255, green: 172/255, blue: 68/255, alpha: 1.0)
        configLine.translatesAutoresizingMaskIntoConstraints = false
        return configLine
    }()
    
    let message: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Solicitud guardada en la sección de prellenado"
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 24/255, green: 32/255, blue: 111/255, alpha: 1.0)
        return label
    }()
    
    let folioMessage: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 255/255, green: 172/255, blue: 68/255, alpha: 1.0)
        return label
    }()
    
    let acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle("Aceptar", for: .normal)
        button.backgroundColor = UIColor(red: 255/255, green: 172/255, blue: 68/255, alpha: 1.0)
        button.titleLabel?.textColor = UIColor.white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        return button
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initComponents()
    }
    
    func initComponents() {
        addComponents()
        setAutolayout()
    }
    
    func addComponents() {
        self.addSubview(backgroundHeader)
        self.addSubview(logoConsubanco)
        self.addSubview(line)
        self.addSubview(message)
        self.addSubview(folioMessage)
        self.addSubview(acceptButton)
    }
    
    func setAutolayout() {
        
        NSLayoutConstraint.activate([
            backgroundHeader.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            backgroundHeader.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0),
            backgroundHeader.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            backgroundHeader.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.20)
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
            message.bottomAnchor.constraint(equalTo: self.acceptButton.topAnchor, constant: -UIScreen.main.bounds.height * 0.12),
            message.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            message.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.90)
        ])
        
        NSLayoutConstraint.activate([
            folioMessage.topAnchor.constraint(equalTo: self.message.bottomAnchor, constant:  12.0),
            folioMessage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            folioMessage.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.90)
        ])
        
        NSLayoutConstraint.activate([
            acceptButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: UIScreen.main.bounds.height * 0.10),
            acceptButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.65),
            acceptButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.080),
            acceptButton.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
    }
    
}
