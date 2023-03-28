//
//  NotificationsViewController.swift
//  DIGIPROSDKUI
//
//  Created by Jonathan Viloria M on 10/04/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation
import UIKit


extension NotificationsViewController: APIDelegate{
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) {}
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) {}
    public func sendStatusCodeMessage(message: String, error: enumErrorType) {}
    public func didSendError(message: String, error: enumErrorType) {}
    public func didSendResponse(message: String, error: enumErrorType) {}
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {}
}

public typealias v2CB = (_ infoToReturn :NSString) ->()

public class NotificationsViewController: UIViewController, UINavigationControllerDelegate
{
    public var completionBlock:v2CB?
    @IBOutlet var bannerImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet var backBtn: UIButton!
    
    let apiSDK = APIManager<NotificationsViewController>()
    let cellReuseIdentifier = "cell"
    
    var messages: [String] = [String]()
    var messagesJson: [FEMensajesPush] = [FEMensajesPush]()
    var arrayData : [String] = [String]()
    var indexVisual : IndexPath = IndexPath()
    var altoVisual : Double = -1.0
    
    //diseño
    public lazy var hud: JGProgressHUD = JGProgressHUD(style: .dark)
    public var proyecto : String = ""
    public var imgBaner : String = ""
    public var colorNew : UIColor = UIColor()
    public var colorCard : UIColor = UIColor()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = "ntfsvw_lbl_title".langlocalized()
        let arrowIcon = UIImage(named: "leftArrow", in: Cnstnt.Path.framework, compatibleWith: nil)
        let tintedImage = arrowIcon?.withRenderingMode(.alwaysTemplate)
        self.backBtn.setImage(tintedImage, for: .normal)
        self.backBtn.imageView!.contentMode = .scaleAspectFill
        
        switch proyecto
        {
            case "EConsubanco":
                self.bannerImg.image = UIImage(named: "bannerEConsubanco", in: Cnstnt.Path.framework, compatibleWith: nil)
                self.colorCard = Cnstnt.Color.pushEConsubanco
                self.colorNew = UIColor(red: 243/255, green: 176/255, blue: 89/255, alpha: 1.0)
                self.backBtn.tintColor = UIColor(red: 243/255, green: 176/255, blue: 89/255, alpha: 1.0)
            break
            case "JLLMyProperty":
                //self.bannerImg.image = UIImage(named: "bannerEConsubanco", in: Cnstnt.Path.framework, compatibleWith: nil)
                self.colorCard = UIColor(named: "whitelight", in: Cnstnt.Path.framework, compatibleWith: nil) ?? UIColor.white
                self.colorNew = UIColor(named: "red", in: Cnstnt.Path.framework, compatibleWith: nil) ?? UIColor.white
                self.backBtn.tintColor = UIColor(named: "red", in: Cnstnt.Path.framework, compatibleWith: nil) ?? UIColor.white
            break
            case "Consullave":
                self.bannerImg.image = UIImage(named: "bannerConsubanco", in: Cnstnt.Path.framework, compatibleWith: nil)
                self.colorCard = UIColor(named: "pushEConsubanco", in: Cnstnt.Path.framework, compatibleWith: nil) ?? UIColor.white
                self.colorNew = .red
                self.backBtn.tintColor = .white
            break
            case "Prologistik":
                //self.bannerImg.image = UIImage(named: "bannerEConsubanco", in: Cnstnt.Path.framework, compatibleWith: nil)
                self.colorCard = UIColor(named: "whitelight", in: Cnstnt.Path.framework, compatibleWith: nil) ?? UIColor.white
                self.colorNew = UIColor(red: 79/255, green: 173/255, blue: 229/255, alpha: 1.0)
                self.backBtn.tintColor = UIColor(named: "blue", in: Cnstnt.Path.framework, compatibleWith: nil) ?? UIColor.white
            break
            default:
                self.colorNew = .black
                self.colorCard = UIColor(named: "whitelight", in: Cnstnt.Path.framework, compatibleWith: nil) ?? UIColor.white
                self.backBtn.tintColor =  .white
            break
                
        }
        
        self.tableview.register(UINib(nibName: "NotificationsCellController", bundle: Cnstnt.Path.framework), forCellReuseIdentifier: cellReuseIdentifier)
        
        self.tableview.rowHeight = UITableView.automaticDimension
        self.tableview.delegate = self
        self.tableview.dataSource = self
        apiSDK.delegate = self
        self.navigationController?.isNavigationBarHidden = true
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        checkNotifications()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    func checkNotifications() {

        DispatchQueue.main.async {
            self.hud.show(in: self.view)
        }
            
        self.apiSDK.serviceNotifications(delegate: self)
            .then { response in
                self.messagesJson = response
                self.messages = []
                self.messagesJson.forEach{ self.messages.append($0.Mensaje) }
                self.obtainerData(mnsjPush: self.messagesJson)
                self.tableview.reloadData()
                self.hud.dismiss(animated: true)
            }.catch { error in
                let e = error as NSError
                if error.localizedDescription.contains("DIGIPROSDK.APIErrorResponse 31")
                {   print("Sin mensajes")
                } else {
                    print(e.localizedDescription)
                }
                self.hud.dismiss(animated: true)
            }
        
    }
    
