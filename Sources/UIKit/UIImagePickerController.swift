//
//  UIImagePickerController.swift
//  TVNExtensions
//
//  Created by TienVu on 1/8/19.
//

import Foundation
import MobileCoreServices
import UIKit

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
    @available(*, deprecated, message: "Use getCameraVC(sourceType:allowVideo:delegate:configure: instead")
    public class func getCameraVC(sourceType: UIImagePickerController.SourceType,
                                  delegate: (UINavigationControllerDelegate & UIImagePickerControllerDelegate)?,
                                  configure:((UIImagePickerController)->())? = nil)
        throws -> UIImagePickerController {
        
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
        picker.sourceType = sourceType
        picker.allowsEditing = false
        configure?(picker)
        picker.delegate = delegate
        return picker
    }
    
    /// Simplify create UIImagePickerController for library or camera, to parse with delegate use ImageHelper.parseMediaInfoToImage
    /// - Parameters:
    ///   - sourceType: SourceType - camera/library
    ///   - allowVideo: Allow picking/capturing video
    ///   - delegate: UIImagePickerControllerDelegate
    ///   - configure: Extra configuration
    /// - Returns: UIImagePickerController will have allowsEditing = false by default
    public class func getCameraVC(sourceType: UIImagePickerController.SourceType,
                                  allowVideo: Bool,
                                  delegate: (UINavigationControllerDelegate & UIImagePickerControllerDelegate)?,
                                  configure:((UIImagePickerController)->())? = nil)
        -> UIImagePickerController {
        
        let picker = UIImagePickerController()
        
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            // Support simulator
            picker.sourceType = .photoLibrary;
            return picker
        }
        
        if allowVideo, let mediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType), mediaTypes.contains(String(kUTTypeMovie)) {
            picker.mediaTypes = mediaTypes
        }
        
        picker.sourceType = sourceType
        picker.allowsEditing = false
        configure?(picker)
        picker.delegate = delegate
        return picker
    }
}
