import Foundation

import UserNotifications

extension DataViewController: SpreadsheetViewDelegate, SpreadsheetViewDataSource{

    
    // Permission to create a new Format
    public func detectPermissionNewFormat(){
        if ConfigurationManager.shared.usuarioUIAppDelegate.PermisoNuevoFormato{
            nuevoFEBtn.isEnabled = true
        }else{
            let userDefaults_serial = String(self.defaults.string(forKey: Cnstnt.BundlePrf.serial) ?? "")
            if userDefaults_serial.sha512() == "07eeb356a2b2297563b4e7cb245387b19b341afd31e58d0bed678449062aa462fd28d78732c62ffeeb73ccbbf45c077d271f4a8f10803dab48597f477e76eaf2"{
                nuevoFEBtn.isEnabled = true
            }else{
                nuevoFEBtn.isEnabled = false
            }
        }
    }
    // Permission to visualize Map
    public func detectPermissionVisualizeMap(){
//        if ConfigurationManager.shared.usuarioUIAppDelegate.PermisoVerMapa{
//            localizacionBtn.isHidden = false
//        }else{
//            localizacionBtn.isHidden = true
//        }
    }
    // Permission to See the Tutorial
    public func permissionToSeeTutorial(_ isPermitted: Bool = true){
        if !isPermitted{ DispatchQueue.main.async{ self.getAllData() }; return; }
        let tutorialBool = plist.tutorial.rawValue.dataB()
        if tutorialBool{
            plist.tutorial.rawValue.dataSSet(false)
            self.settingTutorialView()
            DispatchQueue.main.async{ self.getAllData() }
        }else{
            DispatchQueue.main.async{ self.getAllData() }
        }
    }
    
    // Detect if there is new content
    public func detectIfHasNewFormat(){
        if ConfigurationManager.shared.hasNewFormat {
            self.reloadFormatsAndPlantillas()
            ConfigurationManager.shared.hasNewFormat = false
        }
    }
    
    // Constraints
    public func settingContraints(){
        if device == .iPhone11Pro || device == .iPhone11 || device == .iPhone11ProMax || device == .iPhoneX || device == .iPhoneXS || device == .iPhoneXR || device == .iPhoneXSMax || device.description == "Simulator (iPhone 11)" || device.description == "Simulator (iPhone 11 Pro)" || device.description == "Simulator (iPhone 11 Pro Max)" || self.device.description == "Simulator (iPhone X)"{
            
            for constraint in self.view.constraints {
                if constraint.identifier == "vwLoaderBottom" {
                    constraint.constant = -140
                    
                }
            }
            for constraint in self.view.constraints {
                if constraint.identifier == "tableViewTop" {
                    constraint.constant = 100
                }
            }
            
        }else{
            
            for constraint in self.view.constraints {
                if constraint.identifier == "vwLoaderBottom" {
                    constraint.constant = -50
                }
            }
            for constraint in self.view.constraints {
                if constraint.identifier == "tableViewTop" {
                    constraint.constant = 80
                }
            }
        }
    }
    public func setLoaderBottomAnimation(_ isVisible: Bool = false){
        if isVisible{
            if device == .iPhone11Pro || device == .iPhone11 || device == .iPhone11ProMax || device == .iPhoneX || device == .iPhoneXS || device == .iPhoneXR || device == .iPhoneXSMax || device.description == "Simulator (iPhone 11)" || device.description == "Simulator (iPhone 11 Pro)" || device.description == "Simulator (iPhone 11 Pro Max)" || self.device.description == "Simulator (iPhone X)"{
                for constraint in self.view.constraints {
                    if constraint.identifier == "vwLoaderBottom" {
                        constraint.constant = 16
                    }
                }
            }else{
                for constraint in self.view.constraints {
                    if constraint.identifier == "vwLoaderBottom" {
                        constraint.constant = 14
                    }
                }
            }
            
        }else{
          
            if device == .iPhone11Pro || device == .iPhone11 || device == .iPhone11ProMax || device == .iPhoneX || device == .iPhoneXS || device == .iPhoneXR || device == .iPhoneXSMax || device.description == "Simulator (iPhone 11)" || device.description == "Simulator (iPhone 11 Pro)" || device.description == "Simulator (iPhone 11 Pro Max)" || self.device.description == "Simulator (iPhone X)"{
                for constraint in self.view.constraints {
                    if constraint.identifier == "vwLoaderBottom" {
                        constraint.constant = -140
                    }
                }
            }else{
                for constraint in self.view.constraints {
                    if constraint.identifier == "vwLoaderBottom" {
                        constraint.constant = -50
                    }
                }
            }
        }
    }
    
    // Notifications
    func getNotification(){
        self.sdkAPI?.getNotification(delegate: self)
            .then { response in
                if response != 0{
                    if UIApplication.shared.applicationIconBadgeNumber > 0{
                        UIApplication.shared.applicationIconBadgeNumber = response
                        ConfigurationManager.shared.mainTab?.tabBar.items?[0].badgeValue = String(response)
                    }else{
                        self.sendNotification(title: "lclnot_title".langlocalized(), subtitle: "lclnot_subtitle".langlocalized(), body: "lclnot_message".langlocalized(), badge: NSNumber(value:response))
                        ConfigurationManager.shared.mainTab?.tabBar.items?[0].badgeValue = String(response)
                    }
                }else{
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    ConfigurationManager.shared.mainTab?.tabBar.items?[0].badgeValue = nil
                }
            } .catch { _ in }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    public func sendNotification(title: String, subtitle: String, body: String, badge: NSNumber) {
        //get the notification center
        let center =  UNUserNotificationCenter.current()
        //create the content for the notification
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = badge
        content.sound = UNNotificationSound.default
        //notification trigger can be based on time, calendar or location
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
        //create request to display
        let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: trigger)
        //add request to notification center
        center.add(request) { _ in }
    }
    
    // Configure View
    public func configureViewBeforeVisualization(){
        
        let screenSize: CGRect = UIScreen.main.bounds
        var widthView = screenSize.width
        if (UIDevice.current.model.contains("iPad")) { widthView = widthView < self.view.frame.size.width ? self.view.frame.size.width : widthView }
        
        self.btnSubir.layer.cornerRadius = 30
        self.btnFlujos.clipsToBounds = true
        
        self.btnFlujos.layer.cornerRadius = 5.0
        self.btnFlujos.layer.borderWidth = 1.0
        self.btnFlujos.layer.borderColor = Cnstnt.Color.blue.cgColor
        
        self.view.addSubview(pagesScrollView)
//        pagesScrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
//        pagesScrollView.topAnchor.constraint(equalTo: nuevoFEBtn.bottomAnchor, constant: 0.0).isActive = true
//        pagesScrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
//        pagesScrollView.bottomAnchor.constraint(equalTo: tableview.topAnchor, constant: 0.0).isActive = true
    }
    
    
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow column: Int) -> CGFloat {
        return 30.0
    }
    
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return 90.0
    }
    
    public func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 10
    }
    
    public func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 10
    }
    
    public func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> CellSpread? {
        let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DataCell.self), for: indexPath) as! DataCell
        return cell
    }
    
    
}
