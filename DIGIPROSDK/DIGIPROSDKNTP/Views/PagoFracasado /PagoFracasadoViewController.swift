//
//  PagoFracasadoViewController.swift
//  DIGIPROSDKNTP
//
//  Created by Alberto Echeverri Carrillo on 06/05/21.
//

import UIKit

public class PagoFracasadoViewController: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func didTapCancelar(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
