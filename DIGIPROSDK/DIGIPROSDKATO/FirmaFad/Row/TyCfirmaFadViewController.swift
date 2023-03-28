//
//  TyCfirmaFadViewController.swift
//  DIGIPROSDKATO
//
//  Created by Alejandro López Arroyo on 18/05/21.
//  Copyright © 2021 Jonathan Viloria M. All rights reserved.
//

import UIKit


class TyCfirmaFadViewController: UIViewController {
    
    @IBOutlet weak var tycTextView: UITextView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var tycView: UIView!
    
    
    public var onFinishedAction: ((_ result: Result<Bool, Error>) -> Void)?

    var tycFirma: String = ""
    var iconClick = true
    var flagtyc: Bool = false
    
    func configure(onFinishedAction: ((_ result: Result<Bool, Error>) -> Void)? = nil) {
        //TODO: set number of fingers to scan in options
        self.onFinishedAction = onFinishedAction
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tycView.layer.cornerRadius = 15.0
        self.checkImage.image = UIImage(named: "ic_uncheck", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.tycTextView.text = self.tycFirma
        self.tycTextView.isUserInteractionEnabled = false
        if flagtyc{
            self.acceptButton.isUserInteractionEnabled = false
            self.checkImage.image = UIImage(named: "ic_check_c", in: Cnstnt.Path.framework, compatibleWith: nil)
        }
        // Do any additional setup after loading the view.
    }


    @IBAction func acceptAction(_ sender: UIButton) {
        
        if(iconClick == true) {
            self.checkImage.image = UIImage(named: "ic_check_c", in: Cnstnt.Path.framework, compatibleWith: nil)
        } else {
            self.checkImage.image = UIImage(named: "ic_uncheck", in: Cnstnt.Path.framework, compatibleWith: nil)
        }

        iconClick = !iconClick
        self.cancelButton.isUserInteractionEnabled = false
        self.acceptButton.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(900)) {
            self.dismiss(animated: true, completion: nil)
            self.onFinishedAction?(.success(true))
        }

    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
