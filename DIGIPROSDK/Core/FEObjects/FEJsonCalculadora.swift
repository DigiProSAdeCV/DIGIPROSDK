//
//  FEJsonCalculadora.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 17/03/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEJsonCalculadora: EVObject{
    public var bpID: Int = 0
    public var promotorName: String = ""
    public var biometricsExceptionProtocol: String =  ""
    public var branch = Array<FEBranchCalculadora>()
    public var GruposConvenio = Array<FEGruposConvenio>()
}
