//
//  UtilitiesForImage.swift
//  DIGIPROSDK
//
//  Created by Carlos Mendez Flores on 06/07/20.
//  Copyright © 2020 Jonathan Viloria M. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public class UtilitiesForImage {
    
    public let startDate = Date()
    public var originalImage: UIImage = #imageLiteral(resourceName: "jeremy-thomas-unsplash")
    
    private func compressJPGImage(with quality: CGFloat) -> UIImage  {
        
        guard let data = self.originalImage.jpegData(compressionQuality: quality) else {
            return UIImage()
        }
        
        if let time = self.elapsedTime(from: self.startDate) {
            print("\(time) s")
        }
        
        return UIImage(data: data) ?? UIImage()
        
    }
    
    public func compressHEICImage(with quality: CGFloat)-> UIImage {
        
        do {
            let data = try self.originalImage.heicData(compressionQuality: quality)
            
            if let time = self.elapsedTime(from: self.startDate) {
                print("\(time) s")
            }
            return UIImage(data: data) ?? UIImage()
            
            
        } catch {
            print("Error creating HEIC data: \(error.localizedDescription)")
            return UIImage()
        }
        
    }
    
    private func elapsedTime(from startDate: Date) -> String? {
        let numberFormatter = NumberFormatter()
        let endDate = Date()
        let interval = endDate.timeIntervalSince(startDate)
        let intervalNumber = NSNumber(value: interval)
        
        return numberFormatter.string(from: intervalNumber)
    }
    
    
}

extension UIImage {
    enum HEICError: Error {
        case heicNotSupported
        case cgImageMissing
        case couldNotFinalize
    }
    
    func heicData(compressionQuality: CGFloat) throws -> Data {
        let data = NSMutableData()
        guard let imageDestination =
            CGImageDestinationCreateWithData(
                data, AVFileType.heic as CFString, 1, nil
            )
            else {
                throw HEICError.heicNotSupported
        }
        
        guard let cgImage = self.cgImage else {
            throw HEICError.cgImageMissing
        }
        
        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        
        CGImageDestinationAddImage(imageDestination, cgImage, options)
        guard CGImageDestinationFinalize(imageDestination) else {
            throw HEICError.couldNotFinalize
        }
        
        return data as Data
    }
}

extension Data {
    var prettySize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(count))
    }
    
}
