//
//  VeridasDocumentOcrRow.swift
//  DIGIPROSDKATO
//
//  Created by Carlos Mendez Flores on 24/11/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation

import Eureka

// MARK: VeridasDocumentOcrRow

open class _VeridasDocumentOcrRow<T: Equatable> : Row<VeridasDocumentOcrCell>, KeyboardReturnHandler {
    
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    open var presentationMode: PresentationMode<UIViewController>?
    open var onPresentCallback: ((FormViewController, SelectorViewController<SelectorRow<Cell>>) -> Void)?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let v = value else { return nil }
            self.value = String(describing: v)
            return String(describing: v)
        }
        cellProvider = CellProvider<VeridasDocumentOcrCell>(nibName: "VeridasDocumentOcrCell", bundle: Cnstnt.Path.framework)
    }
    
}

/// A row with a button and String value. The action of this button can be anything but normally will push a new view controller
public final class VeridasDocumentOcrRow: _VeridasDocumentOcrRow<String>, RowType { }
