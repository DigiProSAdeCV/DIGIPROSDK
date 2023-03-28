//
//  UtilsF.swift
//  DGFmwrk
//
//  Created by Alejandro López Arroyo on 2/15/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import SystemConfiguration


public class UtilsF: UIViewController {
    
    public class func regexMatchesEmail(text: String) -> Bool {
        
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let validation = NSPredicate(format:"SELF MATCHES %@", regex)
        return validation.evaluate(with: text)
    }
    
    public class func regexMatchesName(text: String) -> Bool{
        let regex = "(([a-zA-Z\\s])*)"
        let validation = NSPredicate(format:"SELF MATCHES %@", regex)
        return validation.evaluate(with: text)
    }
    
    public class func regexMatchesNunmber(text: String) -> Bool{
        let regex = "\\d{2}?\\d{4}?\\d{4}"
        let validation = NSPredicate(format:"SELF MATCHES %@", regex)
        return validation.evaluate(with: text)
    }
    
    public class func regexMatchesPassword(text: String) -> Bool{
        let regex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        let validation = NSPredicate(format:"SELF MATCHES %@", regex)
        return validation.evaluate(with: text)
    }
    
    public class func regexMatchesCURP(text: String) -> Bool{
        let regex = "([A-Z][AEIOUX][A-Z]{2}\\d{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\\d|3[01])[HM](?:AS|B[CS]|C[CLMSH]|D[FG]|G[TR]|HG|JC|M[CNS]|N[ETL]|OC|PL|Q[TR]|S[PLR]|T[CSL]|VZ|YN|ZS)[B-DF-HJ-NP-TV-Z]{3}[A-Z\\d])(\\d)"
        let validation = NSPredicate(format:"SELF MATCHES %@", regex)
        return validation.evaluate(with: text)
    }
}

public extension UIViewController{
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() { view.endEditing(true) }
    func alert(message: String, title: String = "alrt_warning".langlocalized()) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "alrt_accept".langlocalized(), style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UIDevice {
    open var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

public extension UserDefaults
{
    func indexPath(forKey key: String) -> IndexPath?
    {   if let data = data(forKey: key), let indexPath = try? JSONDecoder().decode(IndexPath.self, from: data)
        {   return indexPath    }
        return nil
    }
}

public class InternetConnectionManager {


    private init() {

    }

    public static func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {

            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {

                SCNetworkReachabilityCreateWithAddress(nil, $0)

            }

        }) else {

            return false
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }

}

public extension WKWebView {
    class func clean() {
        guard #available(iOS 9.0, *) else {return}

        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                #if DEBUG
                    print("WKWebsiteDataStore record deleted:", record)
                #endif
            }
        }
    }
}
