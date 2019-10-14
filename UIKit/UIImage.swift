//
//  UIImageExtension.swift
//  Alamofire
//
//  Created by Tien Nhat Vu on 10/19/17.
//

import Foundation
import UIKit

extension UIImage {
    public convenience init?(qrString: String, size: CGSize) {
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
