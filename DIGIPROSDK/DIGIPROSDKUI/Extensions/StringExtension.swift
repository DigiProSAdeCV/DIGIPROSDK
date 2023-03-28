//
//  StringExtension.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 26/08/22.
//  Copyright © 2022 Jonathan Viloria M. All rights reserved.
//

import Foundation

extension String {
    /// Determine if the url passed by parameter is relative or absolute
    /// If it is relative, it will interpolate its http and IDPortal information
    /// Parameters
    /// url - URL String
    public static func determineRelativeAndAbsoluteURL(url: String) -> String {
        if url.contains("https://") { // URL Absolute
            return url
        } else { // URL Relative
            let protocolDGP : String = "https://test.digipromovil.com:495/VersionGenerica/IDPortal/"
            return "\(protocolDGP)\(url)"
        }
    }
}
