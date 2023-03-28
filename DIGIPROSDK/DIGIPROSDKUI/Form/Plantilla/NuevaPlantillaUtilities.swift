import Foundation
import CoreLocation
import Eureka

extension NuevaPlantillaViewController{
    
    public func resettingForm(){
        
    }
    
    /// Check if the user has actually the location permission
    public func checkLocationPermission() {
        ConfigurationManager.shared.utilities.writeLogger("Function CheckLocationPermission", .format)
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                ConfigurationManager.shared.utilities.writeLogger("Location Services Enable", .format)
                switch(CLLocationManager.authorizationStatus()) {
                case .restricted, .denied:
                    ConfigurationManager.shared.utilities.writeLogger("Permisos restricted/denied", .format)
                    if self.negoPermisos == 1{
                        self.defaultSettings()
                    }else{
                        if self.negoPermisos == 3{
                            self.negoPermisos = 1
                        }else{
                            self.openSettingApp(message:NSLocalizedString("nvapla_permissions_loc".langlocalized(), comment: ""));
                        }
                    }
                    break;
                case .authorizedAlways, .authorizedWhenInUse:
                    ConfigurationManager.shared.utilities.writeLogger("Permisos authorizedAlways/authorizedWhenUse", .format)
                    NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
                    NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
                    if !self.isGrantedPremissions{
                        self.negoPermisos = 0
                        self.isGrantedPremissions = true
                        self.defaultSettings()
                    }
                    break;
                case .notDetermined:
                    ConfigurationManager.shared.utilities.writeLogger("Permisos NotDetermined", .format)
                    self.locationManager.requestWhenInUseAuthorization()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        self.checkLocationPermission()
                    }
                @unknown default: break
                }
            }else {
                ConfigurationManager.shared.utilities.writeLogger("Location Services NOT enabled", .format)
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
        
    }
    
    /// Pop up to alert the user to enable the location permission
    ///
    /// - Parameter message: The message to show in the alert
    public func openSettingApp(message: String) {
        var alertController = UIAlertController()
        alertController = UIAlertController (title: nil, message:message , preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: NSLocalizedString("alrt_settings".langlocalized(), comment: ""), style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString)else{ return }
            if UIApplication.shared.canOpenURL(settingsUrl) { UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil) }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("alrt_cancel".langlocalized(), comment: ""), style: .default, handler: { action in
            if self.negoPermisos != 2{ self.negoPermisos = 1
            }else{ self.negoPermisos = 3 }
            self.checkLocationPermission()
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Get all ids from sections
    public func loopElement(_ root: Elemento, _ object: [String]) -> [String]?{
        
        var objectElement: [String] = [String]()
        if object.count > 0{ objectElement = object }
        objectElement.append(root._idelemento)
        if root.elementos?.elemento.count == 0 { return nil }
        
        for elementos in (root.elementos?.elemento)!{
            if elementos.elementos?.elemento.count ?? 0 > 0 {
                //objectElement = loopElement(elementos, objectElement)!
                if elementos._tipoelemento == "tabla" || elementos._tipoelemento == "seccion"{
                    objectElement.append(elementos._idelemento)
                }else{ continue }
            }else{
                objectElement.append(elementos._idelemento)
            }
        }
        objectElement.append("\(root._idelemento)-f")
        return objectElement
        
    }
    
    // MARK: - Set Colors for Plantilla
    public func configureColors(){
        // Plantilla Theme
        //self.view.backgroundColor = UIColor(hexFromString: atributosPlantilla?.fondoplantilla ?? atributosPlantilla?.colorfondoplantilla ?? "#ffffff", alpha: 1.0)
        self.titlePlantilla.textColor = UIColor(hexFromString: atributosPlantilla?.colortextotitulo ?? "#202020", alpha: 1.0)
        self.subtitlePlantilla.textColor = UIColor(hexFromString: atributosPlantilla?.colortextosubtitulo ?? "#202020", alpha: 1.0)
        // Colors for alerts and Popups
    }
    
    // MARK: - Set Attributes for Plantilla
    public func configureButtons(){
        let mayBeEstilo: EstiloDeBoton? = EstiloDeBoton(rawValue: atributosPlantilla?.estilocomandos ?? "fondo")
        if let estilo = mayBeEstilo {
            self.configurarBotonNavegacion(.continuar, estilo)
            self.configurarBotonNavegacion(.cancelar, estilo)
        } else {
            self.configurarBotonNavegacion(.continuar, EstiloDeBoton.iconoTextoConRelleno)
            self.configurarBotonNavegacion(.cancelar, EstiloDeBoton.iconoTextoConRelleno)
        }
    }
    
    private enum TipoDeBoton {
        case continuar
        case cancelar
    }
    
    private enum EstiloDeBoton: String {
        case iconoConRelleno = "fondo"
        case iconoTextoConRelleno = "fondotexto"
        case iconoSinRelleno = "borde"
        case iconoTextoSinRelleno = "bordetexto"
        case iconoTextoBicolor = "mixto"
    }
    
    private func configurarBotonNavegacion(_ tipo: TipoDeBoton, _ estilo: EstiloDeBoton) {
        let icono: UIImage?
        
        let textoGuardar: String = atributosPlantilla?.textoguardarplantilla ?? "alrt_continue".langlocalized()
        let colorGuardarPlantilla = UIColor(hexFromString: atributosPlantilla?.colorguardarplantilla ?? "#ffffff")
        let colorGuardarTextoPlantilla = UIColor(hexFromString: atributosPlantilla?.colorguardartextoplantilla ?? "#ffffff")
        
        let textoSalir: String = atributosPlantilla?.textocancelarplantilla ?? "alrt_cancel".langlocalized()
        let colorCancelarPlantilla = UIColor(hexFromString: atributosPlantilla?.colorcancelarplantilla ?? "#ffffff")
        let colorCancelarTextoPlantilla = UIColor(hexFromString: atributosPlantilla?.colorcancelartextoplantilla ?? "#ffffff")
        
        let bundlePath = Cnstnt.Path.framework
        
        self.btnGuardar?.clipsToBounds = true
        self.btnBack?.clipsToBounds = true
        
        self.btnGuardar?.layer.cornerRadius = 3.0
        self.btnBack?.layer.cornerRadius = 3.0
     
        let grosorDeBorde: CGFloat = 1.0
        
        switch tipo {
        case .continuar:
            icono = UIImage(named: "done_black_24dp", in: bundlePath, with: nil)?.withRenderingMode(.alwaysTemplate)
            switch estilo {
            case .iconoConRelleno:
                self.btnGuardar?.backgroundColor = colorGuardarPlantilla
                self.btnGuardar?.setImage(icono, for: .normal)
                self.btnGuardar?.tintColor = .white
                self.btnGuardar?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.btnGuardar?.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.btnGuardar?.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.btnGuardar?.sizeToFit()
                break
            case .iconoTextoConRelleno: //Icono en la derecha para continuar
                self.btnGuardar?.setTitle(textoGuardar, for: .normal)
                self.btnGuardar?.setTitleColor(colorGuardarTextoPlantilla, for: .normal)
                self.btnGuardar?.imageView?.backgroundColor = colorGuardarPlantilla
                self.btnGuardar?.backgroundColor = colorGuardarPlantilla
                self.btnGuardar?.tintColor = .white
                self.btnGuardar?.setTitle(textoGuardar, for: .normal)
                
                //Agregar el icono en la derecha:
                self.btnGuardar?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.btnGuardar?.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.btnGuardar?.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                
                self.btnGuardar?.setImage(icono, for: .normal)
                self.btnGuardar?.sizeToFit()
                break
            case .iconoSinRelleno:
                self.btnGuardar?.backgroundColor = .white
                self.btnGuardar?.tintColor = colorGuardarTextoPlantilla
                self.btnGuardar?.setImage(icono, for: .normal)
                
                self.btnGuardar?.layer.borderColor = colorGuardarPlantilla.cgColor
                self.btnGuardar?.layer.borderWidth = grosorDeBorde
                break
            case .iconoTextoSinRelleno:
                self.btnGuardar?.backgroundColor = .white
                self.btnGuardar?.tintColor = colorGuardarPlantilla
                
                self.btnGuardar?.setTitle(textoGuardar, for: .normal)
                self.btnGuardar?.setTitleColor(colorGuardarTextoPlantilla, for: .normal)

                self.btnGuardar?.setImage(icono, for: .normal)
                self.btnGuardar?.layer.borderColor = colorGuardarPlantilla.cgColor
                self.btnGuardar?.layer.borderWidth = grosorDeBorde
                
                self.btnGuardar?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.btnGuardar?.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.btnGuardar?.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.btnGuardar?.imageView?.backgroundColor = .white
                
                break
            case .iconoTextoBicolor:
                self.btnGuardar?.backgroundColor = colorGuardarPlantilla
                self.btnGuardar?.tintColor = colorGuardarPlantilla
                
                self.btnGuardar?.setTitle(textoGuardar, for: .normal)
                self.btnGuardar?.setTitleColor(colorGuardarTextoPlantilla, for: .normal)
            
                self.btnGuardar?.setImage(icono, for: .normal)
                self.btnGuardar?.layer.borderColor = colorGuardarPlantilla.cgColor
                self.btnGuardar?.layer.borderWidth = grosorDeBorde
                
                self.btnGuardar?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.btnGuardar?.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.btnGuardar?.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
                self.btnGuardar?.imageView?.backgroundColor = .white

                self.btnGuardar?.imageEdgeInsets = UIEdgeInsets(top: -6, left: -9, bottom: -6, right: 4)
                break
            }
            break
        case .cancelar:
            icono = UIImage(named: "arrow_back_black_24dp", in: bundlePath, with: nil)?.withRenderingMode(.alwaysTemplate)
            switch estilo {
            case .iconoConRelleno:
                self.btnBack?.backgroundColor = colorCancelarPlantilla
                self.btnBack?.setImage(icono, for: .normal)
                self.btnBack?.setTitleColor(colorCancelarTextoPlantilla, for: .normal)
                self.btnBack?.tintColor = .white
                break
            case .iconoTextoConRelleno: //Icono en la izquierda para continuar
                self.btnBack?.tintColor = .white
                
                self.btnBack?.setTitle(textoSalir, for: .normal)
                self.btnBack?.setTitleColor(colorCancelarTextoPlantilla, for: .normal)
                self.btnBack?.imageView?.backgroundColor = colorCancelarPlantilla
                self.btnBack?.backgroundColor = colorCancelarPlantilla
                
                self.btnBack?.setImage(icono, for: .normal)
                break
            case .iconoSinRelleno:
                self.btnBack?.backgroundColor = .white
                self.btnBack?.tintColor = colorCancelarTextoPlantilla
                self.btnBack?.setImage(icono, for: .normal)
                
                self.btnBack?.layer.borderColor = colorCancelarPlantilla.cgColor
                self.btnBack?.layer.borderWidth = grosorDeBorde
                break
            case .iconoTextoSinRelleno:
                self.btnBack?.backgroundColor = .white
                self.btnBack?.tintColor = colorCancelarPlantilla
                
                self.btnBack?.setTitle(textoSalir, for: .normal)
                self.btnBack?.setTitleColor(colorCancelarTextoPlantilla, for: .normal)
    
                self.btnBack?.setImage(icono, for: .normal)
                self.btnBack?.layer.borderColor = colorCancelarPlantilla.cgColor
                self.btnBack?.layer.borderWidth = grosorDeBorde
                self.btnBack?.sizeToFit()
                
                break
            case .iconoTextoBicolor:
                self.btnBack?.backgroundColor = colorCancelarPlantilla
                self.btnBack?.tintColor = colorCancelarPlantilla
                
                self.btnBack?.setTitle(textoSalir, for: .normal)
                self.btnBack?.setTitleColor(colorCancelarTextoPlantilla, for: .normal)
                
                self.btnBack?.setImage(icono, for: .normal)
                self.btnBack?.layer.borderColor = colorCancelarPlantilla.cgColor
                self.btnBack?.layer.borderWidth = grosorDeBorde
                
                self.btnBack?.imageView?.backgroundColor = .white
                self.btnBack?.imageEdgeInsets = UIEdgeInsets(top: -6, left: -5, bottom: -6, right: 40)
                break
            }
            break
        }
        
        self.btnBack?.imageView?.contentMode = .scaleAspectFit
        self.btnGuardar?.imageView?.contentMode = .scaleAspectFit
    }
    
    // Get Wizard Functionality From Table
    public func getWizardFunctionalityFromTable(_ tag: String){
        
        for forForm in self.forms{
            let row = forForm.rowBy(tag: tag)
            if row == nil{ continue }
            switch row{
            case is WizardRow:
                let cell = (row as? WizardRow)?.cell
                if cell == nil { break }
                if cell?.atributos?.plantillaabrir != ""{
                    self.setValuesToNewForm((cell?.atributos!.plantillaabrir)!, cell!.atributos!)
                }else{
                    self.setStatusBarNotificationBanner("not_wizard_tableerror".langlocalized(), .danger, .top)
                }
                break;
            default: break;
            }
        }
        
    }
    
    // Detect Value and perform Formulas
    public func detectValuePerformFormula(){
        for row in self.form.allRows{
            switch row{
            case is TextoRow:
                let r = (row as? TextoRow)
                if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
            case is TextoAreaRow:
                let r = (row as? TextoAreaRow)
                if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
            case is NumeroRow:
                let r = (row as? NumeroRow)
                if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
            case is MonedaRow:
                let r = (row as? MonedaRow)
                if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
            case is FechaRow:
                let r = (row as? FechaRow)
                if r?.value != nil{ r?.cell.triggerEvent("alcambiar") }; break;
            case is WizardRow:
                let r = (row as? WizardRow)
                if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
            case is LogicoRow:
                let r = (row as? LogicoRow)
                if r?.value != nil{ r?.cell.triggerEvent("alcambiar") }; break;
            case is RangoFechasRow:
                let r = (row as? RangoFechasRow)
                if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
            case is SliderNewRow:
                let r = (row as? SliderNewRow)
                if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
            case is ListaRow:
                let r = (row as? ListaRow)
                if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
            case is ListaTemporalRow:
                let r = (row as? ListaTemporalRow)
                if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
            case is TablaRow:
                let r = (row as? TablaRow)
                if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
            case is ComboDinamicoRow:
                if plist.idportal.rawValue.dataI() >= 40 {
                    let r = (row as? ComboDinamicoRow)
                    if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
                } else { break; }
            case is MarcadoDocumentoRow:
                if plist.idportal.rawValue.dataI() >= 41 {
                    let r = (row as? MarcadoDocumentoRow)
                    if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
                } else { break; }
            case is CodigoBarrasRow:
                let r = (row as? CodigoBarrasRow)
                if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
            case is CodigoQRRow:
                if plist.idportal.rawValue.dataI() >= 39 {
                    let r = (row as? CodigoQRRow)
                    if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
                } else { break; }
            case is EscanerNFCRow:
                if plist.idportal.rawValue.dataI() >= 39 {
                    let r = (row as? EscanerNFCRow)
                    if r?.value != nil && r?.value != ""{ r?.cell.triggerEvent("alcambiar") }; break;
                } else { break; }
            case is CalculadoraRow: break;
            case is AudioRow: break;
            case is FirmaRow: break;
            case is FirmaFadRow: break;
            case is MapaRow: break;
            case is ImagenRow: break;
            case is DocFormRow: break;
            case is VideoRow: break;
            case is DocumentoRow: break;
            case is VeridasDocumentOcrRow: break
            case is JUMIODocumentOcrRow: break
            case is VeridiumRow: break;
            default: break;
            }
        }
    }
    
    // Detect Attributes Visibility By Row
    public func detectAttrVisibility(_ row: BaseRow) -> Bool{
        
        switch row{
        case is TextoRow:
            if (row as? TextoRow)?.cell.atributos != nil{
                return (row as? TextoRow)?.cell.atributos?.visible ?? false
            }else if (row as? TextoRow)?.cell.atributosPassword != nil{
                return (row as? TextoRow)?.cell.atributosPassword?.visible ?? false
            }; return false
        case is TextoAreaRow:
            return (row as? TextoAreaRow)?.cell.atributos?.visible ?? false
        case is NumeroRow:
            return (row as? NumeroRow)?.cell.atributos?.visible ?? false
        case is MonedaRow:
            return (row as? MonedaRow)?.cell.atributos?.visible ?? false
        case is FechaRow:
            if (row as? FechaRow)?.cell.atributos != nil{
                return (row as? FechaRow)?.cell.atributos?.visible ?? false
            }else if (row as? FechaRow)?.cell.atributosHora != nil{
                return (row as? FechaRow)?.cell.atributosHora?.visible ?? false
            }; return false
        case is WizardRow:
            return (row as? WizardRow)?.cell.atributos?.visible ?? false
        case is BotonRow:
            return (row as? BotonRow)?.cell.atributos?.visible ?? false
        case is LogoRow:
            return (row as? LogoRow)?.cell.atributos?.visible ?? false
        case is LogicoRow:
            return (row as? LogicoRow)?.cell.atributos?.visible ?? false
        case is EtiquetaRow:
            return (row as? EtiquetaRow)?.cell.atributos?.visible ?? false
        case is ListaTemporalRow:
            return (row as? ListaTemporalRow)?.cell.atributos?.visible ?? false
        case is RangoFechasRow:
            return (row as? RangoFechasRow)?.cell.atributos?.visible ?? false
        case is SliderNewRow:
            return (row as? SliderNewRow)?.cell.atributos?.visible ?? false
        case is ListaRow:
            return (row as? ListaRow)?.cell.atributos?.visible ?? false
        case is TablaRow:
            return (row as? TablaRow)?.cell.atributos?.visible ?? false
        case is HeaderRow: return (row as? HeaderRow)?.cell.atributos?.visible ?? false
        case is HeaderTabRow: return (row as? HeaderTabRow)?.cell.atributos?.visible ?? false
        case is ComboDinamicoRow:
            if plist.idportal.rawValue.dataI() >= 40 {
                return (row as? ComboDinamicoRow)?.cell.atributos?.visible ?? false
            } else { return false }
        case is MarcadoDocumentoRow:
            if plist.idportal.rawValue.dataI() >= 41 {
                return (row as? MarcadoDocumentoRow)?.cell.atributos?.visible ?? false
            } else { return false }
        case is CodigoBarrasRow:
            return (row as? CodigoBarrasRow)?.cell.atributos?.visible ?? false
        case is CodigoQRRow:
            if plist.idportal.rawValue.dataI() >= 39 {
                return (row as? CodigoQRRow)?.cell.atributos?.visible ?? false
            } else { return false }
        case is EscanerNFCRow:
            if plist.idportal.rawValue.dataI() >= 39 {
                return (row as? EscanerNFCRow)?.cell.atributos?.visible ?? false
            } else { return false }
        case is ServicioRow, is MetodoRow: return true
        case is CalculadoraRow:
            if plist.idportal.rawValue.dataI() >= 39{
                return (row as? CalculadoraRow)?.cell.atributos?.visible ?? false
            }else{
                return false
            }
        case is AudioRow:
            return (row as? AudioRow)?.cell.atributos?.visible ?? false
        case is FirmaRow:
            return (row as? FirmaRow)?.cell.atributos?.visible ?? false
        case is FirmaFadRow:
            if plist.idportal.rawValue.dataI() >= 39{
                return (row as? FirmaFadRow)?.cell.atributos?.visible ?? false
            }else{
                return false
            }
        case is MapaRow:
            if (row as? MapaRow)?.cell.atributos != nil{
                return (row as? MapaRow)?.cell.atributos?.visible ?? false
            }else if (row as? MapaRow)?.cell.atributosGeo != nil{
                return (row as? MapaRow)?.cell.atributosGeo?.visible ?? false
            }; return false
        case is ImagenRow:
            return (row as? ImagenRow)?.cell.atributos?.visible ?? false
        case is DocFormRow:
            return (row as? DocFormRow)?.cell.atributos?.visible ?? false
        case is VideoRow:
            return (row as? VideoRow)?.cell.atributos?.visible ?? false
        case is DocumentoRow:
            return (row as? DocumentoRow)?.cell.atributos.visible ?? false
        case is VeridasDocumentOcrRow:
            return (row as? VeridasDocumentOcrRow)?.cell.atributos?.visible ?? false
        case is JUMIODocumentOcrRow:
            return (row as? JUMIODocumentOcrRow)?.cell.atributos?.visible ?? false
        case is VeridiumRow:
            return (row as? VeridiumRow)?.cell.atributos?.visible ?? false
        default: return false;
        }
        
    }
    
    // Evaluate Attributes Enable By Row
    public func evaluateAttrEnable(_ row: BaseRow, _ enable: Bool){
        
        switch row{
        case is TextoRow: (row as? TextoRow)?.cell.setHabilitado(enable); break
        case is TextoAreaRow: (row as? TextoAreaRow)?.cell.setHabilitado(enable); break
        case is NumeroRow: (row as? NumeroRow)?.cell.setHabilitado(enable); break
        case is MonedaRow: (row as? MonedaRow)?.cell.setHabilitado(enable); break
        case is FechaRow: (row as? FechaRow)?.cell.setHabilitado(enable); break
        case is WizardRow: (row as? WizardRow)?.cell.setHabilitado(enable); break
        case is BotonRow: (row as? BotonRow)?.cell.setHabilitado(enable); break
        case is LogoRow: (row as? LogoRow)?.cell.setHabilitado(enable); break
        case is LogicoRow: (row as? LogicoRow)?.cell.setHabilitado(enable); break
        case is EtiquetaRow: (row as? EtiquetaRow)?.cell.setHabilitado(enable); break
        case is ListaTemporalRow: (row as? ListaTemporalRow)?.cell.setHabilitado(enable); break
        case is RangoFechasRow: (row as? RangoFechasRow)?.cell.setHabilitado(enable); break
        case is SliderNewRow: (row as? SliderNewRow)?.cell.setHabilitado(enable); break
        case is ListaRow:
            (row as? ListaRow)?.cell.setHabilitado(enable);
            break
        case is TablaRow: (row as? TablaRow)?.cell.setHabilitado(enable); break
        case is HeaderRow: (row as? HeaderRow)?.cell.setHabilitado(enable); break
        case is HeaderTabRow: (row as? HeaderTabRow)?.cell.setHabilitado(enable); break
        case is ComboDinamicoRow:
            if plist.idportal.rawValue.dataI() >= 40 {
                (row as? ComboDinamicoRow)?.cell.setHabilitado(enable); break
            } else { break }
        case is MarcadoDocumentoRow:
            if plist.idportal.rawValue.dataI() >= 41 {
                (row as? MarcadoDocumentoRow)?.cell.setHabilitado(enable); break
            } else { break }
        case is CodigoBarrasRow: (row as? CodigoBarrasRow)?.cell.setHabilitado(enable); break
        case is CodigoQRRow:
            if plist.idportal.rawValue.dataI() >= 39 {
                (row as? CodigoQRRow)?.cell.setHabilitado(enable); break
            } else { break }
        case is EscanerNFCRow:
            if plist.idportal.rawValue.dataI() >= 39 {
                (row as? EscanerNFCRow)?.cell.setHabilitado(enable); break
            } else { break }
        case is ServicioRow, is MetodoRow: break
        case is CalculadoraRow:
            if plist.idportal.rawValue.dataI() >= 39{
                (row as? CalculadoraRow)?.cell.setHabilitado(enable); break
            }
        case is AudioRow: (row as? AudioRow)?.cell.setHabilitado(enable); break
        case is FirmaRow: (row as? FirmaRow)?.cell.setHabilitado(enable); break
        case is FirmaFadRow:
            if plist.idportal.rawValue.dataI() >= 39 {
                (row as? FirmaFadRow)?.cell.setHabilitado(enable); break
            }
        case is MapaRow: (row as? MapaRow)?.cell.setHabilitado(enable); break
        case is ImagenRow: (row as? ImagenRow)?.cell.setHabilitado(enable); break
        case is DocFormRow: (row as? DocFormRow)?.cell.setHabilitado(enable); break
        case is VideoRow: (row as? VideoRow)?.cell.setHabilitado(enable); break
        case is DocumentoRow: (row as? DocumentoRow)?.cell.setHabilitado(enable); break
        case is VeridasDocumentOcrRow: (row as? VeridasDocumentOcrRow)?.cell.setHabilitado(enable); break
        case is JUMIODocumentOcrRow: (row as? JUMIODocumentOcrRow)?.cell.setHabilitado(enable); break
        case is VeridiumRow: (row as? VeridiumRow)?.cell.setHabilitado(enable); break
        default: break
        }
    }
    
    // Get Title Plantilla
    public func getPlantillaTitle()->String{
        return self.atributosPlantilla?.titulo ?? ""
    }
    
    // Get Title by Row
    public func getTitleByRow(_ row: BaseRow) -> String{
        
        switch row{
        case is TextoRow:
            if (row as? TextoRow)?.cell.atributos != nil{ return (row as? TextoRow)?.cell.atributos?.titulo ?? ""
            }else if (row as? TextoRow)?.cell.atributosPassword != nil{ return (row as? TextoRow)?.cell.atributosPassword?.titulo ?? "" }
            return ""
        case is TextoAreaRow:
            return (row as? TextoAreaRow)?.cell.atributos?.titulo ?? ""
        case is NumeroRow:
            return (row as? NumeroRow)?.cell.atributos?.titulo ?? ""
        case is MonedaRow:
            return (row as? MonedaRow)?.cell.atributos?.titulo ?? ""
        case is FechaRow:
            if (row as? FechaRow)?.cell.atributos != nil{ return (row as? FechaRow)?.cell.atributos?.titulo ?? ""
            }else if (row as? FechaRow)?.cell.atributosHora != nil{ return (row as? FechaRow)?.cell.atributosHora?.titulo ?? "" }
            return ""
        case is WizardRow:
            return (row as? WizardRow)?.cell.atributos?.titulo ?? ""
        case is BotonRow:
            return (row as? BotonRow)?.cell.atributos?.titulo ?? ""
        case is LogoRow:
            return (row as? LogoRow)?.cell.atributos?.titulo ?? ""
        case is LogicoRow:
            return (row as? LogicoRow)?.cell.atributos?.titulo ?? ""
        case is EtiquetaRow:
            return (row as? EtiquetaRow)?.cell.atributos?.titulo ?? ""
        case is ListaTemporalRow:
            return (row as? ListaTemporalRow)?.cell.atributos?.titulo ?? ""
        case is RangoFechasRow:
            return (row as? RangoFechasRow)?.cell.atributos?.titulo ?? ""
        case is SliderNewRow:
            return (row as? SliderNewRow)?.cell.atributos?.titulo ?? ""
        case is ListaRow:
            return (row as? ListaRow)?.cell.atributos?.titulo ?? ""
        case is TablaRow:
            return (row as? TablaRow)?.cell.atributos?.titulo ?? ""
        case is HeaderRow: return (row as? HeaderRow)?.cell.atributos?.titulo ?? ""
        case is HeaderTabRow: return (row as? HeaderTabRow)?.cell.atributos?.titulo ?? ""
        case is ComboDinamicoRow:
            if plist.idportal.rawValue.dataI() >= 40 {
                return (row as? ComboDinamicoRow)?.cell.atributos?.titulo ?? ""
            } else { return ""}
        case is MarcadoDocumentoRow:
            if plist.idportal.rawValue.dataI() >= 41 {
                return (row as? MarcadoDocumentoRow)?.cell.atributos?.titulo ?? ""
            } else { return ""}
        case is CodigoBarrasRow:
            return (row as? CodigoBarrasRow)?.cell.atributos?.titulo ?? ""
        case is CodigoQRRow:
            if plist.idportal.rawValue.dataI() >= 39 {
                return (row as? CodigoQRRow)?.cell.atributos?.titulo ?? ""
            } else { return ""}
        case is EscanerNFCRow:
            if plist.idportal.rawValue.dataI() >= 39 {
                return (row as? EscanerNFCRow)?.cell.atributos?.titulo ?? ""
            } else { return ""}
        case is CalculadoraRow:
            if plist.idportal.rawValue.dataI() >= 39{
                return (row as? CalculadoraRow)?.cell.atributos?.titulo ?? ""
            }else{return ""}
        case is AudioRow:
            return (row as? AudioRow)?.cell.atributos?.titulo ?? ""
        case is FirmaRow:
            return (row as? FirmaRow)?.cell.atributos?.titulo ?? ""
        case is FirmaFadRow:
            if plist.idportal.rawValue.dataI() >= 39{
                return (row as? FirmaFadRow)?.cell.atributos?.titulo ?? ""
            }else{return ""}
        case is MapaRow:
            if (row as? MapaRow)?.cell.atributos != nil{ return (row as? MapaRow)?.cell.atributos?.titulo ?? ""
            }else if (row as? MapaRow)?.cell.atributosGeo != nil{ return (row as? MapaRow)?.cell.atributosGeo?.titulo ?? "" }
            return ""
        case is ImagenRow:
            return (row as? ImagenRow)?.cell.atributos?.titulo ?? ""
        case is DocFormRow:
            return (row as? DocFormRow)?.cell.atributos?.titulo ?? ""
        case is VideoRow:
            return (row as? VideoRow)?.cell.atributos?.titulo ?? ""
        case is DocumentoRow:
            return (row as? DocumentoRow)?.cell.atributos.titulo ?? ""
        case is ServicioRow, is MetodoRow: return ""
        case is VeridasDocumentOcrRow:
            return (row as? VeridasDocumentOcrRow)?.cell.atributos?.titulo ?? ""
        case is JUMIODocumentOcrRow:
            return (row as? JUMIODocumentOcrRow)?.cell.atributos?.titulo ?? ""
        case is VeridiumRow:
            return (row as? VeridiumRow)?.cell.atributos?.titulo ?? ""
        default: return "";
        }
        
    }
    
    // Detect Parent Section
    public func getParentsection(_ rowString: String) -> Atributos_seccion?{
        
        for form in self.forms{
            let row = form.rowBy(tag: rowString)
            if row == nil { continue }
            switch row{
            case is HeaderRow:
                return (row as? HeaderRow)?.cell.atributos ?? nil
            default: break;
            }
        }
        
        return nil
    }
    
    // Get Page Title
    //Recibe el elemento padre de un elemento, de ahi buscar el titulo:
    public func getPageTitle(_ rowString: String) -> String {
        let row = getElementByIdInAllForms(rowString)
        if let _ = row {
            if row is HeaderRow {
                if let seccionRow = row as? HeaderRow {
                    let elementopadre = seccionRow.cell.atributos?.elementopadre
                    return self.getPageTitle(elementopadre ?? "")
                }
            } else if row is PaginaRow {
                let atributo = FormularioUtilities.shared.atributosPaginas.first { atr in
                    atr.idelemento == rowString
                }
                guard let atr = atributo else { return "" }
                return atr.titulo
            }
        }
       return ""
    }
    
    public func getPageID(_ rowString: String) -> String {
        let row = getElementByIdInAllForms(rowString)
        if let _ = row {
            if row is HeaderRow {
                if let seccionRow = row as? HeaderRow {
                    let elementopadre = seccionRow.cell.atributos?.elementopadre
                    return self.getPageTitle(elementopadre ?? "")
                }
            } else if row is PaginaRow {
                let atributo = FormularioUtilities.shared.atributosPaginas.first { atr in
                    atr.idelemento == rowString
                }
                guard let atr = atributo else { return "" }
                return atr.titulo.replaceFormElec()
            }
        }
       return ""
    }
    
    // Set Visible Object for Sections
    public func setVisibleEnableElementsFromSection(_ tag: String, _ atributos: Atributos_seccion, _ forced: Bool = false, _ isUserAction: Bool = false){
        var isHDetected = false
        var isFDetected = false
        var tagInit = ""
        var tagFinal = ""
        
        var parentIsHidden: Bool = false
        
        var attributes_parent: Atributos_seccion?
        
        if !forced && atributos.visible || atributos.elementopadre != "" {
            attributes_parent = self.getParentsection(atributos.elementopadre)
        }
        
        let elements = self.getElementByIdInAllForms("\(tag)")
        let section = (elements as? HeaderRow)?.cell.sects
        if section?.count == 0 || section == nil{ return }
        
        // We need to get all sections in section
        for innerSect in section!{
            let rowString = innerSect
            let rows = self.getElementByIdsInAllForms(rowString.elements)
            
            if rows.count > 0{
                for rw in rows {
                    if rw == nil{ continue }
                    if tag == rw?.tag{ tagInit = tag; tagFinal = "\(tagInit)-f"; isHDetected = true; if isUserAction{ continue }}
                    if tagFinal == rw?.tag{
                        isFDetected = true;
                        break
                    }
                    
                    if isHDetected{
                        ConfigurationManager.shared.utilities.writeLogger("Element: \(rw?.tag ?? "")", .format)
                        if attributes_parent != nil{
                            if attributes_parent?.visible == false{
                                rw?.hidden = Condition(booleanLiteral: true)
                                ConfigurationManager.shared.utilities.writeLogger("Set Visibility to false", .format)
                            }else{
                                
                                let visibility = self.detectAttrVisibility(rw!)
                                
                                if rw!.tag == tagInit && visibility == false {
                                    rw?.hidden = Condition(booleanLiteral: !visibility)
                                    parentIsHidden = true
                                    continue
                                }
                                
                                if parentIsHidden == true {
                                    rw?.hidden = Condition(booleanLiteral: !false)
                                } else {
                                    rw?.hidden = Condition(booleanLiteral: !visibility)
                                }
                                
                            }
                            rw?.evaluateHidden()
                            ConfigurationManager.shared.utilities.writeLogger("Visibility setted", .format)
                        }else{
                            
                            if (tag != rw?.tag) && getElementANY(rw?.tag ?? "").type == "seccion" {
                                _ = self.resolveVisible(rw?.tag ?? "", "asignacion", String(atributos.visible))
                            } else {
                                if atributos.visible == false{
                                    rw?.hidden = Condition(booleanLiteral: true)
                                    ConfigurationManager.shared.utilities.writeLogger("Set Visibility to false", .format)
                                }else{
                                    ConfigurationManager.shared.utilities.writeLogger("Set Visibility to true", .format)
                                    let visibility = self.detectAttrVisibility(rw!)
                                    if visibility {
                                        rw?.hidden = Condition(booleanLiteral: false)
                                    }
                                }
                                rw?.evaluateHidden()
                                ConfigurationManager.shared.utilities.writeLogger("Visibility setted", .format)
                            }
                        }
                        
                        if isFDetected{ break; }
                    }
                    
                }
            }
        }
    }
    
    // Set Enable Object for Sections
    public func setEnableElementsFromSection(_ tag: String, _ atributos: Atributos_seccion){
        var isHDetected = false
        var isFDetected = false
        var tagInit = ""
        var tagFinal = ""
        
        let elements = self.getElementByIdInAllForms("\(tag)")
        let section = (elements as? HeaderRow)?.cell.sects
        if section?.count == 0{ return }
        
        // We need to get all sections in section
        for innerSect in section!{
            let rowString = innerSect
            let rows = self.getElementByIdsInAllForms(rowString.elements)
            
            if rows.count > 0{
                for rw in rows{
                    if rw == nil{ continue }
                    if tag == rw?.tag {
                        tagInit = tag
                        tagFinal = "\(tagInit)-f"
                        isHDetected = true
                    }
                    
                    if tagFinal == rw?.tag{ isFDetected = true; }
                    
                    if isHDetected{
                        self.evaluateAttrEnable(rw!, atributos.habilitado)
                        if atributos.visible == false{
                            rw?.hidden = Condition(booleanLiteral: true)
                            rw?.evaluateHidden()
                        }else{
                            let visibility = self.detectAttrVisibility(rw!)
                            rw?.hidden = Condition(booleanLiteral: !visibility)
                            rw?.evaluateHidden()
                        }
                        if isFDetected{ break; }
                    }
                    
                }
            }
        }
    }
    
    public func setVisibleEnableElementsFromTabber(_ tag: String, _ atributos: Atributos_tabber){
        
        let _ = atributos.visible
        let elements = self.getElementByIdInAllForms("\(tag)")
        let section = (elements as? HeaderTabRow)?.cell.sects
        if section?.count == 0 { return }
        let atributosSeccion = section?[0].attributes
        
        let seccion = section?[0].elements[0]
        
        //let seccionRow = self.getElementById(seccion!)
        let seccionRow = self.getElementByIdInCurrentForm(seccion!)
        if let row = seccionRow as? HeaderRow {
            let atributos = row.cell.atributos ?? Atributos_seccion()
            self.setVisibleEnableElementsFromSection(seccion ?? "", atributos)
        }
        
        //Solo las pestañas tienen secciones entonces sacamos la primera seccion y escondemos todos:
        //self.setVisibleEnableElementsFromSection(seccion!, atributosSeccion!)
    }
    
    // Set Elements to a Modal Presentation
    public func getElementsFromSectionToModal(_ tag: String) -> Form{
        var isHDetected = false
        var isFDetected = false
        var tagInit = ""
        var tagFinal = ""
        
        let rowsModal: Form = Form()
        
        for form in forms{
            for rw in form.allRows{
                if tag == rw.tag{ tagInit = tag; tagFinal = "\(tagInit)-f"; isHDetected = true; }
                if tagFinal == rw.tag{ isFDetected = true; }
                
                if isHDetected{
                    rowsModal +++ rw
                    if isFDetected{ return rowsModal; }
                }
            }
        }
        
        return rowsModal
    }
    
    public func validateRowFromForm(_ row: BaseRow){
        
        switch row{
        // DIGIPROSDKSO
        case is TextoRow:
            let cell = (row as? TextoRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            if cell?.atributosPassword?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            break;
        case is TextoAreaRow:
            let cell = (row as? TextoAreaRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            break;
        case is NumeroRow:
            let cell = (row as? NumeroRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            break;
        case is MonedaRow:
            let cell = (row as? MonedaRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            break;
        case is FechaRow:
            let cell = (row as? FechaRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            if cell?.atributosHora?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            break;
        case is WizardRow:
            let cell = (row as? WizardRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            break;
        case is LogicoRow:
            let cell = (row as? LogicoRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            break;
        case is RangoFechasRow:
            let cell = (row as? RangoFechasRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            break;
        case is SliderNewRow:
            let cell = (row as? SliderNewRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            break;
        case is ListaRow:
            let cell = (row as? ListaRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            break;
        case is ListaTemporalRow:
            let cell = (row as? ListaTemporalRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            break;
        case is TablaRow:
            let cell = (row as? TablaRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            break;
        case is ComboDinamicoRow:
            if plist.idportal.rawValue.dataI() >= 40 {
                let cell = (row as? ComboDinamicoRow)?.cell
                if cell == nil { break }
                if cell?.atributos?.visible ?? false && !row.isHidden {
                    cell?.resetValidation()
                    if cell?.elemento.validacion.needsValidation ?? false{
                        _ = row.validate()
                        cell?.updateIfIsValid()
                    }
                    if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                        self.elementsForValidate.append("\(row.tag ?? "")")
                    }
                }
            }
            break;
        case is MarcadoDocumentoRow:
            if plist.idportal.rawValue.dataI() >= 41 {
                let cell = (row as? MarcadoDocumentoRow)?.cell
                if cell == nil { break }
                if cell?.atributos?.visible ?? false && !row.isHidden {
                    cell?.resetValidation()
                    if cell?.elemento.validacion.needsValidation ?? false{
                        _ = row.validate()
                        cell?.updateIfIsValid()
                    }
                    if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                        self.elementsForValidate.append("\(row.tag ?? "")")
                    }
                }
            }
            break;
        case is CodigoBarrasRow:
            let cell = (row as? CodigoBarrasRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                cell?.resetValidation()
                if cell?.elemento.validacion.needsValidation ?? false{
                    _ = row.validate()
                    cell?.updateIfIsValid()
                }
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            break;
        case is CodigoQRRow:
            if plist.idportal.rawValue.dataI() >= 39 {
                let cell = (row as? CodigoQRRow)?.cell
                if cell == nil { break }
                if cell?.atributos?.visible ?? false && !row.isHidden {
                    cell?.resetValidation()
                    if cell?.elemento.validacion.needsValidation ?? false{
                        _ = row.validate()
                        cell?.updateIfIsValid()
                    }
                    if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                        self.elementsForValidate.append("\(row.tag ?? "")")
                    }
                }
            }
            break;
        case is EscanerNFCRow:
            if plist.idportal.rawValue.dataI() >= 39 {
                let cell = (row as? EscanerNFCRow)?.cell
                if cell == nil { break }
                if cell?.atributos?.visible ?? false && !row.isHidden {
                    cell?.resetValidation()
                    if cell?.elemento.validacion.needsValidation ?? false{
                        _ = row.validate()
                        cell?.updateIfIsValid()
                    }
                    if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                        self.elementsForValidate.append("\(row.tag ?? "")")
                    }
                }
            }
            break;
        case is CalculadoraRow:
            if plist.idportal.rawValue.dataI() >= 39{
                let cell = (row as? CalculadoraRow)?.cell
                if cell == nil { break }
                if cell?.atributos?.visible ?? false && !row.isHidden {
                    _ = row.validate()
                    cell?.updateIfIsValid()
                    if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                        self.elementsForValidate.append("\(row.tag ?? "")")
                    }
                }
                break;
            }
        case is AudioRow:
            let cell = (row as? AudioRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                _ = row.validate()
                cell?.updateIfIsValid()
                if cell?.elemento.validacion.needsValidation ?? false{
                    if (cell?.elemento.validacion.validado ?? false) == false{
                        for elemAnexo in (cell?.elemento.validacion.anexos)!{
                            if elemAnexo.id != "", elemAnexo.id == "reemplazo"{
                                cell?.elemento.validacion.validado = true; cell?.elemento.validacion.valor = elemAnexo.url
                            }
                        }
                        if (cell?.elemento.validacion.validado ?? false) == false{ self.elementsForValidate.append("\(row.tag ?? "")") }
                    }
                }
            }
            break;
        case is FirmaRow:
            let cell = (row as? FirmaRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                _ = row.validate()
                cell?.updateIfIsValid()
                if cell?.elemento.validacion.needsValidation ?? false{
                    if (cell?.elemento.validacion.validado ?? false) == false{
                        for elemAnexo in (cell?.elemento.validacion.anexos)!{
                            if elemAnexo.id != "", elemAnexo.id == "reemplazo"{
                                cell?.elemento.validacion.validado = true; cell?.elemento.validacion.valor = elemAnexo.url
                            }
                        }
                        if (cell?.elemento.validacion.validado ?? false) == false{ self.elementsForValidate.append("\(row.tag ?? "")") }
                    }
                }
            }
            break;
        case is FirmaFadRow:
            if plist.idportal.rawValue.dataI() >= 39{
                let cell = (row as? FirmaFadRow)?.cell
                if cell == nil { break }
                if cell?.atributos?.visible ?? false && !row.isHidden {
                    _ = row.validate()
                    cell?.updateIfIsValid()
                    if cell?.elemento.validacion.needsValidation ?? false{
                        if (cell?.elemento.validacion.validado ?? false) == false{
                            for elemAnexo in (cell?.elemento.validacion.anexos)!{
                                if elemAnexo.id != "", elemAnexo.id == "reemplazo"{
                                    cell?.elemento.validacion.validado = true; cell?.elemento.validacion.valor = elemAnexo.url
                                }
                            }
                            if (cell?.elemento.validacion.validado ?? false) == false{ self.elementsForValidate.append("\(row.tag ?? "")") }
                        }
                    }
                }
                break;
            }
        case is MapaRow:
            let cell = (row as? MapaRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                _ = row.validate()
                cell?.updateIfIsValid()
                if cell?.elemento.validacion.needsValidation ?? false{
                    if (cell?.elemento.validacion.validado ?? false) == false{
                        for elemAnexo in (cell?.elemento.validacion.anexos)!{
                            if elemAnexo.id != "", elemAnexo.id == "reemplazo"{
                                cell?.elemento.validacion.validado = true; cell?.elemento.validacion.valor = elemAnexo.url
                            }
                        }
                        if (cell?.elemento.validacion.validado ?? false) == false{ self.elementsForValidate.append("\(row.tag ?? "")") }
                    }
                }
            }
            if cell?.atributosGeo?.visible ?? false && !row.isHidden {
                _ = row.validate()
                cell?.updateIfIsValid()
                if cell?.elemento.validacion.needsValidation ?? false{
                    if (cell?.elemento.validacion.validado ?? false) == false{
                        for elemAnexo in (cell?.elemento.validacion.anexos)!{
                            if elemAnexo.id != "", elemAnexo.id == "reemplazo"{
                                cell?.elemento.validacion.validado = true; cell?.elemento.validacion.valor = elemAnexo.url
                            }
                        }
                        if (cell?.elemento.validacion.validado ?? false) == false{ self.elementsForValidate.append("\(row.tag ?? "")") }
                    }
                }
            }
            break;
        case is ImagenRow:
            let cell = (row as? ImagenRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                _ = row.validate()
                cell?.updateIfIsValid()
                if cell?.elemento.validacion.needsValidation ?? false{
                    if (cell?.elemento.validacion.validado ?? false) == false{
                        for elemAnexo in (cell?.elemento.validacion.anexos)!{
                            if elemAnexo.id != "", elemAnexo.id == "reemplazo"{
                                cell?.elemento.validacion.validado = true; cell?.elemento.validacion.valor = elemAnexo.url
                            }
                        }
                        if (cell?.elemento.validacion.validado ?? false) == false{ self.elementsForValidate.append("\(row.tag ?? "")") }
                    }
                }
            }
            break;
        case is DocFormRow:
            let cell = (row as? DocFormRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                _ = row.validate()
                cell?.updateIfIsValid()
                if cell?.elemento.validacion.needsValidation ?? false {
                    if (cell?.elemento.validacion.validado ?? false) == false {
                        for elemAnexo in (cell?.elemento.validacion.anexos)! {
                            if elemAnexo.id != "", elemAnexo.id == "reemplazo" {
                                cell?.elemento.validacion.validado = true; cell?.elemento.validacion.valor = elemAnexo.url
                            }
                        }
                        if (cell?.elemento.validacion.validado ?? false) == false{ self.elementsForValidate.append("\(row.tag ?? "")") }
                    }
                }
            }
            break;
        case is VideoRow:
            let cell = (row as? VideoRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                _ = row.validate()
                cell?.updateIfIsValid()
                if cell?.elemento.validacion.needsValidation ?? false{
                    if (cell?.elemento.validacion.validado ?? false) == false{
                        for elemAnexo in (cell?.elemento.validacion.anexos)!{
                            if elemAnexo.id != "", elemAnexo.id == "reemplazo"{
                                cell?.elemento.validacion.validado = true; cell?.elemento.validacion.valor = elemAnexo.url
                            }
                        }
                        if (cell?.elemento.validacion.validado ?? false) == false{ self.elementsForValidate.append("\(row.tag ?? "")") }
                    }
                }
            }
            break;
            
        case is DocumentoRow:
            let cell = (row as? DocumentoRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                _ = row.validate()
                let isDefault = cell?.atributos?.requerido == true ? false : true
                cell?.updateIfIsValid(isDefault: isDefault)
                if cell?.elemento.validacion.needsValidation ?? false {
                    if (cell?.elemento.validacion.validado ?? false) == false {
                        for elemAnexo in (cell?.elemento.validacion.anexos)! {
                            if elemAnexo.id != "", elemAnexo.id == "reemplazo" {
                                cell?.elemento.validacion.validado = true
                                cell?.elemento.validacion.valor = elemAnexo.url
                            }
                        }
                        if (cell?.elemento.validacion.validado ?? false) == false {
                            self.elementsForValidate.append("\(row.tag ?? "")")
                        }
                    }
                }
            }
            
            break;
        case is VeridasDocumentOcrRow:
            break
        case is JUMIODocumentOcrRow:
            break
        case is VeridiumRow:
            let cell = (row as? VeridiumRow)?.cell
            if cell == nil { break }
            if cell?.atributos?.visible ?? false && !row.isHidden {
                _ = row.validate()
                cell?.updateIfIsValid()
                if cell?.elemento.validacion.needsValidation ?? false && (cell?.elemento.validacion.validado ?? false) == false{
                    self.elementsForValidate.append("\(row.tag ?? "")")
                }
            }
            break;
        default:
            break;
        }
        
    }
    
    // Validation Rows By Form
    public func validationRowsForm(_ index: Int?, _ elements: [BaseRow]?){
        
        if elements != nil{
            for row in elements!{
                validateRowFromForm(row)
            }
        }else if index != nil{
            
            // Detecting if the row has a Table Form
            for sect in self.forms[index!].allSections{
                if sect.tag?.contains("InnerForm") ?? false{
                    return
                }
            }
            for row in self.forms[index!].allRows{
                validateRowFromForm(row)
            }
        }
        
    }
    
    // Get Static Elements
    public func getStaticElements() -> [(title: String, value: String)]{
        var dummyEstaticos: [(title: String, value: String)] = [(title: String, value: String)]()
        
        for element in FormularioUtilities.shared.elementsInPlantilla{
            
            switch element.kind{
            case is TextoRow:
                let row = element.kind as? TextoRow
                if row?.cell.atributos?.contenidoestatico ?? false{
                    dummyEstaticos.append((title: row?.cell.getTitleLabel() ?? "", value: row?.value ?? ""))
                }
                break;
            case is TextoAreaRow:
                let row = element.kind as? TextoAreaRow
                if row?.cell.atributos?.contenidoestatico ?? false{
                    dummyEstaticos.append((title: row?.cell.getTitleLabel() ?? "", value: row?.value ?? ""))
                }
                break;
            case is NumeroRow:
                let row = element.kind as? NumeroRow
                if row?.cell.atributos?.contenidoestatico ?? false{
                    dummyEstaticos.append((title: row?.cell.getTitleLabel() ?? "", value: row?.value ?? ""))
                }
                break;
            case is MonedaRow:
                let row = element.kind as? MonedaRow
                if row?.cell.atributos?.contenidoestatico ?? false{
                    dummyEstaticos.append((title: row?.cell.getTitleLabel() ?? "", value: row?.value ?? ""))
                }
                break;
            default:
                break;
            }
            
        }
        return dummyEstaticos
    }
    
    public func getValuesJson(_ jsonString: String = ""){
        do{
            var customJson = ""
            if jsonString == ""{ customJson = self.sdkAPI?.DGSDKgetJson(FormularioUtilities.shared.currentFormato) ?? ""
            }else{ customJson = jsonString }
            if customJson == "" { return }
            let dict = try JSONSerializer.toDictionary(customJson)
            let sorted = dict.sorted { (arg0, arg1) -> Bool in
                let (key1, _) = arg0
                let (key2, _) = arg1
                return (key1 as! String) < (key2 as! String)
            }
            for dato in sorted{
                let dictValor = dato.value as! NSMutableDictionary
                let docid = dictValor.value(forKey: "docid") as? String ?? "0"
                let valor = dictValor.value(forKey: "valor") as? String ?? ""
                let valormetadato = dictValor.value(forKey: "valormetadato") as? String ?? ""
                let tipodoc = dictValor.value(forKey: "tipodoc") as? String ?? ""
                let metadatostipodoc = dictValor.value(forKey: "metadatostipodoc") as? String ?? ""
                //FAD
                let nameFirm = dictValor.value(forKey: "nombrefirmante") as? String ?? ""
                let dateFirm = dictValor.value(forKey: "fecha") as? String ?? ""
                let georefFirm = dictValor.value(forKey: "georeferencia") as? String ?? ""
                let deviceFirm = dictValor.value(forKey: "dispositivo") as? String ?? ""
                
                dictValues["\(dato.key)"] = (docid: docid, valor: valor, valormetadato: valormetadato, tipodoc: tipodoc, metadatostipodoc: metadatostipodoc, nameFirm: nameFirm, dateFirm: dateFirm, georefFirm: georefFirm, deviceFirm: deviceFirm)
            }
            
        }catch{ }
    }
    
    // Getting Delegate for further actions
    public func getFormViewControllerDelegate() -> FormViewController?{ return self }
    
    public func getNestedForm() -> FormViewController?{ return self.navigation }
    
    public func setNestedForm(_ nav: FormViewController?){ self.navigation = nav }
}

// MARK: - Notification Center
extension NuevaPlantillaViewController{
    
    public func setNotificationBanner(_ title: String, _ subtitle: String, _ style: BannerStyle, _ color: UIColor?, _ text: UIColor?){
        if color != nil{
            let banner = NotificationBanner(title: title, subtitle: subtitle, leftView: nil, rightView: nil, style: .info, colors: color, texts: text)
            banner.show(bannerPosition: .bottom)
        }else{
            let banner = NotificationBanner(title: title, subtitle: subtitle, style: style)
            banner.show(bannerPosition: .bottom)
        }
    }
    
    public func setNotificationBanner(_ title: String, _ subtitle: String, _ style: BannerStyle, _ direction: BannerPosition){
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: style)
        if direction == .bottom{
            banner.show(bannerPosition: direction)
        }else{
            banner.show()
        }
        
    }
    public func setStatusBarNotificationBanner(_ title: String, _ style: BannerStyle, _ direction: BannerPosition){
        
        switch style{
        case .danger:
            let bg: UIColor = UIColor(hexFromString: "#D93829", alpha: 1.0)
            let txt: UIColor = UIColor(hexFromString: "#FFFFFF", alpha: 1.0)
            let banner = NotificationBanner(title: title, subtitle: nil, leftView: nil, rightView: nil, style: .danger, colors: bg, texts: txt)
            banner.show(bannerPosition: .bottom)
            break;
        case .info:
            var bg: UIColor = UIColor(hexFromString: self.atributosPlantilla?.colorfondoalertainfo ?? "#3C3CCC", alpha: 1.0)
            var txt: UIColor = UIColor(hexFromString: self.atributosPlantilla?.colortextoalertainfo ?? "#FFFFFF", alpha: 1.0)
            if self.atributosPlantilla?.colorfondoalertainfo == ""{ bg = UIColor(hexFromString: "#3C3CCC", alpha: 1.0) }
            if self.atributosPlantilla?.colortextoalertainfo == ""{ txt = UIColor(hexFromString: "#FFFFFF", alpha: 1.0) }
            let banner = NotificationBanner(title: title, subtitle: nil, leftView: nil, rightView: nil, style: .info, colors: bg, texts: txt)
            banner.show(bannerPosition: .bottom)
            banner.bannerQueue.removeAll()
            break;
        case .none:
            let banner = NotificationBanner(title: title, style: style)
            banner.show(bannerPosition: .bottom)
        case .success:
            let bg: UIColor = UIColor(hexFromString: "#68B848", alpha: 1.0)
            let txt: UIColor = UIColor(hexFromString: "#FFFFFF", alpha: 1.0)
            let banner = NotificationBanner(title: title, subtitle: nil, leftView: nil, rightView: nil, style: .success, colors: bg, texts: txt)
            //let banner = NotificationBanner(title: title, leftView: nil, rightView: nil, style: .info, colors: bg, texts: txt)
            banner.show(bannerPosition: .bottom)
            break;
        case .warning:
            //Color amarillo
            let bg: UIColor = UIColor(hexFromString: "#FFD500", alpha: 1.0)
            let txt: UIColor = UIColor(hexFromString: "#FFFFFF", alpha: 1.0)
            let banner = NotificationBanner(title: title, subtitle: nil, leftView: nil, rightView: nil, style: .warning, colors: bg, texts: txt)
            banner.show(bannerPosition: .bottom)
            break;
        default: break
        }
    }
    
    public func refreshConstraintsOrLayout(){
        self.view.layoutIfNeeded()
        self.tableView.reloadData()
    }
    
}

// MARK: - Custom Alert
extension NuevaPlantillaViewController: CustomAlertViewDelegate {
    func okButtonTapped() {
        if ConfigurationManager.shared.isConsubanco{
            self.flagCot = false
            if flagAlert{
                self.formatoData.EstadoApp = 1
                self.formatoData.Editado = true
                FormularioUtilities.shared.globalFlujo = self.formatoData.FlujoID
                FormularioUtilities.shared.globalProceso = 0
            }
            
            if  self.atributosPlantilla?.titulo == "Biométrico"{
                self.flagCot = false
                self.setValuesToObject(accion: actionForm.borrador)
            }else{
                self.flagCot = true
                if self.flagCalculadora{
                    self.setValuesToObject(accion: actionForm.publicado)
                    self.sendToServerEC()
                }else{
                    self.setValuesToObject(accion: actionForm.borrador)
                }
            }
            
        }else{
            if flagAlert{
                self.formatoData.EstadoApp = 1
                self.formatoData.Editado = true
                self.setValuesToObject(accion: actionForm.publicado)
                FormularioUtilities.shared.globalFlujo = self.formatoData.FlujoID
                FormularioUtilities.shared.globalProceso = 0
            }
        }
        
    }
    func cancelButtonTapped() {
        if ConfigurationManager.shared.isConsubanco{
            if  self.atributosPlantilla?.titulo == "Biométrico"{}else{
                self.flagAlert = false
                self.closeViewController(status: 400)
            }
            
        }
        
    }
}
