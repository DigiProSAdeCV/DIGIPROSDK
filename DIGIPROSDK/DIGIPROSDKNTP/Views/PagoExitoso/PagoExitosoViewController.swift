//
//  PagoExitosoViewController.swift
//  DIGIPROSDKNTP
//
//  Created by Alberto Echeverri Carrillo on 28/04/21.
//

import UIKit
import PDFKit

public class PagoExitosoViewController: UIViewController {
    
    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var fechaLbl: UILabel!
    @IBOutlet weak var transaccionLbl: UILabel!
    @IBOutlet weak var montoLbl: UILabel!
    @IBOutlet weak var folioLbl: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        let checkMark = UIImage(named: "check_full", in: Cnstnt.Path.framework, compatibleWith: nil)
        self.checkMarkImageView.image = checkMark
    }
    
    public func configuraRecibo(recibo: NetPayResponse, completion: @escaping () -> ()) {
        fechaLbl.text =
            self.getFormattedDate(date: recibo.createdAt ?? "")
        transaccionLbl.text = recibo.transactionTokenId
        montoLbl.text = "$\(recibo.amount ?? 0)"
        folioLbl.text = recibo.description
        completion()
    }
    
    private func getFormattedDate(date: String) -> String {
        //13 de Mayo de 2021 a las 12:56:12
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"
        dateFormatter.locale = Locale(identifier: "es_MX") //La localidad es importante.
        if let date = dateFormatter.date(from: date) {
            print(date)
            let calendarComponents = Calendar.current.dateComponents([.day,.year,.month,.hour,.minute, .second], from: date)
            let month = dateFormatter.monthSymbols[calendarComponents.month! - 1]
            let dateString = "\(calendarComponents.day ?? 0) de \(month) de \(calendarComponents.year ?? 0000) a las \(calendarComponents.hour ?? 0):\(calendarComponents.minute ?? 0):\(calendarComponents.second ?? 0)"
            return dateString
        } else {
            return ""
        }
    }
    
    @IBAction func didTapCancelar(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
