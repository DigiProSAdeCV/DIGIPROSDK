//
//  RequestSucessController.swift
//  EConsubanco
//
//  Created by Carlos Mendez Flores on 07/04/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation
import UIKit


public protocol RequestSuccessControllerDelegate {
    func didTapSave()
}

public class RequestSuccessController: UIViewController {
    
    let interface: RequestSuccessView = {
           let interface = RequestSuccessView(frame: CGRect.zero)
           interface.translatesAutoresizingMaskIntoConstraints = false
           return interface
       }()
    required init(UI: RequestSuccessView) {
        super.init(nibName: nil, bundle: Cnstnt.Path.framework)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var delegate: RequestSuccessControllerDelegate!
    public var folioEconsubanco = ""
    public var titlePage: String = ""
       
    public override func viewDidLoad() {
           super.viewDidLoad()
   
           initComponents()
        self.addTargetsButtons()
        self.interface.folio.text = "Folio: \(self.folioEconsubanco)"
        if self.titlePage == "Biométrico" || self.titlePage == "Captación"{
            self.interface.auxText.text = "Biométrico enviado."
            self.interface.auxText2.isHidden = true
            self.interface.folio.text = "FOLIO PROBANK: \(self.folioEconsubanco)"
        }
           
       }
       
       private func initComponents() {
           setSubviews()
           setAutolayout()
           // addActionButton()
       }
       
       private func setSubviews() {
           _ = UIColor(red: 32/255, green: 38/255, blue: 69/255, alpha: 1.0)
           view.backgroundColor = UIColor.white
           view.addSubview(interface)
       }
       
       private func setAutolayout() {
           NSLayoutConstraint.activate([
               interface.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
               interface.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               interface.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
               interface.leadingAnchor.constraint(equalTo: view.leadingAnchor)
           ])
           
       }
    
    
}
