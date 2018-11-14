//
//  UIFont.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 8/7/18.
//

import Foundation

extension UIFont {
    
    /// Load font from file without adding into .plist, should check for font availability before use
    ///
    /// - Parameters:
    ///   - fontFileName: File name without extension
    ///   - fileType: Font file extension, usually `ttf` or `otf`
    ///   - bundle: File bundle to get path
    ///   - size: Font size
    /// - Returns: Nullable UIFont
    public class func loadFont(fontFileName: String, fileType: String = "otf", bundle: Bundle = .main, size: CGFloat) -> UIFont? {
        guard let fontPath = bundle.url(forResource: fontFileName, withExtension: fileType) else { return nil }
        do {
            let fontData = try Data(contentsOf: fontPath)
            return loadFont(data: fontData, size: size)
        } catch {
            print("Failed to load font data: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Load font from data without adding into .plist, should check for font availability before use
    ///
    /// - Parameters:
    ///   - data: Decrypted font file data
    ///   - size: Font size
    /// - Returns: Nullable UIFont
    public class func loadFont(data: Data, size: CGFloat) -> UIFont? {
        guard let provider = CGDataProvider(data: data as CFData) else { return nil }
        guard let fontRef = CGFont(provider) else { return nil }
        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterGraphicsFont(fontRef, &error) {
            guard let fontNameRef = fontRef.postScriptName else { return nil }
            let font = UIFont(name: fontNameRef as String, size: size)
            return font
        } else {
            let errorDescription = CFErrorCopyDescription(error?.takeRetainedValue())
            print("Failed to load font: \(String(describing: errorDescription))")
        }
        return nil
    }
}