    func updateNotifications( tipoOp : Int , idPush : [String]) {
        
        DispatchQueue.main.async {
            self.hud.show(in: self.view)
        }
        
        ConfigurationManager.shared.utilities.isConnectedToNetwork()
        .then { response in
            self.apiSDK.serviceNotifications(delegate: self, tipoOp: tipoOp, idPush: idPush)
            .then { response in
                self.messagesJson = response
                self.messages = []
                self.messagesJson.forEach{  self.messages.append($0.Mensaje)}
                self.obtainerData(mnsjPush: self.messagesJson)
                self.tableview.reloadData()
                self.hud.dismiss(animated: true)
            }.catch { error in
                if error.localizedDescription.contains("DIGIPROSDK.APIErrorResponse 31")
                {
                    print("Sin mensajes")
                } else
                {
                    print(error.localizedDescription)
                }
                self.hud.dismiss(animated: true)
            }
        }.catch { error in
            self.hud.dismiss(animated: true)
        }
        
    }
    
    func obtainerData (mnsjPush : [FEMensajesPush])
    {
        self.arrayData = [String]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = NSTimeZone.local
        var seccionesIDs: [String: [Int]] = [String: [Int]]()
        mnsjPush.forEach
        { msjPush in
            let fechaPush : String = String((msjPush.FechaCreacion.split(separator: "T")).first ?? "")
            let fechaOk : Date = dateFormatter.date(from: fechaPush) ?? Date()
            if Calendar.current.isDateInToday(fechaOk)
            {   var ids : [Int] = seccionesIDs["Hoy"] ?? []
                ids.append((mnsjPush.firstIndex(of: msjPush) ?? -1))
                seccionesIDs.updateValue(ids, forKey: "Hoy")
            } else if Calendar.current.isDateInYesterday(fechaOk) {
                var ids : [Int] = seccionesIDs["Ayer"] ?? []
                ids.append((mnsjPush.firstIndex(of: msjPush) ?? -1))
                seccionesIDs.updateValue(ids, forKey: "Ayer")
            } else {
                var ids : [Int] = seccionesIDs["Anteriores"] ?? []
                ids.append((mnsjPush.firstIndex(of: msjPush) ?? -1))
                seccionesIDs.updateValue(ids, forKey: "Anteriores")
            }
        }
        if seccionesIDs["Hoy"] != nil
        {   let ids = (seccionesIDs["Hoy"]).map(String.init) ?? ""
            arrayData.append("Hoy-\(ids)")
        }
        if seccionesIDs["Ayer"] != nil
        {   let ids = (seccionesIDs["Ayer"]).map(String.init) ?? ""
            arrayData.append("Ayer-\(ids)")
        }
        if seccionesIDs["Anteriores"] != nil
        {
            let array : [Int] = seccionesIDs["Anteriores"]?.reversed() ?? []
            seccionesIDs.updateValue(array, forKey: "Anteriores")
            let ids = (seccionesIDs["Anteriores"]).map(String.init) ?? ""
            arrayData.append("Anteriores-\(ids)")
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        guard let cb = completionBlock else { return }
        cb("regresa")
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if messagesJson.isEmpty {
            return 1
        }else {
            return arrayData.count
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y:0, width: tableView.frame.width, height: 50))
        view.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 20, y:5, width: tableView.frame.width - 20, height: 40))
        if messagesJson.isEmpty {
            label.text = ""
        }else {
            let titulo = String(self.arrayData[section].split(separator: "-").first ?? "")
            label.text = titulo
            label.font = UIFont(name: "Helvetica-bold", size: 16)
        }
        view.addSubview(label)
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if messagesJson.isEmpty {
            return 100
        } else{
            if indexVisual == indexPath && self.altoVisual != -1.0 {
                return CGFloat(self.altoVisual)
            } else {
                return 125
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messagesJson.isEmpty {
            return messages.count
        }else {
            let idsString = (String(arrayData[section].split(separator: "-").last ?? "").replacingOccurrences(of: "[", with: "")).replacingOccurrences(of: "]", with: "")
            return (idsString.components(separatedBy: ",")).count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messagesJson.isEmpty
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
            cell?.textLabel?.text = messages[indexPath.row]
            cell?.textLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
            cell?.textLabel?.textColor = UIColor(hexFromString: "#202020", alpha: 1)
            return cell!
        } else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! NotificationsCellController
            
            if self.indexVisual == indexPath
            {   cell.titleTemplate.numberOfLines = 0
                cell.descriptionTemplate.numberOfLines = 0
            } else {
                cell.titleTemplate.numberOfLines = 1
                cell.descriptionTemplate.numberOfLines = 1
            }
            
            let stringIDs = String(self.arrayData[indexPath.section].split(separator: "-").last ?? "")
            let item = (stringIDs.dropFirst()).dropLast()
            let aux = String(item.split(separator: ",")[indexPath.row])
            let idItem = (aux as NSString).integerValue
            let msjfull = (self.messagesJson[idItem].Mensaje).split(separator: "-")
            if msjfull.count == 3
            {
                cell.titleTemplate.text = String(msjfull[0])
                cell.descriptionTemplate.text = String(msjfull[1])
                cell.txtMoreInfo.text = String(msjfull[2])
            } else if msjfull.count == 2
            {
                cell.titleTemplate.text = String(msjfull[0])
                cell.descriptionTemplate.text = ""
                cell.txtMoreInfo.text = String(msjfull[1])
            } else if msjfull.count == 1
            {
                cell.titleTemplate.text = String(msjfull[0])
                cell.descriptionTemplate.text = ""
                cell.txtMoreInfo.text = String(msjfull[0])
            }
            
            cell.cardView.layer.borderColor = UIColor.black.cgColor
            cell.cardView.layer.borderWidth = 0.1
            cell.cardView.layer.cornerRadius = 10.0
            cell.cardView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
            cell.cardView.layer.shadowColor = self.colorCard.cgColor
            cell.cardView.layer.shadowOpacity = 0.45
            cell.cardView.layer.shadowRadius = 6
            
            cell.newPushBtn.backgroundColor = self.colorNew
            cell.newPushBtn.layer.cornerRadius = cell.newPushBtn.frame.height / 2
            cell.newPushBtn.isHidden = self.messagesJson[idItem].Visto ? true : false
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = NSTimeZone.local
            dateFormatter.locale = Locale(identifier: "es_MX")
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let fechaPush : String = String((self.messagesJson[idItem].FechaCreacion.split(separator: "T")).first ?? "")
            let fechaOk : Date = dateFormatter.date(from: fechaPush) ?? Date()
            dateFormatter.dateFormat = "d MMM"
            let fecha = dateFormatter.string(from: fechaOk)
            var horaPush : String = String((self.messagesJson[idItem].FechaCreacion.split(separator: "T")).last ?? "")
            horaPush = String(String(horaPush.split(separator: ".").first ?? "").dropLast(3))
            cell.fechaLbl.text = "\(fecha) a las \(horaPush)"
             
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let stringIDs = String(self.arrayData[indexPath.section].split(separator: "-").last ?? "")
        let item = (stringIDs.dropFirst()).dropLast()
        let aux = String(item.split(separator: ",")[indexPath.row])
        let idItem = (aux as NSString).integerValue
        let notification : FEMensajesPush = self.messagesJson[idItem]
        if !notification.Visto
        {   self.determinaTam(indexPath: indexPath, tableView: tableView)
            self.updateNotifications(tipoOp: 2, idPush: [self.messagesJson[idItem].ID])
        }else
        {   if self.altoVisual == -1.0 && self.indexVisual == IndexPath()
            {   self.determinaTam(indexPath: indexPath, tableView: tableView)
                self.tableview.reloadData()
            } else
            {   self.altoVisual = -1.0
                self.indexVisual = IndexPath()
                self.tableview.reloadData()
            }
        }
    }
    
    func determinaTam (indexPath: IndexPath, tableView: UITableView)
    {
        self.indexVisual = indexPath
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! NotificationsCellController
        let tit : UILabel = cell.titleTemplate
        tit.numberOfLines = 0
        tit.sizeToFit()
        let subtit : UILabel = cell.descriptionTemplate
        subtit.numberOfLines = 0
        subtit.sizeToFit()
        self.altoVisual = Double(tit.frame.height + subtit.frame.height + 35)
        if cell.txtMoreInfo.text != ""
        {   self.altoVisual = Double(tit.frame.height + subtit.frame.height + 150.0) }
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "")
        { (action, sourceView, nil) in
            let stringIDs = String(self.arrayData[indexPath.section].split(separator: "-").last ?? "")
            let item = (stringIDs.dropFirst()).dropLast()
            let aux = String(item.split(separator: ",")[indexPath.row])
            let idItem = (aux as NSString).integerValue
            let notification : FEMensajesPush = self.messagesJson[idItem]
            //print("index path of delete: \(notification.ID)")
            let alertController = UIAlertController(title: "alrt_warning".langlocalized(), message: "alrt_delete_push".langlocalized(), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "alrt_accept".langlocalized(), style: .default) {
                UIAlertAction in
                self.updateNotifications(tipoOp: 3, idPush: [self.messagesJson[idItem].ID])
            }
            
            let cancelAction = UIAlertAction(title: "alrt_cancel".langlocalized(), style: .destructive) { UIAlertAction in }
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        delete.backgroundColor = self.colorNew == .black ? .red : self.colorNew
        delete.image = UIImage(named: "icon-deletePush", in: Cnstnt.Path.framework, compatibleWith: nil)
        let swipeAction = UISwipeActionsConfiguration(actions: [delete])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
}
