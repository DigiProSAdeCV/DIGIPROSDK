//
//  RequestSuccessEvents.swift
//  DIGIPROSDKUI
//
//  Created by Alejandro López Arroyo on 29/05/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation
import UIKit


public extension RequestSuccessController {
    func addTargetsButtons() {
        self.interface.acceptButton.addTarget(self, action: #selector(saveForm), for: .touchUpInside)
    }
    
    @objc func saveForm(){
        self.delegate?.didTapSave()
    }
}
