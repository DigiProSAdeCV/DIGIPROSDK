//
//  FEDocumentCalculadora.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 17/03/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEDocumentCalculadora: EVObject
{
    public var documentId: String = ""
    public var documentName: String = ""
    public var documentTechnicalName: String = ""
    public var classification: String = ""
    public var mandatory: String = ""
    public var visualization: String = ""
    public var field = Array<FEFieldCalculadora>()
}
