//
//  UIImage+Color.swift
//  Dine
//
//  Created by doss-zstch1212 on 05/07/24.
//

import UIKit

extension UIImage {
    /// Initializes a new UIImage of a specified color and size.
    ///
    /// This convenience initializer creates a UIImage filled with the given color.
    /// If the size parameter is not specified, it defaults to a 1x1 pixel image.
    ///
    /// - Parameters:
    ///   - color: The UIColor to fill the image with.
    ///   - size: The CGSize of the resulting image. Default is CGSize(width: 1, height: 1).
    ///
    /// - Returns: A UIImage object filled with the specified color and size.
    ///
    /// - Note: This initializer uses `UIGraphicsBeginImageContext`, `UIGraphicsGetCurrentContext`, and `UIGraphicsEndImageContext`
    ///         to create the image. The context is drawn with the specified color and size, then converted to a UIImage.
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        // Begin a new image context with the specified size
        UIGraphicsBeginImageContext(size)
        
        // Get the current context and set the fill color
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        
        // Fill the context with the specified color
        UIGraphicsGetCurrentContext()!.fill(CGRect(origin: .zero, size: size))
        
        // Capture the image from the current context
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        // End the image context
        UIGraphicsEndImageContext()
        
        // Initialize the UIImage with the captured CGImage
        self.init(cgImage: image.cgImage!)
    }
}
