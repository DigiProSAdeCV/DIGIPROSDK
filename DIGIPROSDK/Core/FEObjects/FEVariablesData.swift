//
//  FEVariablesData.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 10/23/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class FEVariablesData: EVObject{
    public var AplicacionID = 0
    public var ProyectoID = 0
    public var ListVariables = Array<FEVariableData>()
    public var IP = ""
    public var Password = ""
    public var User = ""
    public var ListLog: Array<FELogError> = [FELogError]()
    public var LogsSincronizados = false
    public var Dispositivo = ""
    public var CfgGeoPosicion = Array<ConfigGeop>();
    public var GeoPosicion = ""
    public var ListCatDocumento = Array<FEVariableData>()
    public var GeoPosicionGuardado = false
    
    
    override public func propertyConverters() -> [(key: String, decodeConverter: ((Any?) -> ()), encodeConverter: (() -> Any?))] {
        return [ ( key: "CfgGeoPosicion"
              , decodeConverter: {
                do{
                    if ($0 as? String) != nil
                    {
                        let auxArray = try JSONSerializer.toArray($0 as! String)
                        var arrayConf = Array<ConfigGeop>()
                        for elementArray in auxArray
                        {   let elementDictionary = elementArray as! NSDictionary//as! NSMutableDictionary
                            arrayConf.append(ConfigGeop.init(dictionary: elementDictionary))//elementDictionary as NSDictionary))
                        }
                        self.CfgGeoPosicion = arrayConf
                    } else if ($0 as! NSArray).count > 0
                    {
                        var arrayConf = Array<ConfigGeop>()
                        for elementArray in ($0 as! NSArray)
                        {   let elementDictionary = elementArray as! NSDictionary//as! NSMutableDictionary
                            arrayConf.append(ConfigGeop.init(dictionary: elementDictionary))//elementDictionary as NSDictionary))
                        }
                        self.CfgGeoPosicion = arrayConf
                    }
                }catch{
                    self.CfgGeoPosicion = Array<ConfigGeop>()
                }
        }
              , encodeConverter: { return self.CfgGeoPosicion }) ]
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

public class ConfigGeop: EVObject
{
    public var Perfil = Array<Int>();
    public var Usuario = Array<String>();
    public var Activo = false
    public var Schedule = Array<scheduleGeop>();
    public var Precision = 0
    
    override public func skipPropertyValue(_ value: Any, key: String) -> Bool
    {
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

public class scheduleGeop: EVObject
{
    public var Dias = Array<Int>();
    public var HoraIni = ""
    public var HoraFin = ""
    public var Frecuencia = 0
    
    override public func skipPropertyValue(_ value: Any, key: String) -> Bool
    {
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
