//
//  BotonPagina.swift
//  DIGIPROSDKUI
//
//  Created by Alberto Echeverri Carrillo on 17/06/21.
//  Copyright © 2021 Jonathan Viloria M. All rights reserved.
//

import UIKit

public enum EstiloBoton: String  {
    case conRelleno = "fondo"
    case sinRelleno = "borde"
    case subrayado = "subrayado"
}

class BotonPagina: UIButton {
    //Se usa para el subrayado si el estilo lo necesita:
    private var lineView: UIView?
    public var estilo: EstiloBoton = .conRelleno
    private var cornerRadius: CGFloat = 3.0
    
    func configurar(estilo: EstiloBoton, titulo: String, color: UIColor, colorTexto: UIColor) {
        self.estilo = estilo
        self.setTitle(titulo, for: .normal)
        
        switch estilo {
        case .conRelleno:
            self.backgroundColor = color
            self.setTitleColor(colorTexto, for: .normal)
            self.layer.cornerRadius = cornerRadius
            break
        case .sinRelleno:
            self.backgroundColor = .white
            self.setTitleColor(colorTexto, for: .normal)
            //Crear border
            self.layer.borderWidth = 2.5
            self.layer.borderColor = color.cgColor
            self.layer.cornerRadius = cornerRadius
            break
        case .subrayado:
            self.backgroundColor = .white
            self.setTitleColor(colorTexto, for: .normal)
            //Crear subrayado
            self.lineView = UIView()
            lineView!.backgroundColor = color
            lineView?.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(lineView!)
            
            lineView!.layer.cornerRadius = cornerRadius
            
            NSLayoutConstraint.activate([
                lineView!.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
                lineView!.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
                lineView!.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
                lineView!.heightAnchor.constraint(equalToConstant: 3)
            ])
            
            break
        }
    }
    
    func aplicarColor(_ color: UIColor, colorTexto: UIColor, estilo: EstiloBoton? = nil) {
        if let estilo = estilo {
            switch estilo {
            case .sinRelleno:
                self.backgroundColor = .white
                self.layer.borderColor = color.cgColor
                self.setTitleColor(colorTexto, for: .normal)
                break
            case .conRelleno:
                self.setTitleColor(colorTexto, for: .normal)
                self.backgroundColor = color
                break
            case .subrayado:
                self.setTitleColor(colorTexto, for: .normal)
                if let line = self.lineView {
                    line.backgroundColor = color
                }
                break
            }
        } 
    }
}

