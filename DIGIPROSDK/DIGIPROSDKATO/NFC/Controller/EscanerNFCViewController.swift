import Foundation
import UIKit
#if targetEnvironment(simulator)

#else
    #if canImport(CoreNFC)
    import CoreNFC
    #endif
#endif
import Eureka

class EscanerNFCViewController: UIViewController, UINavigationControllerDelegate, TypedRowControllerType
{
    public var row: RowOf<String>!
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    
    @IBOutlet weak var textViewValidation: UITextView!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    var reset: Bool = false
    
    var resultsText = ""
    var atributos: Atributos_escanerNFC?
    var flagCode: Bool = true
    @IBOutlet weak var viewButtons: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    fileprivate var timer:Timer!
    #if targetEnvironment(simulator)

    #else
        #if canImport(CoreNFC)
        var nfcNDEFSession: NFCNDEFReaderSession?
        var nfcSession: NFCReaderSession?
        #endif
    #endif
    
    
    @IBOutlet weak var btnCerrar: UIButton!
    @IBAction func cerrarAction(_ sender: Any) {
        self.flagCode = true
        self.viewButtons.isHidden = true
        self.blurView.isHidden = true
        reset = true
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        onDismissCallback?(self)
    }
    
    @IBAction func guardarAction(_ sender: Any) {
        self.flagCode = true
        self.viewButtons.isHidden = true
        self.blurView.isHidden = true
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        onDismissCallback?(self)
    }
    
    @IBAction func reiniciarAction(_ sender: Any)
    {
        #if targetEnvironment(simulator)

        #else
            #if canImport(CoreNFC)
            if #available(iOS 13.0, *)
            {
                //var nfcTAGsession: NFCTagReaderSession?
                //var nfcVASsession: NFCVASReaderSession?

                /*guard NFCTagReaderSession.readingAvailable else { return }
                nfcTAGsession = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693, .iso18092], delegate: self, queue: DispatchQueue.main)
                nfcTAGsession?.alertMessage = "Hold your iPhone near the item to learn more about it...."
                nfcTAGsession?.begin()

                guard NFCReaderSession.readingAvailable else { return }*/
            }
            guard NFCNDEFReaderSession.readingAvailable else
            {
                let alertController = UIAlertController(
                    title: "alrt_warning".langlocalized(),
                    message: "alrt_nfc".langlocalized(),
                    preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "alrt_ok".langlocalized(), style: .default,handler:
                { action in
                    self.textViewValidation.text = ""
                    self.cerrarAction(Any.self)
                }))
                self.present(alertController, animated: true, completion: nil)
                return
            }

            nfcNDEFSession = NFCNDEFReaderSession(delegate: self, queue: .main, invalidateAfterFirstRead: false)
            nfcNDEFSession?.alertMessage = "alrt_nfc_reader".langlocalized()
            nfcNDEFSession?.begin()

            self.flagCode = false
            self.viewButtons.isHidden = true
            self.blurView.isHidden = true
            textViewValidation.text = ""
            #endif
        #endif
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reiniciarAction(Any.self)
        textViewValidation.layer.cornerRadius = 10.0
        
