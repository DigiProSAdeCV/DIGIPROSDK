//
//  Atributos_plantilla.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 25/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class Atributos_plantilla: Atributos_Generales
{
    public var anchocapturador: String = ""
    public var bindcondition: Bool = false
    public var bordeelementos: Bool = false
    public var colorbordeplantilla: String = ""
    public var colorcancelarplantilla: String = ""
    public var colorcancelartextoplantilla: String = ""
    public var colorguardarplantilla: String = ""
    public var colorguardartextoplantilla: String = ""
    public var colortabactivo: String = ""
    public var colortabinhabilitado: String = ""
    public var colortabnormal: String = ""
    public var colortabtextoactivo: String = ""
    public var colortabtextoinhabilitado: String = ""
    public var colortabtextonormal: String = ""
    public var coordenadasplantilla: String = ""

    public var colorfondoalertaadvertencia: String = "#FFD500"
    public var colorfondoalertaerror: String = ""
    public var colorfondoalertaexito: String = "#68B848"
    public var colorfondoalertainfo: String = "#3C3CCC"
    public var colorfondoerrorelemento: String = "#D93829"
    public var colortextoalertaadvertencia: String = "#FFFFFF"
    public var colortextoalertaerror: String = ""
    public var colortextoalertaexito: String = "#FFFFFF"
    public var colortextoalertainfo: String = "#FFFFFF"
    public var colortextoerrorelemento: String = "#FFFFFF"
    public var colortextosubtitulo: String = ""
    public var colortextotitulo: String = ""
    
    public var elementrendered: Bool = false
    public var eventos: Eventos = Eventos() // "alcargar"
    public var executeonce: Bool = false
    public var fondoplantilla: String = ""
    public var grosorbordeplantilla: String = ""
    public var haserror: Bool = false
    public var ocultarsubtitulo: Bool = false
    public var pdfanterior: String = ""
    public var pdfnombre: String = ""
    public var pdfplantilla: String = ""
    public var pedircoordenadasalcargar: Bool = false
    public var permisoestadisticas: Bool = true
    public var prevalidateall: Bool = false
    public var subtitulo: String = ""
    public var tamanofuente: String = ""
    public var textocancelarplantilla: String = ""
    public var textoguardarplantilla: String = ""
    public var textosalirmensaje: String = ""
    public var textosalirtitulo: String = ""
    public var tiempoautoguardado: Int = 0
    public var tipo: String = "" //"plantilla"
    public var tipofuente: String = ""
    public var usarcoordenadas: String = ""
    public var validaralcargar: Bool = false
    public var verguardar: Bool = false
    public var versalir: Bool = false
    
    ///////////////////////// ESTAN AQUÍ Y NO EN WEB ///////////////////////////////
    public var autoredirectalguardar: Bool = false
    public var ayuda: String = ""
    public var modoguardado: Bool = false
    public var mostrartipodoc: Bool = false
    public var mostrartipoexp: Bool = false
    public var plantillamapearprellenado: String = ""
    public var tablahijo: Bool = false
    
    ///////////////////////// ESTAN EN WEB Y AQUÍ NO///////////////////////////////
    public var components: [String:Any] = [:]
   
    public var operacionesmatematicas: NSArray = []
    public var pagids: [String] = []
    public var prefilleddata: NSArray = []
    public var reglas: [String:Any] = [:]
    public var pdfmapping: [String:Any] = [:]
    
    public var macros: [String:Any] = [:]
    
    public var resumen : String = ""

    public var servicios: [String:Any] = [:]
    
    public var validationerror: String = ""
    public var vertabspaginas: Bool = false
    public var verpieplantilla: Bool = false
    public var verexpres: Bool = false
    public var vertipodocres: Bool = false
    
    public var colorfondoplantilla: String = ""
    public var mapeopdfligar: String = ""
    public var lastupdate: String = ""
    
    public var estilocomandos: String = ""
    public var estilotabs: String = ""
    public var estilobotonesaudio: String = ""
    public var estilobotonesimagen: String = ""
    public var estilobotonesboton: String = ""
    public var estilobotonescodigobarras: String = ""
    public var estilobotonescodigoqr: String = ""
    
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

