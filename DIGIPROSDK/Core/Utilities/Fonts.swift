//
//  Fonts.swift
//  DIGIPROSDK
//
//  Created by Jonathan Viloria M on 7/17/19.
//  Copyright © 2019 Jonathan Viloria M. All rights reserved.
//

import Foundation

extension UIFont {
    
    func with(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits).union(self.fontDescriptor.symbolicTraits)) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    func without(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(self.fontDescriptor.symbolicTraits.subtracting(UIFontDescriptor.SymbolicTraits(traits))) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    public func setStyle(_ style: String) -> UIFont{
        switch style {
        case "italic": return with(.traitItalic)
        default: return without(.traitItalic)
        }
    }
    
    public func normal() -> UIFont {
        return without(.traitBold, .traitItalic)
    }
    
    public func bold() -> UIFont {
        return with(.traitBold)
    }
    
    public func italic() -> UIFont {
        return with(.traitItalic)
    }
    
    public func boldItalic() -> UIFont {
        return with(.traitBold, .traitItalic)
    }
    
        
    public class func loadAllFonts() {
        registerFontWithFilenameString(filenameString: "SourceSansPro-Regular.ttf")
        registerFontWithFilenameString(filenameString: "Roboto-Regular.ttf")
        registerFontWithFilenameString(filenameString: "Lato-Bold.ttf")
        registerFontWithFilenameString(filenameString: "Lato-Regular.ttf")
        registerFontWithFilenameString(filenameString: "Lato-Black.ttf")
        registerFontWithFilenameString(filenameString: "Lato-Light.ttf")
    }
    
    static func registerFontWithFilenameString(filenameString: String) {
        if let frameworkBundle = Cnstnt.Path.framework {
            if let asset = NSDataAsset(name: filenameString, bundle: frameworkBundle) {
                let fontData = asset.data
                let dataProvider = CGDataProvider(data: fontData as CFData)
                let fontRef = CGFont(dataProvider!)!
                var errorRef: Unmanaged<CFError>? = nil
                if (CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) == false) { print("Failed to register font") }
            }
            
        }
    }
    
    public class func getallFonts(){
        UIFont.loadAllFonts()
        for family in UIFont.familyNames.sorted(){
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Names: \(names)")
        }
    }
            
}
