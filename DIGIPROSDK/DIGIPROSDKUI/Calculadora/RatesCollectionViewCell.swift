//
//  RatesCollectionViewCell.swift
//  DIGIPROSDKUI
//
//  Created by Alejandro López Arroyo on 23/03/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import UIKit

class RatesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var labelDiscount: UILabel!
    @IBOutlet weak var labelRates: UILabel!
    @IBOutlet weak var labelCat: UILabel!
    @IBOutlet weak var labelTotal: UILabel!
    @IBOutlet weak var labelDescT: UILabel!
    
    override func awakeFromNib() { super.awakeFromNib() }
}
