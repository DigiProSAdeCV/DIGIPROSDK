//
//  Reglas.swift
//
//  Created by Jonathan Viloria M on 20/08/18.
//  Copyright © 2018 Digipro Movil. All rights reserved.
//
import Foundation
import Eureka
/// Required rule for elements
// String(format: NSLocalizedString("rules_max_char", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), String(atributos?.longitudmaxima ?? 0))
public struct ReglaRequerido<T: Equatable>: RuleType {
    public init(msg: String = NSLocalizedString("rules_required", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), id: String? = nil) {
        self.validationError = ValidationError(msg: msg)
        self.id = id
    }
    public var id: String?
    public var validationError: ValidationError
    public func isValid(value: T?) -> ValidationError? {
        if let str = value as? String {
            return str.isEmpty ? validationError : nil
        }
        return value != nil ? nil : validationError
    }
}
/// Required rule only for list element
public struct ReglaListaRequerido<T: Equatable>: RuleType {
    public init(msg: String = NSLocalizedString("rules_required", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), id: String? = nil) {
        self.validationError = ValidationError(msg: msg)
        self.id = id
    }
    public var id: String?
    public var validationError: ValidationError
    public func isValid(value: T?) -> ValidationError? {
        if let str = value as? String {
            return str.isEmpty || str == NSLocalizedString("elemts_list_default", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: "") ? validationError : nil
        }
        return value != nil ? nil : validationError
    }
}
/// Required rule for default value in list
public struct ReglaListaValor: RuleType {
    public var id: String?
    public var validationError: ValidationError
    public init(msg: String = NSLocalizedString("rules_select", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), id: String? = nil) {
        validationError = ValidationError(msg: msg)
        self.id = id
    }
    public func isValid(value: String?) -> ValidationError? {
        guard let value = value else { return nil }
        return value == NSLocalizedString("elemts_list_default", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: "") ? validationError : nil
    }
}
/// Min row rule for table
public struct ReglaMinFila: RuleType {
    let min: UInt
    public var id: String?
    public var validationError: ValidationError
    public init(minFila: UInt, msg: String? = nil, id: String? = nil) {
        let ruleMsg = msg ?? String(format: NSLocalizedString("rules_min_row", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), String(minFila))
        min = minFila
        validationError = ValidationError(msg: ruleMsg)
        self.id = id
    }
    public func isValid(value: String?) -> ValidationError? {
        guard let value = value else { return nil }
        do{
            let arrayDictionary = try JSONSerializer.toArray(value)
            return arrayDictionary.count < Int(min) ? validationError : nil
        }catch{
            return nil
        }
    }
}
/// Min characters rule
public struct ReglaMinLongitud: RuleType {
    let min: UInt
    public var id: String?
    public var validationError: ValidationError
    public init(minLength: UInt, msg: String? = nil, id: String? = nil) {
        let ruleMsg = msg ?? String(format: NSLocalizedString("rules_min_char", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), String(minLength))
        min = minLength
        validationError = ValidationError(msg: ruleMsg)
        self.id = id
    }
    public func isValid(value: String?) -> ValidationError? {
        guard let value = value else { return nil }
        return value.count < Int(min) ? validationError : nil
    }
}
/// Range number rule
public struct ReglaRangoNumerico: RuleType {
    let min: Int64
    let max: Int64
    public var id: String?
    public var validationError: ValidationError
    public init(minNumber: Int64, maxNumber: Int64, msg: String? = nil, id: String? = nil) {
        let ruleMsg = msg ?? String(format: NSLocalizedString("rules_range", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), String(minNumber), String(maxNumber))
        max = maxNumber
        min = minNumber
        validationError = ValidationError(msg: ruleMsg)
        self.id = id
    }
    public func isValid(value: String?) -> ValidationError? {
        guard let value = value else { return nil }
        if value == "" { return nil}
        let n = Int64(value)
        let d = Double(value)
        if n == nil && d == nil { return ValidationError(msg: NSLocalizedString("rules_maxnumber", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: "")) }
        if n != nil{ return n! >= Int64(min) && n! <= Int64(max) ? nil : validationError }
        if d != nil{ return d! >= Double(min) && d! <= Double(max) ? nil : validationError }
        return nil
    }
}
/// Max characters rule
public struct ReglaMaxLongitud: RuleType {
    let max: UInt
    public var id: String?
    public var validationError: ValidationError
    public init(maxLength: UInt, msg: String, id: String? = nil) {
        let ruleMsg = msg
        max = maxLength
        validationError = ValidationError(msg: ruleMsg)
        self.id = id
    }
    public func isValid(value: String?) -> ValidationError? {
        guard let value = value else { return nil }
        return value.count > Int(max) ? validationError : nil
    }
}
/// Exact characters rule
public struct ReglaExactaLongitud: RuleType {
    let length: UInt
    public var id: String?
    public var validationError: ValidationError
    public init(exactLength: UInt, msg: String? = nil, id: String? = nil) {
        let ruleMsg = msg ?? String(format: NSLocalizedString("rules_exact_char", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), String(exactLength))
        length = exactLength
        validationError = ValidationError(msg: ruleMsg)
        self.id = id
    }
    public func isValid(value: String?) -> ValidationError? {
        guard let value = value else { return nil }
        return value.count != Int(length) ? validationError : nil
    }
}
/// Regex rule
open class ReglaExpReg: RuleType {
    public var regExpr: String = ""
    public var id: String?
    public var validationError: ValidationError
    public var allowsEmpty = true
    public init(regExpr: String, allowsEmpty: Bool = true, msg: String = NSLocalizedString("rules_value", bundle: Cnstnt.Path.framework ?? Bundle.main, comment: ""), id: String? = nil) {
        self.validationError = ValidationError(msg: msg)
        self.regExpr = regExpr
        self.allowsEmpty = allowsEmpty
        self.id = id
    }
    public func isValid(value: String?) -> ValidationError? {
        if let value = value, !value.isEmpty {
            let predicate = NSPredicate(format: "SELF MATCHES %@", regExpr)
            guard predicate.evaluate(with: value) else {
                return validationError
            }
            return nil
        } else if !allowsEmpty {
            return validationError
        }
        return nil
    }
}
