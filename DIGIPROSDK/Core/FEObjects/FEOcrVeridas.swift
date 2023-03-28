//
//  FEOcrVeridas.swift
//  DIGIPROSDK
//
//  Created by Carlos Mendez Flores on 29/10/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class FEOcrVeridas: EVObject {
    public var PD_AddressMunicipality_Out: String = ""
    public var OD_CURP_Out: String = ""
    public var PD_IdentificationNumber_Out: String = ""
    public var PD_AddressDistrict_Out: String = ""
    public var PD_Name_Out: String = ""
    public var PD_LastName2_Out: String = ""
    public var DD_ExpeditionDate_Out: String = ""
    public var PD_Sex_Out: String = ""
    public var OD_IDCredentialCode_Out: String = ""
    public var PD_AddressStreet_Out: String = ""
    public var OD_EmissionNumber_Out: String = ""
    public var PD_LastName1_Out: String = ""
    public var PD_BirthPlaceState_Out: String = ""
    public var DD_ExpirationDate_Out: String = ""
    public var PD_AddressState_Out: String = ""
    public var PD_BirthDate_Out: String = ""
    public var OD_Section_Out: String = ""
    public var OD_OCRNumber_Out: String = ""
    public var OD_RegistrationDate_Out: String = ""
    public var PD_LastName_Out: String = ""
    public var OD_FUAR_Out: String = ""
    
    public var PD_Nationality_Out: String = ""
    public var PD_AdressStreet_Out: String = ""
    public var DD_DocumentNumber_Out: String = ""
    public var DD_IssuingCountry_Out: String = ""
    public var fullName: String = ""
    public var ScoreDocumentTotal: String = ""
    public var ScoreValidationGlobal: String = ""
    public var ScoreSelfie: String = ""
    public var ScorePhotoId: String = ""
    public var ScoreDocumentAuthenticity: String = ""
    public var ScoreLifeProof: String = ""
    public var ScoreVideo: String = ""
    
}

public class FECorrectedOCR: EVObject {
    public var name :String = ""
    public var confirmedText :String = ""
}
