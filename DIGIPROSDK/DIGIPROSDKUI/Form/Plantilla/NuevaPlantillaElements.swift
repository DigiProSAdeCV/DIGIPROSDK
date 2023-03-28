import Foundation
import Eureka

extension NuevaPlantillaViewController{
    
    func printElemento(hijos:[Elemento], formulario: Form, section: Section? = nil, isRoot: Bool = true, atributosGlobales: Atributos_pagina? = nil, atributosSeccion: Atributos_seccion? = nil, isFooter: Bool? = nil){
        
        for elem in hijos{
            
            switch(elem._tipoelemento){
            case "plantilla": break
            case "pagina": break
            case "espacio":
                ConfigurationManager.shared.utilities.writeLogger("Espacio: \(elem._idelemento)", .format)
                let espaciorow = EspacioRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                espaciorow.cell.formDelegate = self
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "espacio", kind: espaciorow, element: espaciorow.cell.elemento))
                
                if section == nil{ formulario +++ espaciorow }else{ section?.append(espaciorow) }
                
                break;
            case "texto":
                ConfigurationManager.shared.utilities.writeLogger("Texto: \(elem._idelemento)", .format)
                let textorow = TextoRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }

                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_texto)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_texto)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                // Eventos
                textorow.cell.formDelegate = self
                textorow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "texto", kind: textorow, element: textorow.cell.elemento))
                
                if section == nil{ formulario +++ textorow }else{ section?.append(textorow) }
                
                break
            case "textarea":
                ConfigurationManager.shared.utilities.writeLogger("TextArea: \(elem._idelemento)", .format)
                let textoarearow = TextoAreaRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_textarea)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_textarea)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                textoarearow.cell.formDelegate = self
                textoarearow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "textarea", kind: textoarearow, element: textoarearow.cell.elemento))

                if section == nil{ formulario +++ textoarearow }else{ section?.append(textoarearow) }
                
                break
            case "boton":
                ConfigurationManager.shared.utilities.writeLogger("Boton: \(elem._idelemento)", .format)
                let botonrow = BotonRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_boton)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_boton)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                botonrow.cell.formDelegate = self
                botonrow.cell.estiloBotones = atributosPlantilla?.estilobotonesboton ?? ""
                botonrow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "boton", kind: botonrow, element: elem))

                if section == nil{ formulario +++ botonrow }else{ section?.append(botonrow) }
                
                break
            case "fecha":
                ConfigurationManager.shared.utilities.writeLogger("Fecha: \(elem._idelemento)", .format)
                let fecharow = FechaRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_fecha)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_fecha)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                fecharow.cell.formDelegate = self
                fecharow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "fecha", kind: fecharow, element: fecharow.cell.elemento))
                
                if section == nil{ formulario +++ fecharow }else{ section?.append(fecharow) }
                
                break
           
            case "leyenda":
                ConfigurationManager.shared.utilities.writeLogger("Leyenda: \(elem._idelemento)", .format)
                let leyendarow = EtiquetaRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_leyenda)?.visible = atributosSeccion?.visible ?? false
                }
                
                leyendarow.cell.formDelegate = self
                leyendarow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "leyenda", kind: leyendarow, element: leyendarow.cell.elemento))

                if section == nil{ formulario +++ leyendarow }else{ section?.append(leyendarow) }
                
                break
                
            case "hora":
                ConfigurationManager.shared.utilities.writeLogger("Hora: \(elem._idelemento)", .format)
                let horarow = FechaRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_hora)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_hora)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                horarow.cell.formDelegate = self
                horarow.cell.setObjectHora(obj: elem)
                               
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "hora", kind: horarow, element: horarow.cell.elemento))

                if section == nil{ formulario +++ horarow }else{ section?.append(horarow) }
                               
                break
            case "lista":
                ConfigurationManager.shared.utilities.writeLogger("Lista: \(elem._idelemento)", .format)
                guard let atributos = elem.atributos as? Atributos_lista else{ continue }
            
                let listarow = ListaRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                let catalogos = ConfigurationManager.shared.utilities.getCatalogoInLibrary(atributos.catalogoorigen)
                self.filtrosArray = Array<String>()
                filtrosArray = atributos.filtrarcatalogo.idfiltrados.split{$0 == ","}.map(String.init)
                    
                if catalogos?.Catalogo.count ?? 0 > 0
                {   for catalogo in catalogos!.Catalogo
                    {   if atributos.filtrarcatalogo.filtrar
                        {   if filtrosArray!.count > 0 {
                                var isFiltered = false
                                for filtro in filtrosArray! {
                                    if String(catalogo.CatalogoId) == filtro { isFiltered = true }
                                }
                                if !isFiltered { continue }
                            }
                        }
                        
                        if catalogo.Activo == 0 { continue }
                        listarow.cell.catalogoItems.append(catalogo)
                        if atributos.tipolista == "combo" {
                            let item = "\(catalogo.Descripcion)|\(String(catalogo.CatalogoId))"
                            listarow.cell.listItemsLista.append(item)
                        }
                    }
                }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_lista)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_lista)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                listarow.cell.formDelegate = self
                listarow.cell.setObject(obj: elem)
                
                if catalogos == nil{
                    listarow.cell.setMessage("nvapla_catalog_nodata".langlocalized(), .error)
                    listarow.cell.setHabilitado(false)
                }
                
                if section == nil{ formulario +++ listarow }else{ section?.append(listarow) }
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "lista", kind: listarow, element: listarow.cell.elemento))
                break
                
            case "comboboxtemporal":
                ConfigurationManager.shared.utilities.writeLogger("Combobox Temporal: \(elem._idelemento)", .format)
                guard (elem.atributos as? Atributos_listatemporal) != nil else{ continue }
                let seccionRowButton = ListaTemporalRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_listatemporal)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_listatemporal)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                seccionRowButton.cell.formDelegate = self
                seccionRowButton.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "comboboxtemporal", kind: seccionRowButton, element: seccionRowButton.cell.elemento))
                
                if section == nil{ formulario +++ seccionRowButton }else{ section?.append(seccionRowButton) }
                
                break
            case "combodinamico":
                ConfigurationManager.shared.utilities.writeLogger("Combo Dinamico: \(elem._idelemento)", .format)
             if plist.idportal.rawValue.dataI() >= 40 {
                guard (elem.atributos as? Atributos_comboDinamico) != nil else{ continue }
                
                let seccionRowButton = ComboDinamicoRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_comboDinamico)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_comboDinamico)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                seccionRowButton.cell.formDelegate = self
                seccionRowButton.cell.setObject(obj: elem)
                
                let camposfiltros = (elem.atributos as? Atributos_comboDinamico)?.camposfiltros.first
                camposfiltros?.forEach{ val in
                    let idelementFiltro = val.value as? String ?? ""
                    let valRow = self.valueMetaElementRow(idelementFiltro, nil)
                    switch valRow.row {
                    case is TextoRow:
                        let comboRow = (valRow.row as! TextoRow)
                        var isIn = false
                        for filtro in comboRow.cell.filtroCombo{
                            if filtro.row.tag == comboRow.tag ?? ""{ isIn = true }
                        }
                        if !isIn{ comboRow.cell.filtroCombo.append((id: valRow.row.tag ?? "", row: seccionRowButton)) }
                        break;
                    case is ComboDinamicoRow:
                        let comboRow = (valRow.row as! ComboDinamicoRow)
                        var isIn = false
                        for filtro in comboRow.cell.filtroCombo{
                            if filtro.row.tag == comboRow.tag ?? ""{ isIn = true }
                        }
                        if !isIn{ comboRow.cell.filtroCombo.append((id: valRow.row.tag ?? "", row: seccionRowButton)) }
                    default: break;
                    }
                }
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "combodinamico", kind: seccionRowButton, element: seccionRowButton.cell.elemento))
                
                if section == nil{ formulario +++ seccionRowButton }else{ section?.append(seccionRowButton) }
             }
                break
            case "logico":
                ConfigurationManager.shared.utilities.writeLogger("Logico: \(elem._idelemento)", .format)
                let logicorow = LogicoRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_logico)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_logico)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                logicorow.cell.formDelegate = self
                logicorow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "logico", kind: logicorow, element: logicorow.cell.elemento))
                
                if section == nil{ formulario +++ logicorow }else{ section?.append(logicorow) }
                
                break
                
            case "deslizante":
                ConfigurationManager.shared.utilities.writeLogger("Deslizante: \(elem._idelemento)", .format)
                let sliderRow = SliderNewRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_Slider)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_Slider)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                sliderRow.cell.formDelegate = self
                sliderRow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "deslizante", kind: sliderRow, element: sliderRow.cell.elemento))
                
                if section == nil{ formulario +++ sliderRow }else{ section?.append(sliderRow) }
                
                break
            case "logo":
                ConfigurationManager.shared.utilities.writeLogger("Logo: \(elem._idelemento)", .format)
                let logorow = LogoRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_logo)?.visible = atributosSeccion?.visible ?? false
                }
                
                logorow.cell.formDelegate = self
                logorow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "logo", kind: logorow, element: logorow.cell.elemento))
                
                if section == nil{ formulario +++ logorow }else{ section?.append(logorow) }
                
                break
            case "moneda":
                ConfigurationManager.shared.utilities.writeLogger("Moneda: \(elem._idelemento)", .format)
                let monedarow = MonedaRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_moneda)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_moneda)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                monedarow.cell.formDelegate = self
                monedarow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "moneda", kind: monedarow, element: monedarow.cell.elemento))
                
                if section == nil{ formulario +++ monedarow }else{ section?.append(monedarow) }
                
                break
            case "numero":
                ConfigurationManager.shared.utilities.writeLogger("Numero: \(elem._idelemento)", .format)
                let numerorow = NumeroRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_numero)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_numero)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                numerorow.cell.formDelegate = self
                numerorow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "numero", kind: numerorow, element: numerorow.cell.elemento))
                
                if section == nil{ formulario +++ numerorow }else{ section?.append(numerorow) }
                
                break
            case "password":
                ConfigurationManager.shared.utilities.writeLogger("Password: \(elem._idelemento)", .format)
                let passwordrow = TextoRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_password)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_password)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                passwordrow.cell.formDelegate = self
                passwordrow.cell.setObjectPassword(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "password", kind: passwordrow, element: passwordrow.cell.elemento))
                
                if section == nil{ formulario +++ passwordrow }else{ section?.append(passwordrow) }
                
                break
            case "rangofechas":
                ConfigurationManager.shared.utilities.writeLogger("Rangofechas: \(elem._idelemento)", .format)
                let rangofechasrow = RangoFechasRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_rangofechas)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_rangofechas)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                rangofechasrow.cell.formDelegate = self
                rangofechasrow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "rangofechas", kind: rangofechasrow, element: rangofechasrow.cell.elemento))
                
                if section == nil{ formulario +++ rangofechasrow }else{ section?.append(rangofechasrow) }
                
                break
            case "seccion":
                ConfigurationManager.shared.utilities.writeLogger("Seccion: \(elem._idelemento)", .format)
                guard let atributos = elem.atributos as? Atributos_seccion else{ continue }
                
                let header = HeaderRow("\(elem._idelemento)"){ row in
                    }.cellSetup({ (cell, row) in
                        cell.formDelegate = self
                        cell.setObject(obj: elem, title: "\(atributos.titulo)", isSctHeader: true)
                    })
                
                
                if section == nil{ formulario +++ header }else{ section?.append(header) }
              
                var arraySections = [(id:String, attributes: Atributos_seccion, elements: [String])]()
                let arrayIdsInSection = [String]()
                
                    if elem.elementos != nil{
                        if section == nil{
                            self.printElemento(hijos: (elem.elementos?.elemento)!, formulario: formulario, section: nil, isRoot: false, atributosGlobales: atributosGlobales, atributosSeccion: nil)
                        }else{
                            self.printElemento(hijos: (elem.elementos?.elemento)!, formulario: formulario, section: section, isRoot: false, atributosGlobales: atributosGlobales, atributosSeccion: atributos)
                        }
                        arraySections.append((elem._idelemento, atributos, self.loopElement(elem, arrayIdsInSection)!))
                    }
                    
                
                    let footer = HeaderRow("\(elem._idelemento)-f"){ row in
                        }.cellSetup({ (cell, row) in cell.setObject(obj: elem, title: "Finaliza: \(atributos.titulo)", isSctHeader: false) })
                    footer.cell.formDelegate = self
                    
                    if section == nil{ formulario +++ footer }else{ section?.append(footer) }
                    
                    header.cell.setElements(arraySections)
                 
             
                break
            case "tabber":
                ConfigurationManager.shared.utilities.writeLogger("Tabber: \(elem._idelemento)", .format)
                if elem.elementos?.elemento == nil{ continue }
                
                let tabberrow = HeaderTabRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                tabberrow.cell.formDelegate = self
                formulario +++ tabberrow
                
                var arraySections = [(id:String, attributes: Atributos_seccion, elements: [String])]()
                
                for secc in (elem.elementos?.elemento)!{
                    guard let _ = secc.atributos as? Atributos_seccion else{ continue }
                    
                    let header = HeaderRow("\(secc._idelemento)"){ row in
                    }.cellSetup({ (cell, row) in
                        cell.formDelegate = self
                        cell.setObjectTab(obj: secc, isTab: true)
                    })
                    
                    let arrayIdsInSection = [String]()
                    let sect = Section()
                    sect.tag = "\(secc._idelemento)_tab"
                    formulario +++ header
                    
                    if secc.elementos != nil{
                        printElemento(hijos: (secc.elementos?.elemento)!, formulario: formulario, section: sect, isRoot: false, atributosGlobales: atributosGlobales)
                        let sectAttributes = secc.atributos as! Atributos_seccion
                        arraySections.append((secc._idelemento, sectAttributes, loopElement(secc, arrayIdsInSection)!))
                    }
                    formulario +++ sect
                }
                tabberrow.cell.setObject(obj: elem, arraySections)
                break
            case "wizard":
                ConfigurationManager.shared.utilities.writeLogger("Wizard: \(elem._idelemento)", .format)
                let wizardrow = WizardRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_wizard)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_wizard)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                wizardrow.cell.formDelegate = self
                
                
                if isFooter ?? false{
                    var navegacion: [String] = []
                    for nav in xmlAEXML.root["elementos"]["elemento"].all(withAttributes: ["tipoelemento" : "footer"])![0]["elementos"]["elemento"].all(withAttributes: ["idelemento" : "\(elem._idelemento)"])![0]["atributos"]["navegacion"].children{
                        navegacion.append(nav.name)
                    }
                    (elem.atributos as? Atributos_wizard)?.navegacion = navegacion
                    wizardrow.cell.setFooterOption(obj: elem)
                }else{
                    wizardrow.cell.setObject(obj: elem)
                }
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "wizard", kind: wizardrow, element: wizardrow.cell.elemento))
                
                if section == nil{ formulario +++ wizardrow }else{ section?.append(wizardrow) }
                
                break
            case "tabla":
                ConfigurationManager.shared.utilities.writeLogger("Tabla: \(elem._idelemento)", .format)
                guard let atributos = elem.atributos as? Atributos_tabla else{ continue }
                
                let form = printPagina()
                let idSection = Section()
                idSection.tag = "InnerForm-\(elem._idelemento)"
                form +++ idSection
                
                if elem.elementos != nil{ printElemento(hijos: (elem.elementos?.elemento)!, formulario: form, section: nil, isRoot: false, atributosGlobales: atributosGlobales) }
                
                sectionsDictionary["\(atributos.titulo)"] = form
                
                let tablaRowButton = TablaRow("\(elem._idelemento)") { $0.value = elem._idelemento }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_tabla)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_tabla)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                tablaRowButton.cell.formDelegate = self
                tablaRowButton.cell.setObject(obj: elem, hijos: form)
                
                if elem.elementos?.elemento != nil{ tablaRowButton.cell.setElements((elem.elementos?.elemento)!) }
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "tabla", kind: tablaRowButton, element: tablaRowButton.cell.elemento))
                
                if section == nil{ formulario +++ tablaRowButton }else{ section?.append(tablaRowButton) }
                
                break
            case "marcadodocumentos":
                ConfigurationManager.shared.utilities.writeLogger("Marcado Documentos: \(elem._idelemento)", .format)
             if plist.idportal.rawValue.dataI() >= 41 {
                guard let atributos = elem.atributos as? Atributos_marcadodocumentos else { continue }
                let form = printPagina()
                
                var listarow: SelectableSection<ListCheckRow<String>>?
                listarow = SelectableSection<ListCheckRow<String>>(nil, selectionType: .singleSelection(enableDeselection: true))
                form +++ listarow!
                
                let seccionRowButton = MarcadoDocumentoRow("\(elem._idelemento)")
                { row in
                    row.validationOptions = .validatesOnChange
                    row.customController?.row = row
                    row.presentationMode = .show(controllerProvider: .callback(builder: {
                        row.updateCell()
                        return row.customController!
                    }), onDismiss:{ vc in
                        vc.dismiss(animated: true)
                    })
                }
                if atributos.catalogoorigen == "9999"
                {
                    let listTipoDoc = ConfigurationManager.shared.plantillaDataUIAppDelegate.ListTipoDoc
                    for listTD in listTipoDoc
                    {
                        let dataListTD = listTD as FEListTipoDoc
                        if (atributos.filtrarcatalogo["filtrar"] as? String ?? "") == "true" && (atributos.filtrarcatalogo["idfiltrados"] as? String ?? "") != ""
                        {
                            var isFiltered = false
                            let filtrados = (atributos.filtrarcatalogo["idfiltrados"] as? String ?? "").split(separator: ",")
                            for filtro in filtrados {
                                if String(dataListTD.CatalogoId) == filtro { isFiltered = true }
                            }
                            if !isFiltered{ continue }
                        }
                        seccionRowButton.cell.catOptionCheck2.append(listTD)
                    }
                    if listTipoDoc.isEmpty{
                        seccionRowButton.cell.setMessage("nvapla_catalog_nodata".langlocalized(), .error)
                        seccionRowButton.cell.setHabilitado(false)
                    }
                } else
                {
                    let catalogos = ConfigurationManager.shared.utilities.getCatalogoInLibrary(atributos.catalogoorigen)
                    if catalogos?.Catalogo.count ?? 0 > 0
                    {
                        for catalogo in catalogos!.Catalogo
                        {
                            var isFiltered = false
                            let filtrados = (atributos.filtrarcatalogo["idfiltrados"] as? String ?? "").split(separator: ",")
                            for filtro in filtrados {
                                if String(catalogo.CatalogoId) == filtro{ isFiltered = true }
                            }
                            if !isFiltered{ continue }
                        
                            if catalogo.Activo == 0 { continue }
                            
                            seccionRowButton.cell.catOptionCheck.append(catalogo)
                        }
                    }
                    if catalogos == nil{
                        seccionRowButton.cell.setMessage("nvapla_catalog_nodata".langlocalized(), .error)
                        seccionRowButton.cell.setHabilitado(false)
                    }
                }
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_marcadodocumentos)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_marcadodocumentos)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                if atributos.elementodocumento.first as? String ?? "" != "" {
                    auxMarcadoDoct.append("\(elem._idelemento)|\(atributos.elementodocumento.first as? String ?? "")") }
                seccionRowButton.customController?.row = seccionRowButton
                seccionRowButton.customController?.initForm(form)
                seccionRowButton.cell.formDelegate = self
                seccionRowButton.cell.setObject(obj: elem)
                
                if section == nil{ formulario +++ seccionRowButton }else{ section?.append(seccionRowButton) }
                seccionRowButton.cell.setEdited(v: "--Seleccione--", isRobot: false)
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "marcadodocumentos", kind: seccionRowButton, element: seccionRowButton.cell.elemento))
              }
                break
            case "calculadorafinanciera":
                ConfigurationManager.shared.utilities.writeLogger("Calculadora Financiera: \(elem._idelemento)", .format)
                if plist.idportal.rawValue.dataI() >= 39{
                        let calculadoraRow = CalculadoraRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                    
                        // Modifying Attribute visibility and Enable
                        if atributosSeccion != nil{
                            (elem.atributos as? Atributos_calculadora)?.visible = atributosSeccion?.visible ?? false
                            (elem.atributos as? Atributos_calculadora)?.habilitado = atributosSeccion?.habilitado ?? false
                        }
                        
                        calculadoraRow.cell.formDelegate = self
                        calculadoraRow.cell.setObject(obj: elem)
                    
                        FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "calculadorafinanciera", kind: calculadoraRow, element: calculadoraRow.cell.elemento))

                        if section == nil{ formulario +++ calculadoraRow }else{ section?.append(calculadoraRow) }
                    
                        break
                }
            case "codigobarras":
                ConfigurationManager.shared.utilities.writeLogger("Codigo de Barras: \(elem._idelemento)", .format)
                let codigobarrasrow = CodigoBarrasRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_codigobarras)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_codigobarras)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                codigobarrasrow.cell.formDelegate = self
                codigobarrasrow.cell.estiloBotones = atributosPlantilla?.estilobotonescodigobarras ?? ""
                codigobarrasrow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "codigobarras", kind: codigobarrasrow, element: codigobarrasrow.cell.elemento))
                
                if section == nil{ formulario +++ codigobarrasrow }else{ section?.append(codigobarrasrow) }
                
                break
            case "codigoqr":
                ConfigurationManager.shared.utilities.writeLogger("Codigo QR: \(elem._idelemento)", .format)
             if plist.idportal.rawValue.dataI() >= 39 {
                let codigoqrrow = CodigoQRRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_codigoqr)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_codigoqr)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                codigoqrrow.cell.formDelegate = self
                codigoqrrow.cell.estiloBotones = atributosPlantilla?.estilobotonescodigoqr ?? ""
                codigoqrrow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "codigoqr", kind: codigoqrrow, element: codigoqrrow.cell.elemento))
                
                if section == nil{ formulario +++ codigoqrrow }else{ section?.append(codigoqrrow) }
              }
                break
            case "nfc":
                ConfigurationManager.shared.utilities.writeLogger("NFC: \(elem._idelemento)", .format)
             if plist.idportal.rawValue.dataI() >= 39 {
                let nfcrow = EscanerNFCRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_escanerNFC)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_escanerNFC)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                nfcrow.cell.formDelegate = self
                nfcrow.cell.setObject(obj: elem)
                
               if #available(iOS 11.0, *) { } else {
                nfcrow.cell.setMessage("nvapla_nfc_warning".langlocalized(), .error)
                    nfcrow.cell.setHabilitado(false)
                }
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "nfc", kind: nfcrow, element: nfcrow.cell.elemento))
                
                if section == nil{ formulario +++ nfcrow }else{ section?.append(nfcrow) }
              }
                break
            case "audio", "voz":
                ConfigurationManager.shared.utilities.writeLogger("Audio: \(elem._idelemento)", .format)
                let audiorow = AudioRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_audio)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_audio)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                audiorow.cell.formDelegate = self
                audiorow.cell.estiloBotones = atributosPlantilla?.estilobotonesaudio ?? ""
                audiorow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "audio", kind: audiorow, element: audiorow.cell.elemento))
                
                
                if section == nil{ formulario +++ audiorow }else{ section?.append(audiorow) }
                
                break
            case "firma":
                ConfigurationManager.shared.utilities.writeLogger("Firma: \(elem._idelemento)", .format)
                let firmarow = FirmaRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_firma)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_firma)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                firmarow.cell.formDelegate = self
                firmarow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "firma", kind: firmarow, element: firmarow.cell.elemento))
                
                if section == nil{ formulario +++ firmarow }else{ section?.append(firmarow) }
                
                break
            case "firmafad":
                ConfigurationManager.shared.utilities.writeLogger("Firma FAD: \(elem._idelemento)", .format)
                if plist.idportal.rawValue.dataI() >= 39{
                    let firmafadrow = FirmaFadRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                    
                    // Modifying Attribute visibility and Enable
                    if atributosSeccion != nil{
                        (elem.atributos as? Atributos_firma)?.visible = atributosSeccion?.visible ?? false
                        (elem.atributos as? Atributos_firma)?.habilitado = atributosSeccion?.habilitado ?? false
                    }
                    
                    firmafadrow.cell.formDelegate = self
                    firmafadrow.cell.setObject(obj: elem)
                    
                    FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "firmafad", kind: firmafadrow, element: firmafadrow.cell.elemento))
                    
                    if section == nil{ formulario +++ firmafadrow }else{ section?.append(firmafadrow) }
                    
                    break
                }
            case "georeferencia":
                ConfigurationManager.shared.utilities.writeLogger("Georeferencia: \(elem._idelemento)", .format)
                let maparow = MapaRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_georeferencia)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_georeferencia)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                maparow.cell.formDelegate = self
                maparow.cell.setObjectGeolocalizacion(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "georeferencia", kind: maparow, element: maparow.cell.elemento))
                
                if section == nil{ formulario +++ maparow }else{ section?.append(maparow) }
                
                break
            case "mapa":
                ConfigurationManager.shared.utilities.writeLogger("Mapa: \(elem._idelemento)", .format)
                let maparow = MapaRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_mapa)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_mapa)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                maparow.cell.formDelegate = self
                maparow.cell.setObjectMapa(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "mapa", kind: maparow, element: maparow.cell.elemento))
                
                if section == nil{ formulario +++ maparow }else{ section?.append(maparow) }

                break
            case "imagen":
                ConfigurationManager.shared.utilities.writeLogger("Imagen: \(elem._idelemento)", .format)
                let imagenrow = ImagenRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_imagen)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_imagen)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                imagenrow.cell.formDelegate = self
                imagenrow.cell.estiloBotones = atributosPlantilla?.estilobotonesimagen ?? ""
                imagenrow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "imagen", kind: imagenrow, element: imagenrow.cell.elemento))
                
                if section == nil{ formulario +++ imagenrow }else{ section?.append(imagenrow) }
                
                break
                
            case "video":
                ConfigurationManager.shared.utilities.writeLogger("Video: \(elem._idelemento)", .format)
                let videorow = VideoRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_video)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_video)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                videorow.cell.formDelegate = self
                videorow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "video", kind: videorow, element: videorow.cell.elemento))
                
                if section == nil{ formulario +++ videorow }else{ section?.append(videorow) }
                
                break
                
            case "pdfocr":
                ConfigurationManager.shared.utilities.writeLogger("PDFOCR: \(elem._idelemento)", .format)
                let pdfOCRRow = DocFormRow("\(elem._idelemento)") { row in
                    row.validationOptions = .validatesOnChange
                }
                
                if atributosSeccion != nil {
                    (elem.atributos as? Atributos_PDFOCR)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_PDFOCR)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                pdfOCRRow.cell.formDelegate = self
                pdfOCRRow.cell.setObject(object: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: "\(elem._idelemento)", type: "pdfocr", kind: pdfOCRRow, element: pdfOCRRow.cell.elemento))
                if section == nil {
                    formulario +++ pdfOCRRow
                } else {
                    section?.append(pdfOCRRow)
                }
                break
            case "documento":
                ConfigurationManager.shared.utilities.writeLogger("Documento: \(elem._idelemento)", .format)
                let documentorow = DocumentoRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_documento)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_documento)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                documentorow.cell.formDelegate = self
                documentorow.cell.setObject(obj: elem)
                if !auxMarcadoDoct.isEmpty
                {   for marcado in auxMarcadoDoct
                    {   if String(marcado.split(separator: "|")[1]) == "\(elem._idelemento)"
                        {   documentorow.cell.isMarcado = String(marcado.split(separator: "|")[0])   }
                    }
                }
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "documento", kind: documentorow, element: documentorow.cell.elemento))
                
                if section == nil{ formulario +++ documentorow }else{ section?.append(documentorow) }
                
                break
            case "metodo":
                ConfigurationManager.shared.utilities.writeLogger("Metodo: \(elem._idelemento)", .format)
                let metodorow = MetodoRow("\(elem._idelemento)"){ row in }
                
                metodorow.cell.formDelegate = self
                metodorow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "metodo", kind: metodorow, element: metodorow.cell.elemento))
                
                if section == nil{ formulario +++ metodorow }else{ section?.append(metodorow) }
                
                break
            case "servicio":
                ConfigurationManager.shared.utilities.writeLogger("Servicio: \(elem._idelemento)", .format)
                let serviciorow = ServicioRow("\(elem._idelemento)"){ row in }
                
                serviciorow.cell.formDelegate = self
                serviciorow.cell.setObject(obj: elem)
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "servicio", kind: serviciorow, element: serviciorow.cell.elemento))
                
                if section == nil{ formulario +++ serviciorow }else{ section?.append(serviciorow) }
                
                break
            case "ocr":
                ConfigurationManager.shared.utilities.writeLogger("DocumentoVeridasOcr: \(elem._idelemento)", .format)
                
                let documentorow = VeridasDocumentOcrRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_OCR)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_OCR)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                documentorow.cell.formDelegate = self
                documentorow.cell.setObject(obj: elem)
               
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "ocr", kind: documentorow, element: documentorow.cell.elemento))
                
                if section == nil{ formulario +++ documentorow }else{ section?.append(documentorow) }
                    break
            case "jumio":
                ConfigurationManager.shared.utilities.writeLogger("JumioDocumentoOcr: \(elem._idelemento)", .format)
                
                let jumiorow = JUMIODocumentOcrRow("\(elem._idelemento)") { row in
                    row.validationOptions = .validatesOnChange
                }
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_OCR)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_OCR)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                jumiorow.cell.formDelegate = self
                jumiorow.cell.setObject(obj: elem)
               
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "jumio", kind: jumiorow, element: jumiorow.cell.elemento))
                
                if section == nil{ formulario +++ jumiorow }else{ section?.append(jumiorow) }
                
                break
            case "huelladigital":
                ConfigurationManager.shared.utilities.writeLogger("Huella Digital: \(elem._idelemento)", .format)
                //if NSClassFromString("VeridiumRow") == nil { break }
                let veridiumRow = VeridiumRow("\(elem._idelemento)") { row in row.validationOptions = .validatesOnChange }
                
                // Modifying Attribute visibility and Enable
                if atributosSeccion != nil{
                    (elem.atributos as? Atributos_huelladigital)?.visible = atributosSeccion?.visible ?? false
                    (elem.atributos as? Atributos_huelladigital)?.habilitado = atributosSeccion?.habilitado ?? false
                }
                
                veridiumRow.cell.formDelegate = self
                veridiumRow.cell.setObject(obj: elem)
                
                FormularioUtilities.shared.elementsInPlantilla.append((id: elem._idelemento, type: "huelladigital", kind: veridiumRow, element: veridiumRow.cell.elemento))
                
                if section == nil{ formulario +++ veridiumRow }else{ section?.append(veridiumRow) }
                break
            case "eventos":
                ConfigurationManager.shared.utilities.writeLogger("Eventos: \(elem._idelemento)", .format)
                break
            case "semaforotiempo":
                ConfigurationManager.shared.utilities.writeLogger("Semaforo Tiempo: \(elem._idelemento)", .format)
                break
            default:
                ConfigurationManager.shared.utilities.writeLogger("Elemento no encontrado: \(elem._idelemento) \(elem._tipoelemento)", .format)
                break
            }
            
            allIndex += 1
        }
    }
    
}

