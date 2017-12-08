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
}
