//
//  SaveRequestScreenController.swift
//  EConsubanco
//
//  Created by Carlos Mendez Flores on 22/07/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation
import UIKit


public protocol SaveRequestScreenControllerDelegate {
    func didTapAccept()
}

public typealias ToggleAcept = (_ infoToReturn :NSString) ->()

public class SaveRequestScreenController: UIViewController {
    
    public var completionBlock:ToggleAcept?
    public lazy var hud: JGProgressHUD = JGProgressHUD(style: .dark)
    var UI: SaveRequestScreenView?
    public var delegate: SaveRequestScreenControllerDelegate!
    public var titlePage = ""
    var sdkAPI = APIManager<SaveRequestScreenController>()
    
    required init(UI: SaveRequestScreenView, folio: String) {
        super.init(nibName: nil, bundle: nil)
        self.UI = UI
        self.UI?.folioMessage.text = "Folio solicitud: \(folio)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        self.view = self.UI
        self.view.backgroundColor = .white
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if self.titlePage.contains("Biométrico") || self.titlePage.contains("Captación"){
            self.UI?.message.text = "Biométrico guardado en sección por enviar."
            self.UI?.folioMessage.isHidden = true
            addActionButtons()
        }else{
            hud.show(in: self.view)
            addActionButtons()
            self.sdkAPI.DGSDKdownloadFormats(delegate: self)
                 .then { response in
                     self.hud.dismiss(animated: true)
                 }.catch { error in
                     self.hud.dismiss(animated: true)
                     
             }
        }
        
    }
    
    func addActionButtons() {
        UI?.acceptButton.addTarget(self, action: #selector(toogleAccept), for: .touchUpInside)
        guard let cb = completionBlock else { return }
        cb("aceptar")
    }
    
    @objc func toogleAccept() {
        if self.delegate != nil  {
          self.delegate.didTapAccept()
        }
        guard let cb = self.completionBlock else { return }
        cb("goFirstTab")
    }
    
    
}

extension SaveRequestScreenController: APIDelegate{
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) {
        
    }
    
    public func sendStatusCodeMessage(message: String, error: enumErrorType) {
        
    }
    
    public func didSendError(message: String, error: enumErrorType) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(850)) {
            let bannerNew = StatusBarNotificationBanner(title: "\(message)", style: .warning)
            bannerNew.show(bannerPosition: .bottom)
        }

    }
    
    public func didSendResponse(message: String, error: enumErrorType) {
        
    }
    
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {
        
    }
    
    func sendStatus(message: String, error: String, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    func sendStatusCodeMessage(message: String, error: String) { }
    func didSendError(message: String, error: String) { }
    func didSendResponse(message: String, error: String) { }
    func didSendResponseHUD(message: String, error: String, porcentage: Int) { }
}
