//
//  NetPayInfoViewController.swift
//  DIGIPROSDKNTP
//
//  Created by Alberto Echeverri Carrillo on 28/04/21.
//

import UIKit

public protocol NetPayInfoViewControllerDelegate {
    func checkoutTransaction(netpayResponse: NetPayResponse?)
}

public class NetPayInfoViewController: UIViewController/*, CreditCardFormViewControllerDelegate*/ {
    
    //IBOutlets:
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var nombreLbl: UILabel!
    @IBOutlet weak var correoLbl: UILabel!
    @IBOutlet weak var telefonoLbl: UILabel!
    @IBOutlet weak var direccionLbl: UILabel!
    @IBOutlet weak var montoLbl: UILabel!
    @IBOutlet weak var folioLbl: UILabel!
    
    //Properties:
    private var cornerRadius: CGFloat = 16.0
    
    //PRODUCCION
    //Nueva public api key: pk_netpay_imEgtIcKQAcMGEQhkgEQmmRZr
    //Private api key: sk_netpay_hsLohgkjxrRYXlKXiDhDFbXCljpRxQZmBQflIvlHDIzVP
    
    //SANDBOX
    //publica: pk_netpay_MjprUDidKUDpkWEYXSdJwgxul
    //privada: sk_netpay_LdYRLUDBEciOBVlngtccrecsyMfWHngpnmwIuLsppSElg
    
    private let publicKey: String = "pk_netpay_MjprUDidKUDpkWEYXSdJwgxul"
    private let privateKey: String = "sk_netpay_LdYRLUDBEciOBVlngtccrecsyMfWHngpnmwIuLsppSElg"
    
    private var request: NetPayRequest?
    
    private let bundlePath = Bundle(identifier: "com.digipro.movil.DIGIPROSDKNTP")
    
    //private var capability: NetPaySDK.Capability?
    
    public var delegate: NetPayInfoViewControllerDelegate?
    
