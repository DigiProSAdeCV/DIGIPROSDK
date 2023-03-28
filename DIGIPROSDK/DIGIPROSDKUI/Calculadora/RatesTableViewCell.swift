//
//  RatesTableViewCell.swift
//  DIGIPROSDKUI
//
//  Created by Alejandro López Arroyo on 19/03/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import UIKit


protocol CollectionViewCellDelegate: class {
    func collectionView(collectionviewcell: RatesCollectionViewCell?, index: Int, didTappedInTableViewCell: RatesTableViewCell, tableIndex: Int)
}

class RatesTableViewCell: UITableViewCell {
    weak var cellDelegate: CollectionViewCellDelegate?
    var rowWithData: [FECotizaciones]?
    var indexFromTable = -1
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var labelDiscount: UILabel!
    @IBOutlet weak var labelRates: UILabel!
    @IBOutlet weak var labelCat: UILabel!
    @IBOutlet weak var labelMonth: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet var collectionViewTable: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionViewTable.showsHorizontalScrollIndicator = false
        self.collectionViewTable.dataSource = self
        self.collectionViewTable.delegate = self
        let cellNib = UINib(nibName: "RatesCollectionViewCell", bundle: Cnstnt.Path.framework)
        self.collectionViewTable.register(cellNib, forCellWithReuseIdentifier: "collectionviewcellid")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
extension RatesTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func updateCellWith(row: [FECotizaciones], index: Int) {
        self.rowWithData = row
        self.collectionViewTable.reloadData()
        self.indexFromTable = index
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? RatesCollectionViewCell
        self.cellDelegate?.collectionView(collectionviewcell: cell, index: indexPath.item, didTappedInTableViewCell: self, tableIndex: self.indexFromTable)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rowWithData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionviewcellid", for: indexPath) as? RatesCollectionViewCell {
            var frequency: String = ""
            switch self.rowWithData?[indexPath.item].frequencyDescription ?? "" {
            case "Mensual":
                frequency = "Meses"; break
            case "Quincenal":
                frequency = "Quincenas"; break
            case "Catorcenal":
                frequency = "Catorcenas"; break
            case "Semanal":
                frequency = "Semanas"
            default:
                break
            }
            //
            cell.labelAmount.text = "\(self.rowWithData?[indexPath.item].requestedAmount ?? 0.0)".convertDoubleToCurrency()
            //cell.labelDiscount.text = "$\(String(format: "%.2f", self.rowWithData?[indexPath.item].discountAmount ?? 0.0))"
            cell.labelDiscount.text = "\(self.rowWithData?[indexPath.item].discountAmount ?? 0.0)".convertDoubleToCurrency()
            cell.labelCat.text = "\(String(format: "%.2f", self.rowWithData?[indexPath.item].cat ?? 0.0))%"
            cell.labelTitle.text = "\(self.rowWithData?[indexPath.item].plazo ?? 0) \(frequency)"
            cell.labelTotal.text = "\(self.rowWithData?[indexPath.item].totalAmount ?? 0.0)".convertDoubleToCurrency()
            let descXmil = String(format: "%.2f", self.formulaDesc(descuento: self.rowWithData?[indexPath.item].discountAmount ?? 0.0, monto: self.rowWithData?[indexPath.item].requestedAmount ?? 0.0))
            cell.labelDescT.text = "\(self.rowWithData?[indexPath.item].descx ?? 0.0)".convertDoubleToCurrency()
            cell.labelDescT.text = "$\(descXmil)"//"\(self.formulaDesc(descuento: self.rowWithData?[indexPath.item].discountAmount ?? 0.0, monto: self.rowWithData?[indexPath.item].requestedAmount ?? 0.0))".convertDoubleToCurrency()
            self.rowWithData?[indexPath.item].descx  = self.formulaDesc(descuento: self.rowWithData?[indexPath.item].discountAmount ?? 0.0, monto: self.rowWithData?[indexPath.item].requestedAmount ?? 0.0)
            let interestDecimal = String(format: "%.2f", self.rowWithData?[indexPath.item].tasamensual ?? 0.0)
            cell.labelRates.text = "\(interestDecimal)%"

            return cell
        }
        return UICollectionViewCell()
    }
    func formulaDesc(descuento: Double?, monto: Double?) -> Double{
        let desc = descuento ?? 1.0
        let amount = monto ?? 1.0
        let resultado = (desc / amount) * 1000
        return resultado
    }
    
    func formulaInteres(interes: Double?) -> Double{
        let res = interes! * 100.0
        //let rounded = round(100 * res) / 100
        return res.roundToDecimal(2)
    }
    
}
