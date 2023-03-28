//
//  Sliders.swift
//  DIGIPROSDK
//
//  Created by Jonathan Viloria M on 7/24/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

public class myCustomSlider: UISlider {
    
    public var label: UILabel
    var labelXMin: CGFloat?
    var labelXMax: CGFloat?
    var labelText: ()->String = { "" }
    public var prefijo: String = ""
    public var posfijo: String = ""
    public var estilo: String = ""
    
    required public init?(coder aDecoder: NSCoder) {
        label = UILabel()
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(onValueChanged(sender:)), for: .valueChanged)
    }
    
    
    @IBInspectable open var trackWidth:CGFloat = 2 {
        didSet {setNeedsDisplay()}
    }
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
            width: defaultBounds.size.width,
            height: trackWidth
        )
    }
    
    func setup(){
        labelXMin = frame.origin.x + 16
        labelXMax = frame.origin.x + self.frame.width - 14
        let labelXOffset: CGFloat = labelXMax! - labelXMin!
        let valueOffset: CGFloat = CGFloat(self.maximumValue - self.minimumValue)
        let valueDifference: CGFloat = CGFloat(self.value - self.minimumValue)
        let valueRatio: CGFloat = CGFloat(valueDifference/valueOffset)
        let labelXPos = CGFloat(labelXOffset*valueRatio + labelXMin!)
        label.frame = CGRect(x: labelXPos,y: self.frame.origin.y - 25, width: 200, height: 20)
        label.text = self.value.description
        label.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
        self.superview!.addSubview(label)
    }
    
    public func updateLabel(){
//        label.text = labelText()
        label.text = "\(prefijo)\(label.text!)"
        let labelXOffset: CGFloat = labelXMax! - labelXMin!
        let valueOffset: CGFloat = CGFloat(self.maximumValue - self.minimumValue)
        let valueDifference: CGFloat = CGFloat(self.value - self.minimumValue)
        let valueRatio: CGFloat = CGFloat(valueDifference/valueOffset)
        let labelXPos = CGFloat(labelXOffset*valueRatio + labelXMin!)
        label.frame = CGRect(x: labelXPos - label.frame.width/2,y: self.frame.origin.y - 20, width: 200, height: 25)
        label.textAlignment = NSTextAlignment.center
        self.superview!.addSubview(label)
    }
    public func updateEstilo()
    {
        self.setThumbImage(UIImage(named: estilo, in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        self.setThumbImage(UIImage(named: estilo, in: Cnstnt.Path.framework, compatibleWith: nil), for: .highlighted)
    }
    
    override public func layoutSubviews() {
        labelText = { "\(Int(self.value))" }
        setup()
        updateLabel()
        super.layoutSubviews()
        super.layoutSubviews()
    }
    
    @objc public func onValueChanged(sender: myCustomSlider){
//        updateLabel()
    }
    
}
