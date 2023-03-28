//
//  FEBranchCalculadora.swift
//  DIGIPROSDK
//
//  Created by Alejandro López Arroyo on 17/03/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEBranchCalculadora: EVObject
{
    public var branchID: String  = ""
    public var branchName: String = ""
    public var branchSigla: String = ""
    public var branchBPID: String = ""
    public var Convenio = FEConvenioCalculadora()
}
