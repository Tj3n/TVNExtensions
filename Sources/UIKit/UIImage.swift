//
//  UIImageExtension.swift
//  Alamofire
//
//  Created by Tien Nhat Vu on 10/19/17.
//

import Foundation
import UIKit

public extension UIImage {
    convenience init?(qrString: String, size: CGSize) {
        let data = qrString.data(using: .isoLatin1, allowLossyConversion: false)
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        if let qrCodeImg = filter?.outputImage {
            let scaleX = size.width / qrCodeImg.extent.size.width
            let scaleY = size.height / qrCodeImg.extent.size.height
            let transformedImage = qrCodeImg.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            self.init(ciImage: transformedImage)
        } else {
            //            self.init()
            return nil
        }
    }
    
    var brightness: Double {
        return (self.cgImage?.brightness)!
    }
    
    var isDark: Bool {
        return brightness < 125
    }
    
    convenience init?(color: UIColor) {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension CGImage {
    var brightness: Double {
        get {
            let imageData = self.dataProvider?.data
            let ptr = CFDataGetBytePtr(imageData)
            var x = 0
            var result: Double = 0
            for _ in 0..<self.height {
                for _ in 0..<self.width {
                    let r = ptr![0]
                    let g = ptr![1]
                    let b = ptr![2]
                    result += (0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b))
                    x += 1
                }
            }
            let bright = result / Double (x)
            return bright
        }
    }
}
