//
//  Buttons.swift
//  DIGIPROSDK
//
//  Created by Jonathan Viloria M on 14/02/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class Checkbox: UIButton {

    let checkedImage = UIImage(named: "checked")
    let uncheckedImage = UIImage(named: "uncheked")
    var action: ((Bool) -> Void)? = nil

    private(set) var isChecked: Bool = false {
        didSet{
            self.setImage(
                self.isChecked ? self.checkedImage : self.uncheckedImage,
                for: .normal
            )
        }
    }

    override public func awakeFromNib() {
        self.addTarget(
            self,
            action:#selector(buttonClicked(sender:)),
            for: .touchUpInside
        )
        self.isChecked = false
    }

    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            self.action?(!self.isChecked)
        }
    }

    func update(checked: Bool) {
        self.isChecked = checked
    }
}
