//
//  JUMIODocumentOcrRow.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 26/02/23.
//  Copyright © 2023 Jonathan Viloria M. All rights reserved.
//

import UIKit
import Eureka

open class _JumioOCRDocumentOf<T: Equatable>: Row<JUMIODocumentOcrCell>, KeyboardReturnHandler {
    
    open var keyboardReturnType: KeyboardReturnTypeConfiguration?
    open var presentationMode: PresentationMode<UIViewController>?
    open var onPresentCallback: ((FormViewController, SelectorViewController<SelectorRow<Cell>>) -> Void)?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { [unowned self] value in
            guard let v = value else { return nil }
            self.value = String(describing: v)
            return String(describing: "")
        }
        cellProvider = CellProvider<JUMIODocumentOcrCell>()
    }
}

/// A row with a button and String value. The action of this button can be anything but normally will push a new view controller
public final class JUMIODocumentOcrRow: _JumioOCRDocumentOf<String>, RowType { }