        //#Btn Fondo/Redondo
        self.btnCerrar.backgroundColor = UIColor.red
        self.btnCerrar.layer.cornerRadius = self.btnCerrar.frame.height / 2
        self.btnCerrar.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        self.btnOk.setImage( UIImage(named: "check_full", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        self.btnDelete.setImage(UIImage(named: "deleteAtt", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if self.flagCode{
            self.viewButtons.isHidden = false
            self.blurView.isHidden = false
        }else{
            self.viewButtons.isHidden = true
            self.blurView.isHidden = true
        }
        
        if reset{
            reset = false
            reiniciarAction(Any.self)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    #if targetEnvironment(simulator)

    #else
      // your real device code
        #if canImport(CoreNFC)
        @available(iOS 13.0, *)
        private func readTag(_ session: NFCNDEFReaderSession, tag: NFCNDEFTag) {
            tag.readNDEF { (message, error) in
                guard error == nil else {
                    session.invalidate()
                    return
                }

                guard let record = message?.records.first else {
                    session.invalidate()
                    return
                }

                let firstChar = String(data: record.payload, encoding: .utf8)?.first
                let payload: String

                if firstChar == "\u{02}" {
                    payload = "\(String(data: record.payload, encoding: .utf8)?.dropFirst(3) ?? "<UNK>")"
                }
                else {
                    payload = "\(String(data: record.payload, encoding: .utf8)?.dropFirst(1) ?? "<UNK>")"
                }

                self.textViewValidation.text = payload
                session.alertMessage = payload
                session.invalidate()
            }
        }
        #endif
    #endif
    
}
#if targetEnvironment(simulator)

#else
extension EscanerNFCViewController: NFCNDEFReaderSessionDelegate, NFCTagReaderSessionDelegate
{

    #if canImport(CoreNFC)
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage])
    {
        if #available(iOS 13.0, *)  {} else
        {
            var result = ""
            for payload in messages[0].records {
                result += String.init(data: payload.payload.advanced(by: 3), encoding: .utf8)!
            }

            self.textViewValidation.text = result
            self.viewButtons.isHidden = false
            self.blurView.isHidden = false
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error)
    {
        if #available(iOS 13.0, *)  {} else
        {
            if error is NFCReaderError
            {
                let alertController = UIAlertController(
                    title: "alrt_warning".langlocalized(),
                    message: error.localizedDescription,
                    preferredStyle: .alert )
                alertController.addAction(UIAlertAction(title: "alrt_ok".langlocalized(), style: .default, handler: { action in
                    if self.textViewValidation.text == ""
                    {
                        self.cerrarAction(Any.self)
                    }
                } ))
                //self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) { }


    @available(iOS 13.0, *)
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) { }
    @available(iOS 13.0, *)
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if let _ = error as? NFCReaderError
        {
            let alertController = UIAlertController(
                title: "alrt_warning".langlocalized(),
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "alrt_ok".langlocalized(), style: .default, handler: nil))
        }
    }
    @available(iOS 13.0, *)
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        let tag = tags.first!
        session.connect(to: tag) { (error: Error?) in
            if nil != error {
                session.invalidate(errorMessage: "alrt_error_try".langlocalized())
                return
            }
            if case let NFCTag.feliCa(felicaTag) = tag
            {
                let idm = felicaTag.currentIDm.map { String(format: "%.2hhx", $0) }.joined()
                let systemCode = felicaTag.currentSystemCode.map { String(format: "%.2hhx", $0) }.joined()
                self.textViewValidation.text = "IDm: \(idm) \nSystem Code: \(systemCode)"
                self.viewButtons.isHidden = false
                self.blurView.isHidden = false
            }

            if case let .miFare(mifareTag) = tag
            {
                let apdu = NFCISO7816APDU(instructionClass: 0, instructionCode: 0xB0, p1Parameter: 0, p2Parameter: 0, data: Data(), expectedResponseLength: 16)
                mifareTag.sendMiFareISO7816Command(apdu) { (apduData, sw1, sw2, error) in
                    let tagUIDData = mifareTag.identifier
                    var byteData: [UInt8] = []
                    tagUIDData.withUnsafeBytes { byteData.append(contentsOf: $0) }
                    var uidString = ""
                    for byte in byteData {
                        let decimalNumber = String(byte, radix: 16)
                        if (Int(decimalNumber) ?? 0) < 10 { // add leading zero
                            uidString.append("0\(decimalNumber)")
                        } else {
                            uidString.append(decimalNumber)
                        }
                    }
                    if uidString.count > 0
                    {
                        self.textViewValidation.text = "Tag UID: \(uidString)"
                        self.viewButtons.isHidden = false
                        self.blurView.isHidden = false
                    }
                }
            }
        }
    }



    @available(iOS 13.0, *)
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }

        session.connect(to: tag)
        { (error) in
            guard error == nil else {
                session.invalidate()
                return
            }
            self.readTag(session, tag: tag)
        }
    }
    #endif

}
#endif
