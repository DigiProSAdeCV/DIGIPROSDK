//
//  BugsViewController.swift
//  DGApp
//
//  Created by Alejandro Lopez Arroyo on 1/17/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import UIKit


public class BugsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var txtField: UITextView!
    
    public var auxLogsGeol : Bool = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        self.txtField.text = ""
        self.txtField.setContentOffset(CGPoint.zero, animated: true)
        
        titleLabel.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 19.0)
        backButton.titleLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 17.0)
        txtField.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
        
        self.txtField.insertText(ConfigurationManager.shared.utilities.readLogger("log.txt"));
        self.txtField.insertText(ConfigurationManager.shared.utilities.readLogger("error.txt"));
        self.backButton.setImage(UIImage(named:"ic_back_blue", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        if self.navigationController != nil{ self.navigationController?.popViewController(animated: true)
        }else{ self.dismiss(animated: true, completion: nil) }
    }
}
