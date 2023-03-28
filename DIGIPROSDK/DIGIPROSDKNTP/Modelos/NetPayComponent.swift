//
//  NetPayComponent.swift
//  DIGIPROSDKNTP
//
//  Created by Alberto Echeverri Carrillo on 11/05/21.
//

import Foundation

public struct NetPayComponent {
    public var orden: String
    public var nombre: String
    public var valor: String
    
    public init(orden: String, nombre: String, valor: String) {
        self.orden = orden
        self.nombre = nombre
        self.valor = valor
    }
}
