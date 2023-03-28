//
//  Elemento.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 25/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Elemento: EVObject {
    
    public var versionguardadoplantilla = ""
    public var _fechaguardadoplantilla = ""
    public var _version = ""
    public var __name = ""
    public var _idelemento = ""
    public var _tipoelemento = ""
    public var atributos: Any?
    public var elementos: Elementos?
    public var validacion = Validacion()
    public var estadisticas: FEEstadistica? = nil
    public var estadisticas2: FEEstadistica2? = nil
    
    public override func setValue(_ value: Any!, forUndefinedKey key: String) {
        
        guard let dict = value as? NSDictionary else{
            return
        }
        
        let tipoElemento = TipoElemento(rawValue: "\(_tipoelemento)") ?? TipoElemento.other
        switch tipoElemento {
        
        case .eventos:
            self.atributos = nil
            break;
        case .plantilla:
            self.atributos = Atributos_plantilla(dictionary: dict)
            break;
        case .pagina:
            self.atributos = Atributos_pagina(dictionary: dict)
            break;
        case .seccion:
            self.atributos = Atributos_seccion(dictionary: dict)
            break;
        case .boton:
            self.atributos = Atributos_boton(dictionary: dict)
            break;
        case .codigobarras:
            self.atributos = Atributos_codigobarras(dictionary: dict)
            break;
        case .codigoqr:
            self.atributos = Atributos_codigoqr(dictionary: dict)
            break;
        case .nfc:
            self.atributos = Atributos_escanerNFC(dictionary: dict)
            break;
        case .comboboxtemporal:
            self.atributos = Atributos_listatemporal(dictionary: dict)
            break;
        case .combodinamico:
            self.atributos = Atributos_comboDinamico(dictionary: dict)
            break;
        case .deslizante:
            self.atributos = Atributos_Slider(dictionary: dict)
            break;
        case .espacio:
            self.atributos = Atributos_espacio(dictionary: dict)
            break;
        case .fecha:
            self.atributos = Atributos_fecha(dictionary: dict)
            break;
        case .hora:
            self.atributos = Atributos_hora(dictionary: dict)
            break;
        case .leyenda:
            self.atributos = Atributos_leyenda(dictionary: dict)
            break;
        case .lista:
            self.atributos = Atributos_lista(dictionary: dict)
            break;
        case .logico:
            self.atributos = Atributos_logico(dictionary: dict)
            break;
        case .logo:
            self.atributos = Atributos_logo(dictionary: dict)
            break;
        case .moneda:
            self.atributos = Atributos_moneda(dictionary: dict)
            break;
        case .numero:
            self.atributos = Atributos_numero(dictionary: dict)
            break;
        case .password:
            self.atributos = Atributos_password(dictionary: dict)
            break;
        case .rangofechas:
            self.atributos = Atributos_rangofechas(dictionary: dict)
            break;
        case .semaforotiempo:
            self.atributos = nil
            break;
        case .tabber:
            self.atributos = Atributos_tabber(dictionary: dict)
            break;
        case .tabla:
            self.atributos = Atributos_tabla(dictionary: dict)
            break;
        case .texto:
            self.atributos = Atributos_texto(dictionary: dict)
            break;
        case .textarea:
            self.atributos = Atributos_textarea(dictionary: dict)
            break;
        case .wizard:
            self.atributos = Atributos_wizard(dictionary: dict)
            break;
        case .metodo:
            self.atributos = Atributos_metodo(dictionary: dict)
            break;
        case .servicio:
            self.atributos = Atributos_servicio(dictionary: dict)
            break;
        case .audio, .voz:
            self.atributos = Atributos_audio(dictionary: dict)
            break;
        case .calculadora:
            self.atributos = Atributos_calculadora(dictionary: dict)
            break;
        case .firma:
            self.atributos = Atributos_firma(dictionary: dict)
            break;
        case .firmafad:
            self.atributos = Atributos_firmafad(dictionary: dict)
            break;
        case .georeferencia:
            self.atributos = Atributos_georeferencia(dictionary: dict)
            break;
        case .imagen:
            self.atributos = Atributos_imagen(dictionary: dict)
            break;
        case .pdfocr:
            self.atributos = Atributos_PDFOCR(dictionary: dict)
            break;
        case .mapa:
            self.atributos = Atributos_mapa(dictionary: dict)
            break;
        case .video:
            self.atributos = Atributos_video(dictionary: dict)
            break;
        case .videollamada:
            self.atributos = nil
            break;
        case .huelladigital:
            self.atributos = Atributos_huelladigital(dictionary: dict)
            break;
        case .rostrovivo, .capturafacial:
            self.atributos = Atributos_rostrovivo(dictionary: dict)
            break;
        case .documento:
            self.atributos = Atributos_documento(dictionary: dict)
        case .marcadodocumentos:
            self.atributos = Atributos_marcadodocumentos(dictionary: dict)
        case .veridasdocumentcapture:
            self.atributos = Atributos_VeridasDocumentCapture(dictionary: dict)
        case .veridasphotoselfie:
             self.atributos = Atributos_VeridasPhotoSelfie(dictionary: dict)
        case .veridasvideoselfie:
            self.atributos = Atributos_VeridasVideoSelfie(dictionary: dict)
        case .ocr:
            self.atributos = Atributos_OCR(dictionary: dict)
        case .jumio:
            self.atributos = AtributosJumio(dictionary: dict)
        case .other:
            self.atributos = nil
            break;

        }
        
    }
    
    override public func skipPropertyValue(_ value: Any, key: String) -> Bool {
        if let value = value as? String, value.count == 0 || value == "null" {
            return true
        } else if let value = value as? NSArray, value.count == 0 {
            return true
        } else if value is NSNull {
            return true
        }
        return false
    }
    
}

public class Elementos: EVObject{
    public var elemento: Array<Elemento> = []
    
    override public func skipPropertyValue(_ value: Any, key: String) -> Bool {
        if let value = value as? String, value.count == 0 || value == "null" {
            return true
        } else if let value = value as? NSArray, value.count == 0 {
            return true
        } else if value is NSNull {
            return true
        }
        return false
    }
}

public class Validacion: EVObject{
    
    public var id = ""
    public var idunico = ""
    public var coordenadasplantilla = ""
    public var docid = ""
    public var habilitado = false
    public var valor = ""
    public var valormetadato = ""
    public var visible = false
    public var needsValidation = false
    public var validado = false
    public var metadatos: String = String();
    public var tipodoc: String = String();
    public var anexos: [(id: String, url: String)]?
    public var feanexo: [FEAnexoData]?
    public var attData: [(catalogoId: Int, descripcion: String)]?
    public var catalogoDestino: String = ""
    public var hashFad: String = ""
    public var guidtimestamp: String = ""
    public var georeferencia: String = ""
    public var fecha: String = ""
    public var dispositivo: String = ""
    public var acuerdofirma: String = ""
    public var personafirma: String = ""
    public var cantidadhuellas = ""
    public var scorepromedio = ""
    public var scorehuellas = ""
    public var isreemplazohuella = ""
    public var valormetadatoinicial: String = ""
    public var valormetadatofinal: String = ""
    public var valormetadatorango: String = ""
    
    override public func skipPropertyValue(_ value: Any, key: String) -> Bool {
        if let value = value as? String, value.count == 0 || value == "null" {
            return true
        } else if let value = value as? NSArray, value.count == 0 {
            return true
        } else if value is NSNull {
            return true
        }
        return false
    }
}
