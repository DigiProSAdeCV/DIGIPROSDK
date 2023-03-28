//
//  NotificationsCellController.swift
//  EConsubanco
//
//  Created by Desarrollo JBH on 04/06/20.
//  Copyright © 2020 Digipro Movil. All rights reserved.
//

import UIKit
import  DIGIPROSDK

public class NotificationsCellController: UITableViewCell {
    
    @IBOutlet weak var txtMoreInfo: UITextView!
    @IBOutlet weak var titleTemplate: UILabel!
    @IBOutlet weak var descriptionTemplate: UILabel!
    @IBOutlet var fechaLbl: UILabel!
    @IBOutlet weak var cardView: UIView!
    // New and Check
    @IBOutlet var newPushBtn: UIButton!
    @IBOutlet var btnCheck: DLRadioButton!
    
}
