//
//  ResolveRows.swift
//  DIGIPROSDKUI
//
//  Created by Jonathan Viloria M on 24/10/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation
import Eureka

public enum RowAction: String{
    case value = "value"
    
    var label:String? {
        let mirror = Mirror(reflecting: self)
        return mirror.children.first?.label
    }
}

public class UnknownClass{}

/*public enum RowKind: String {
    
    // DIGIPROSDK
    case eventos = "eventos"
    case plantilla
    case pagina
    case seccion
    // DIGIPROSDKSO
    case boton
    case comboboxtemporal
    case combodinamico
    case deslizante
    case espacio
    case fecha
    case hora
    case leyenda
    case lista
    case logico
    case logo
    case moneda
    case numero
    case password
    case rangofechas
    case semaforotiempo
    case tabber
    case tabla
    case ETextoRow = "ETextoRow"
    case textarea
    case wizard
    case metodo
    case servicio
    case marcadodocumentos
    // DIGIPROSDKATO
    case audio
    case calculadora
    case codigobarras
    case codigoqr
    case nfc
    case firma
    case firmafad
    case georeferencia
    case imagen
    case mapa
    case video
    case videollamada
    case voz
    case documento
    // DIGIPROSDKVO
    case huelladigital
    // DIGIPROSDKFO
    case rostrovivo
    case capturafacial

    case other
    
    public var klass: AnyClass {
        switch self {
        case .eventos: return UnknownClass.self
        case .plantilla: return PlantillaRow.self
        case .pagina: return PaginaRow.self
        case .seccion: return HeaderRow.self
        case .boton: return BotonRow.self
        case .comboboxtemporal: return ListaTemporalRow.self
        case .combodinamico: return ComboDinamicoRow.self
        case .deslizante: return SliderRow.self
        case .espacio: return EspacioRow.self
        case .fecha: return FechaRow.self
        case .hora: return FechaRow.self
        case .leyenda: return EtiquetaRow.self
        case .lista: return ListaRow.self
        case .logico: return LogicoRow.self
        case .logo: return LogoRow.self
        case .moneda: return MonedaRow.self
        case .numero: return NumeroRow.self
        case .password: return TextoRow.self
        case .rangofechas: return RangoFechasRow.self
        case .semaforotiempo: return UnknownClass.self
        case .tabber: return HeaderTabRow.self
        case .tabla: return TablaRow.self
        case .ETextoRow: return TextoRow.self
        case .textarea: return TextoAreaRow.self
        case .wizard: return WizardRow.self
        case .metodo: return MetodoRow.self
        case .servicio: return ServicioRow.self
        case .marcadodocumentos: return MarcadoDocumentoRow.self
        case .audio: return AudioRow.self
        case .calculadora: return CalculadoraRow.self
        case .codigobarras: return CodigoBarrasRow.self
        case .codigoqr: return CodigoQRRow.self
        case .nfc: return EscanerNFCRow.self
        case .firma: return FirmaRow.self
        case .firmafad: return FirmaFadRow.self
        case .georeferencia: return MapaRow.self
        case .imagen: return ImagenRow.self
        case .mapa: return MapaRow.self
        case .video: return VideoRow.self
        case .videollamada: return UnknownClass.self
        case .voz: return AudioRow.self
        case .documento: return DocumentoRow.self
        case .huelladigital: return VeridiumRow.self
        case .rostrovivo: return RostroRow.self
        case .capturafacial: return RostroRow.self
        case .other: return UnknownClass.self
        }
    }
}

extension NuevaPlantillaViewController{
    public func getElementRow( action typedAction: RowAction, element rowElement: String) -> Any?{
        
        let row = self.getElementByIdInAllForms("\(rowElement)")
        let classRow = RowKind(rawValue: row.debugDescription)
        switch typedAction{
        
        case .value:
            break;
        }
        
        return nil
    }
}*/
