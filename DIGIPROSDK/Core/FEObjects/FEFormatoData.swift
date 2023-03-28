//
//  FEFormatoData.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 30/07/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FEFormatoData: EVObject{
    public var Guid = ""
    public var GuidPdf = ""
    public var InstanciaId = 0
    public var DocID = 0
    public var ExpID = 0
    public var NombreExpediente = ""
    public var TipoDocID = 0
    public var NombreTipoDoc = ""
    public var EstadoID = 0
    public var NombreEstado = ""
    public var Usuario = ""
    public var FlujoID = 0
    public var NombreFlujo = ""
    public var ProcesoID = 0
    public var NombreProceso = ""
    public var PIID = 0
    public var EstadoApp = 0
    public var CoordenadasFormato = ""
    public var JsonDatos = ""
    public var Xml = ""
    public var Anexos = Array<FEAnexoData>()
    public var AnexosBorrados = Array<String>()
    public var Estadisticas =  Array<FEEstadistica>()
    public var TareaSiguiente = FEEventosFlujo()
    public var Movil = false
    public var Reserva = false
    public var Enviado = false
    public var Borrador = false
    public var porEnviar = false
    public var TipoReemplazo = 0
    public var Accion = 0
    public var Reporte = FEReporteEstadistico()
    public var Resumen = ""
    public var ResumenV2: FEResumenDos = FEResumenDos()
    public var Editado = false
    public var ShowLog = false
    public var ShowLogTransitando = false
    public var ShowLogEnviando = false
    public var ShowLogDownloadAnexos = false
    public var estatusEnvio = 0
    public var estatusTransitando = 0
    public var AnexosDescargados = false
    public var isSelected = false
    public var FechaFormatoLong = 0
    public var FechaFormato = ""
    
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
    
    // MARK:- NSCopying
    convenience required init(_ with: FEFormatoData) {
        self.init()
        
        self.Guid = with.Guid
        self.GuidPdf = with.GuidPdf
        self.InstanciaId = with.InstanciaId
        self.DocID = with.DocID
        self.ExpID = with.ExpID
        self.NombreExpediente = with.NombreExpediente
        self.TipoDocID = with.TipoDocID
        self.NombreTipoDoc = with.NombreTipoDoc
        self.EstadoID = with.EstadoID
        self.NombreEstado = with.NombreEstado
        self.Usuario = with.Usuario
        self.FlujoID = with.FlujoID
        self.NombreFlujo = with.NombreFlujo
        self.ProcesoID = with.ProcesoID
        self.NombreProceso = with.NombreProceso
        self.PIID = with.PIID
        self.EstadoApp = with.EstadoApp
        self.CoordenadasFormato = with.CoordenadasFormato
        self.JsonDatos = with.JsonDatos
        self.Xml = with.Xml
        self.Anexos = with.Anexos
        self.AnexosBorrados = with.AnexosBorrados
        self.Estadisticas =  with.Estadisticas
        self.TareaSiguiente = with.TareaSiguiente
        self.Movil = with.Movil
        self.Reserva = with.Reserva
        self.Enviado = with.Enviado
        self.Borrador = with.Borrador
        self.porEnviar = with.porEnviar
        self.TipoReemplazo = with.TipoReemplazo
        self.Accion = with.Accion
        self.Resumen = with.Resumen
        self.ResumenV2 = with.ResumenV2
        self.Reporte = with.Reporte
        self.Editado = with.Editado
        self.ShowLog = with.ShowLog
        self.ShowLogTransitando = with.ShowLogTransitando
        self.ShowLogEnviando = with.ShowLogEnviando
        self.ShowLogDownloadAnexos = with.ShowLogDownloadAnexos
        self.estatusEnvio = with.estatusEnvio
        self.estatusTransitando = with.estatusTransitando
        self.AnexosDescargados = with.AnexosDescargados
        self.isSelected = with.isSelected
        self.FechaFormatoLong = with.FechaFormatoLong
        self.FechaFormato = with.FechaFormato
    }

    func copy(with zone: NSZone? = nil) -> Any
    {
        return type(of:self).init(self)
    }

}
