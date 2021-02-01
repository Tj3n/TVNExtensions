//
//  ImageHelper.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 10/24/17.
//

import Foundation
import MobileCoreServices

public enum ImageType {
    case png
    case jpg
}

public struct ImageHelper {
    
    /// Parse media info from UIImagePickerController
    /// - Parameters:
    ///   - info: media info
    ///   - isEdited: return editted image
    ///   - completion: return image & url if is image, return url if is video
    public static func parseMediaInfo(_ info: [UIImagePickerController.InfoKey : Any], isEdited: Bool = false, completion: (UIImage?, URL?)->()) {
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String else {
            completion(nil, nil)
            return
        }
        
        if mediaType == String(kUTTypeImage),
           let image = info[isEdited ? UIImagePickerController.InfoKey.originalImage : UIImagePickerController.InfoKey.editedImage] as? UIImage {
            if #available(iOS 11.0, *), let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                completion(image, url)
            } else {
                completion(image, nil)
            }
        } else if mediaType == String(kUTTypeMovie), let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            completion(nil, url)
        } else {
            completion(nil, nil)
        }
    }
    
    public static func parseMediaInfoToImage(_ info: [UIImagePickerController.InfoKey : Any]) -> UIImage? {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return nil
        }
        return image
    }
    
    public static func parseMediaInfoToImageData(_ info: [UIImagePickerController.InfoKey : Any], type: ImageType) -> Data? {
        guard let image = parseMediaInfoToImage(info) else {
            return nil
        }
        let compressionFactor: CGFloat = 1.0
        return type == .jpg ? image.jpegData(compressionQuality: compressionFactor) : image.pngData()
    }
    
    public static func getDocumentsURL() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsURL
    }
    
    public static func fileInDocumentsDirectory(_ filename: String) -> String {
        let fileURL = getDocumentsURL().appendingPathComponent(filename)
        return fileURL.path
    }
    
    public static func saveImage (_ image: UIImage, path: String, imageType: ImageType = .png) {
        let imageData = imageType == .png ? image.pngData() : image.jpegData(compressionQuality: 1.0)
        
        do {
            try imageData!.write(to: URL(fileURLWithPath: path), options: [.atomic])
        } catch  {
            print("error saving image \(error.localizedDescription)")
        }
        print("saved image \(path)")
    }
    
    public static func loadImageFromPath(_ path: String) -> UIImage? {
        let image = UIImage(contentsOfFile: path)
        if image == nil {
            print("missing image at: \(path)")
        }
        print("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
        return image
    }
    
    public static func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
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
    
    //TODO: need check
    public static func cropImage(_ image: UIImage, rect: CGRect) -> UIImage {
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        let contextSize: CGSize = contextImage.size
        
        let widthRatio = contextSize.height/UIScreen.main.bounds.size.height
        let heightRatio = contextSize.width/UIScreen.main.bounds.size.width
        
        let width = (rect.size.width) * widthRatio
        let height = (rect.size.height) * heightRatio
        let x = (contextSize.width/2) - width/2
        let y = (contextSize.height/2) - height/2
        let rect = CGRect(x: x, y: y, width: width, height: height)
        
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        let image: UIImage = UIImage(cgImage: imageRef, scale: 0, orientation: image.imageOrientation)
        return image
    }
    
    public static func clearAllImage() {
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
    
    public static func saveToPhotoLibrary(img: UIImage, _ completionTarget: Any? = nil, _ completionSelector: Selector? = nil, _ contextInfo: UnsafeMutableRawPointer? = nil) {
        UIImageWriteToSavedPhotosAlbum(img, completionTarget, completionSelector, contextInfo)
    }
}
