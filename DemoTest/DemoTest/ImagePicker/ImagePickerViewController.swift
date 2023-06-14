//
//  ImagePickerViewController.swift
//  DemoTest
//
//  Created by TienVu on 3/4/19.
//

import UIKit
import RxSwift
import RxCocoa
import Photos

class ImagePickerViewController: UIViewController {
    
    var cameraBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.system)
        btn.setTitle("Camera", for: .normal)
        return btn
    }()
    
    var libraryBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.system)
        btn.setTitle("Library", for: .normal)
        return btn
    }()
    
    var imageView = UIImageView(image: nil)
    
    var bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Do any additional setup after loading the view.
        view.addSubview(cameraBtn)
        if #available(iOS 11.0, *) {
            cameraBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        } else {
            cameraBtn.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 30).isActive = true
        }
        cameraBtn.centerX(to: view)
        cameraBtn.setRelativeWidth(to: view, ratio: 0.7)
        cameraBtn.setHeight(40)
        cameraBtn.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        view.addSubview(libraryBtn)
        libraryBtn.centerX(to: view)
        libraryBtn.topToBottom(of: cameraBtn, by: 30)
        libraryBtn.setRelativeWidth(to: view, ratio: 0.7)
        libraryBtn.setHeight(40)
        
        view.addSubview(imageView)
        imageView.centerX(to: view)
        imageView.topToBottom(of: libraryBtn, by: 30)
        imageView.setRelativeWidth(to: view, ratio: 0.7)
        imageView.setWidthHeightRatio()
        
        //        setupImagePickerRx()
        setupImagePickerDefault()
    }
    
    func setupImagePickerRx() {
        libraryBtn.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = false
                }
                .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                .take(1)
            }
            .map { info in
                return info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            }
            .bind(to: imageView.rx.image)
            .disposed(by: bag)
        
        cameraBtn.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = .camera
                    picker.allowsEditing = false
                }
                .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                .take(1)
            }
            .map { info in
                return info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            }
            .bind(to: imageView.rx.image)
            .disposed(by: bag)
    }
    
    func setupImagePickerDefault() {
        cameraBtn.addTarget(self, action: #selector(showCamera(_:)), for: .touchUpInside)
        libraryBtn.addTarget(self, action: #selector(showLibrary(_:)), for: .touchUpInside)
    }
    
    @objc func showCamera(_ sender: UIButton) {
        let picker = UIImagePickerController.getCameraVC(sourceType: .camera, allowVideo: true, delegate: self)
        self.present(picker, animated: true, completion: nil)
    }
    
    @objc func showLibrary(_ sender: UIButton) {
        let picker = UIImagePickerController.getCameraVC(sourceType: .photoLibrary, allowVideo: true, delegate: self, configure: {
            $0.allowsEditing = true
        })
        self.present(picker, animated: true, completion: nil)
    }
}

extension ImagePickerViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        imageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
