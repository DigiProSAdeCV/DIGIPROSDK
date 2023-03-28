//
//  PreviewTxtFADViewController.swift
//  DIGIPROSDKATO
//
//  Created by Desarrollo on 13/07/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation
import UIKit


class PreviewTxtFADViewController: UIViewController{
    
    var preview: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func customInit(){
        self.view.backgroundColor = UIColor.init(hue: 0/255, saturation: 0/255, brightness: 100/255, alpha: 0.8)
        let txtFAD = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.height))
        txtFAD.text = preview
        txtFAD.isEditable = false
        txtFAD.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        txtFAD.clipsToBounds = true
        self.view.addSubview(txtFAD)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
