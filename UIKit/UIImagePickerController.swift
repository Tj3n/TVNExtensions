//
//  UIImagePickerController.swift
//  TVNExtensions
//
//  Created by TienVu on 1/8/19.
//

import Foundation

public enum ImagePickerError: Error {
    case noCameraAvailable
    case noPhotoLibraryAccess
    case unknowError
}

extension UIImagePickerController {
    
    /// Simplify create UIImagePickerController for library or camera, to parse with delegate use ImageHelper.parseMediaInfoToImage
    ///
    /// - Parameters:
    ///   - sourceType: SourceType
    ///   - delegate: UIImagePickerControllerDelegate
    /// - Returns: UIImagePickerController
    /// - Throws: ImagePickerError
    public class func getCameraVC(sourceType: UIImagePickerController.SourceType, delegate: UINavigationControllerDelegate & UIImagePickerControllerDelegate) throws -> UIImagePickerController  {
        
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            switch sourceType {
            case .camera:
                guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                    throw ImagePickerError.noCameraAvailable
                }
            case .photoLibrary:
                guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                    throw ImagePickerError.noCameraAvailable
                }
            default:
                throw ImagePickerError.unknowError
            }
            throw ImagePickerError.unknowError
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = delegate
        return picker
    }
}