    private var userInfo = [NetPayComponent]()

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.alert(message: "El componente se encuentra inhabilitado", title: "Error de NetPay")
//        let client = Client(publicKey: publicKey, testMode: true)
//        client.capabilityDataWithCompletionHandler { (result) in
//            if case .success(let capability) = result {
//                self.capability = capability
//            } else {
//                print("Error de cliente:")
//            }
//        }
    }
    
    
    /// Configura la vista para desplegar los valores obtenidos para el pago de NetPay
    /// - Parameters:
    ///   - dicitonary: diccionario de tipo `NSMutableDictioanry` que contiene la informacion necesaria para generar una transaccion de NetPay
    ///   - completion: completion handler para indicar que la vista a sido configurada
    public func configure(with componentes: [NetPayComponent], completion: @escaping () ->()) {
        
        self.userInfo = componentes
        
        var array: [(title: String, description: String)] = [(title:"", description: ""),(title:"", description: ""),(title:"", description: ""),(title:"", description: ""),(title:"", description: ""),(title:"", description: "")]
        
        var nombreCompleto: String = ""
        
        var direccion: [String:String] = [String:String]()
        for c in componentes {
            switch c.orden {
            case "order_1":
                array.insert((title:"Monto", description: c.valor),at: 4)
                break
//                case "order_2": //Descripcion de Cargo //No Aplica.
//                    break
            case "order_3": //Nombre
                nombreCompleto.append(c.valor)
                break
            case "order_4": //Apellido(s)
                nombreCompleto.append(" \(c.valor)")
                break
            case "order_5": //Correo
                array.insert((title:"Correo", description: c.valor),at: 1)
                break
            case "order_6": //Telefono
                array.insert((title:"Telefono", description: c.valor),at: 2)
                break
            case "order_7": //Ciudad
                direccion["Ciudad"] = c.valor
                break
            case "order_8": //Codigo Postal
                direccion["CP"] = c.valor
                break
            case "order_9": //Estado
                direccion["Estado"] = c.valor
                break
            case "order_10": //Calle
                direccion["Calle"] = c.valor
                break
            case "order_11": //Folio
                if c.valor.isEmpty || c.valor == "" {
                    let number = Int.random(in: 0...100000)
                    array.insert((title:"Folio", description: "\(number)"),at: 5)
                } else {
                    array.insert((title:"Folio", description: c.valor),at: 5)
                }
                break
            default:
                break
            }
        }
        
        
        array.insert((title:"Nombre", description: nombreCompleto),at: 0)
        
        var direccionString: String = ""
        
        direccionString.append("\(direccion["Calle"] ?? "") \n")
        direccionString.append("CP \(direccion["CP"] ?? "") \n")
        direccionString.append("\(direccion["Ciudad"] ?? "") \n")
        direccionString.append("\(direccion["Estado"] ?? "")")
        
        array.insert((title:"Direccion", description: direccionString),at: 3)
        
        for elemento in array {
            switch elemento.title {
            case "Nombre":
                nombreLbl.text = elemento.description
                break;
            case "Correo":
                correoLbl.text = elemento.description
            case "Telefono":
                telefonoLbl.text = elemento.description
                break
            case "Direccion":
                direccionLbl.text = elemento.description
                break
            case "Monto":
                montoLbl.text = "$\(elemento.description)"
                break
            case "Folio":
                folioLbl.text = elemento.description
                break
            default:
                break
            }
        }
        completion()
    }
    
    private func createRequest(token: String) -> NetPayRequest{
        //Sacar la informacion del diccionario:
        var request: NetPayRequest = NetPayRequest(
            description: "Cargo de prueba",
            source: token,
            paymentMethod: "card",
            amount: 300,
            currency: "MXN",
            billing: NetPayBilling(
                firstName: "John",
                lastName: "Doe",
                email: "accept@netpay.com.mx",
                phone: "1234567890",
                address: NetPayBillingAddress(
                    city: "Panuco",
                    country: "MX",
                    postalCode: "93994",
                    state: "Veracruz",
                    street1: "Calle",
                    street2: "Centro"),
                merchantReferenceCode: "14500056"
            ),
            ship: NetPayShipping(
                city: "Monterrey",
                country: "MX",
                firstName: "Jill",
                lastName: "Doe",
                phoneNumber: "0987654321",
                postalCode: "66478",
                state: "Nuevo Leon",
                street1: "direccion",
                street2: "colonia",
                shippingMethod: "flatrate_flatrate"
            ),
            redirect3dsUri: "https://netpay.mx"
        )
        
        //Si no llenas todos los parametros, se vacia estos valores
        self.userInfo.forEach({
            switch $0.orden {
            case "order_1": //Monto
                request.amount = Double($0.valor) ?? 0.0
                break
            case "order_2": //Descripcion de Cargo //No Aplica.
                request.description = $0.valor
                break
            case "order_3": //Nombre
                request.ship.firstName = $0.valor
                request.billing.firstName = $0.valor
                break
            case "order_4": //Apellido(s)
                request.ship.lastName = $0.valor
                request.billing.lastName = $0.valor
                break
            case "order_5": //Correo
                request.billing.email = $0.valor
                break
            case "order_6": //Telefono
                request.billing.phone = $0.valor
                request.ship.phoneNumber = $0.valor
                break
            case "order_7": //Ciudad
                request.ship.city = $0.valor
                request.billing.address?.city = $0.valor
                break
            case "order_8": //Codigo Postal
                request.ship.postalCode = $0.valor
                request.billing.address?.postalCode = $0.valor
                break
            case "order_9": //Estado
                request.ship.state = $0.valor
                request.billing.address?.state = $0.valor
                break
            case "order_10": //Calle
                request.ship.street1 = $0.valor
                request.billing.address?.street1 = $0.valor
            case "order_11": //Folio
                request.billing.merchantReferenceCode = $0.valor
                break
            default:
                break
            }
        })
        
        return request
    }

    @IBAction func didTapAccept(_ sender: UIButton) {
        self.alert(message: "El componente se encuentra inhabilitado, tarjeta de crédito no disponible.", title: "Error de NetPay")
//        let creditCardFormController = CreditCardFormViewController.makeCreditCardFormViewController(withPublicKey: publicKey, testMode: true)
//        creditCardFormController.handleErrors = false
//        //creditCardFormController.delegate = self
//        self.show(creditCardFormController, sender: self)
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func checkout(token:String, netPayRequest: NetPayRequest, completion: @escaping (NetPayResponse?, Error?) -> ()) {
        let urlPath: String = "https://gateway-154.netpaydev.com/gateway-ecommerce/v3/charges"
        if let url = URL(string: urlPath) {
            var networkRequest: URLRequest = URLRequest(url: url)
            networkRequest.timeoutInterval = TimeInterval(60)
            networkRequest.httpMethod = "POST"
            networkRequest.addValue(privateKey, forHTTPHeaderField: "Authorization")
            networkRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let data = try JSONEncoder().encode(netPayRequest)
                networkRequest.httpBody = data
                URLSession.shared.dataTask(with: networkRequest) { (data, response, error) in
                    if let _ = error {
                        completion(nil, error)
                    } else {
                        if let responseData = data {
                            let netPayResponse: NetPayResponse? = try? JSONDecoder().decode(NetPayResponse.self, from: responseData)
                            
                            if let error = netPayResponse?.error {
                                print(error)
                                completion(nil, nil)
                            } else {
                                completion(netPayResponse, nil)
                            }
                        }
                    }
                }.resume()
            } catch {
                completion(nil, error)
            }
        }
    }
    
    private func validatePurchase(transactionTokenId: String, completion: @escaping () -> ()) {
        let urlPath: String = "https://gateway-154.netpaydev.com/gateway-ecommerce/v3/transactions/\(transactionTokenId)"
        if let url = URL(string: urlPath) {
            var networkRequest: URLRequest = URLRequest(url: url)
            networkRequest.timeoutInterval = TimeInterval(60)
            networkRequest.httpMethod = "GET"
            networkRequest.addValue(privateKey, forHTTPHeaderField: "Authorization")
            networkRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: networkRequest) { (data, reponse, error) in
                if let _ = error {
                    print("Error al validar compra")
                } else {
                    if let _ = data {
                        completion()
                    }
                }
            }.resume()
        }
    }

}
