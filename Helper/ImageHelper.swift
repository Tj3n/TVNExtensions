//
//  ImageHelper.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 10/24/17.
//

import Foundation
protocol ImageHelper {
    
}

extension ImageHelper {
    public func getDocumentsURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }
    
    public func fileInDocumentsDirectory(_ filename: String) -> String {
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL.path
    }
    
    public func saveImage (_ image: UIImage, path: String ) {
        let pngImageData = UIImagePNGRepresentation(image)
        //let jpgImageData = UIImageJPEGRepresentation(image, 1.0)   // if you want to save as JPEG
        
        do {
            try pngImageData!.write(to: URL(fileURLWithPath: path), options: [.atomic])
        } catch  {
            print("error saving image \(error.localizedDescription)")
        }
        print("saved image \(path)")
    }
    
    public func loadImageFromPath(_ path: String) -> UIImage? {
        let image = UIImage(contentsOfFile: path)
        if image == nil {
            print("missing image at: \(path)")
        }
        print("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
        return image
    }
    
    public func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    public func clearAllImage() {
        do {
            let folderPath = getDocumentsURL()
            let paths = try FileManager.default.contentsOfDirectory(atPath: String(describing: folderPath))
            for path in paths
            {
                try FileManager.default.removeItem(atPath: "\(folderPath)/\(path)")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    public func saveToPhotoLibrary(img: UIImage) {
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
    }
}
