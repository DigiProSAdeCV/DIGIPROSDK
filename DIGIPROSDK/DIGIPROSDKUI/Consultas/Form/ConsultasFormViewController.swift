import Foundation
import UIKit

import Eureka
public class ConsultasFormViewController: FormViewController, APIDelegate{
    
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    public func didSendError(message: String, error: enumErrorType) { }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
    
    @IBOutlet weak var containerView: UIView!
    
    public var reporte: FETipoReporte?
    var elements = [String: String]()
    var sdkAPI = APIManager<ConsultasFormViewController>()
    var device: Device?
    
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var backButton: UIButton!
    
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.titleLabel.text = "cnslvw_lbl_title_form".langlocalized()
        self.navigationController?.isToolbarHidden = true
        sdkAPI.delegate = self
        self.gettingFields()
        self.backButton.setImage(UIImage(named: "ic_back_blue", in: Cnstnt.Path.framework, compatibleWith: nil), for:.normal )
        
    }
   
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        ConfigurationManager.shared.consultaHackPage = 0
        ConfigurationManager.shared.consultaSum = 30
    }
 
    public func gettingFields(){
                
        if reporte?.Campos.count ?? 0 > 0{
            for campo in (reporte?.Campos)!{
                
                switch campo.TypeId{
                case "VarChar":
                    form +++ TextRow("\(campo.Nombre)"){ row in
                        }.cellSetup({ (cell, row) in
                            row.title = "\(campo.Nombre)"
                            row.placeholder = "\(campo.Mascara)"
                            cell.textField.autocapitalizationType = .allCharacters
                            cell.textField.autocorrectionType = .no
                        }).onChange({ (row) in
                        self.elements["\(campo.Nombre)"] = "\(row.value ?? "")"
                    })
                    break
                case "Int":
                    form +++ IntRow("\(campo.Nombre)"){ row in
                        row.title = "\(campo.Nombre)"
                        row.placeholder = "\(campo.Mascara)"
                        }.cellSetup({ (cell, row) in
                            cell.textField.autocapitalizationType = .allCharacters
                            cell.textField.autocorrectionType = .no
                        }).onChange({ (row) in
                        self.elements["\(campo.Nombre)"] = "\(row.value ?? 0)"
                    })
                    break
                case "Money":
                    form +++ DecimalRow("\(campo.Nombre)"){ row in
                        row.title = "\(campo.Nombre)"
                        row.placeholder = "\(campo.Mascara)"
                        }.cellSetup({ (cell, row) in
                            cell.textField.autocapitalizationType = .allCharacters
                            cell.textField.autocorrectionType = .no
                        }).onChange({ (row) in
                        self.elements["\(campo.Nombre)"] = "\(row.value ?? 0)"
                    })
                    break
                case "DynamicList":
                    form +++ SelectableSection<ListCheckRow<String>>("\(campo.Nombre)", selectionType: .singleSelection(enableDeselection: true))
                    for option in campo.Catalogo {
                        form.last! <<< ListCheckRow<String>(option.Descripcion){ listRow in
                            listRow.title = option.Descripcion
                            listRow.selectableValue = String(option.CatalogoId)
                            listRow.value = nil
                            }.onChange({ (row) in
                                self.elements["\(campo.Nombre)"] = "\(row.selectableValue ?? "")"
                            })
                    }
                    
                    break;
                default:
                    break
                }
                
            }
        }
        form +++ ButtonRow() {
            $0.title = "cnslvw_lbl_search".langlocalized()
        }.onCellSelection{ cell, row in
            for element in self.elements{
                for campo in (self.reporte?.Campos)!{
                    if element.key == campo.Nombre{
                        campo.Valor = element.value
                    }
                }
            }
            self.search()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            for row in self.form.allRows{
                row.baseCell.formViewController()?.navigationOptions = []
                row.baseCell.formViewController()?.navigationController?.isToolbarHidden = true
            }
        }
        
    }
    
    public func search(){
        for consul in reporte!.Campos{
            consul.Regla = ""
        }
        self.sdkAPI.consultaConsultasPromise(delegate: self, reporte: reporte!, consulta: nil)
            .then { response in

                for row in self.form.allRows{
                    row.baseValue = nil
                    row.updateCell()
                }
                ConfigurationManager.shared.consultaSum = response.RegistrosPorPagina
                ConfigurationManager.shared.consultaHackPage = response.TotalRegistros
                let resultVC = ResultadosConsultasViewController.init(nibName: "vPzyRGBqIKrYKZn", bundle: Cnstnt.Path.framework)
                resultVC.reporte = self.reporte!
                resultVC.consulta = response
                self.show(resultVC, sender: nil)
            }.catch { error in
                let alert = UIAlertController(title: "alrt_consult".langlocalized(), message: "alrt_consult_des".langlocalized(), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "alrt_cancel".langlocalized(), style: .default, handler: { action in
                    switch action.style{
                    case .default: break
                    case .cancel: break
                    case .destructive: break
                    @unknown default: break
                    }}))
                self.present(alert, animated: true, completion: nil)
            }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        changeIconBack()
    }
    
}


extension ConsultasFormViewController {
    
    func changeIconBack() {
        if ConfigurationManager.shared.isConsubanco {
            backButton.setImage(UIImage(named: "arrowLeft", in: Bundle(identifier: "com.consubanco.econsubanco"), compatibleWith: nil), for: .normal)
        }
    }
    
}
