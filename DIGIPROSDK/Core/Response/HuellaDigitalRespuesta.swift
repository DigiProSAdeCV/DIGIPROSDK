//
//  Fingerprints.swift
//  Digipro
//
//  Created by Jonathan Viloria M on 10/26/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//

import Foundation

public class HuellaDigitalRespuesta: EVObject{
    public var Fingerprints = Array<FingerPrintsData>()
    public var Status = 0
}

public class FingerPrintsData: EVObject{
    public var CaptureDate = CaptureDateData()
    public var FingerImpressionImage = FingerImpressionImageData()
    public var FingerPositionCode = 0
    public var FingerprintImageFingerMissing = ""
    public var NFIQ = 0
}

public class CaptureDateData: EVObject{
    public var DateTime = ""
}

public class FingerImpressionImageData: EVObject{
    public var BinaryBase64ObjectPNG = ""
    public var BinaryBase64ObjectRAW = ""
    public var BinaryBase64ObjectWSQ = ""
    public var Height = 0
    public var ImageBitsPerPixelQuantity = 0
    public var ImageHashValuePNG = ""
    public var ImageHashValueRAW = ""
    public var ImageHashValueWSQ = ""
    public var Resolution = 0
    public var Width = 0
}
