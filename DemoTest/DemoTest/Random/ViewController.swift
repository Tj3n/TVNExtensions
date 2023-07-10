//
//  ViewController.swift
//  DemoTest
//
//  Created by Tien Nhat Vu on 4/11/18.
//

import UIKit
import TVNExtensions
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var testTextfield: UITextField! {
        didSet {
            testTextfield.delegate = self
        }
    }

    @IBOutlet weak var imgView: UIImageView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(testImageViewer(_:)))
            imgView.isUserInteractionEnabled = true
            imgView.addGestureRecognizer(tapGesture)
        }
    }
    
    var scannerBarBtn: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.camera, target: nil, action: nil)
        return btn
    }()
    
    let bag = DisposeBag()
    
    var animator: ExpandShrinkAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor(hexString: "fff4e6")
        
        let testFontFamilyName = "Beautiful People Personal Use"
        if UIFont.familyNames.contains(testFontFamilyName) {
            testTextfield.font = UIFont(name: testFontFamilyName.removeCharacters(from: " "), size: 17)
            print(UIFont.fontNames(forFamilyName: testFontFamilyName))
        } else {
            if let font = UIFont.loadFont(fontFileName: testFontFamilyName, fileType: "ttf", bundle: .main, size: 17) {
                print("font font \(font.fontDescriptor)\n\(font.description)\n\(font.familyName)\n\(UIFont.fontNames(forFamilyName: font.familyName))")
                testTextfield.font = font
            }
        }
        
        self.navigationItem.rightBarButtonItem = scannerBarBtn
        scannerBarBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.testCodeScannerRX()
            })
            .disposed(by: bag)
    }
    
    deinit {
        self.navigationController?.delegate = nil
    }
    
    @objc func testImageViewer(_ sender: UIGestureRecognizer) {
        print(#function)
//        let viewer = ImageViewerViewController(image: imgView.image, from: imgView)
        let viewer = ImageViewerViewController(imageURL: URL(string: "https://cdn.pixabay.com/photo/2017/02/20/18/03/cat-2083492_1280.jpg")!, placeholderImage: imgView.image, from: imgView, clippingTransition: false) { img in
            self.imgView.image = img
        }
        self.present(viewer, animated: true, completion: nil)
    }
    
    func biometryAuthenticateWithRx() {
        BiometryHelper.rx.authenticateUser(with: "test").subscribe { (event) in
            switch event {
            case .error(let error):
                print("error \(error.localizedDescription)")
            case .completed:
                print("completed")
            }
            }
            .disposed(by: bag)
    }
    
    func getNextVC() -> NextViewController {
        let nextVC = NextViewController()
        nextVC.destinationText = self.testTextfield.text!.isEmpty ? self.testTextfield.placeholder : self.testTextfield.text
        nextVC.destinationImage = self.imgView.image
        return nextVC
    }

    @IBAction func modalBtnTouch(_ sender: Any) {
        let nextVC = getNextVC()
        nextVC.modalPresentationStyle = .fullScreen
        self.animator = ExpandShrinkAnimator(fromView: self.imgView, toView: nextVC.destinationImgView)
        nextVC.transitioningDelegate = self.animator
        self.present(nextVC, animated: true, completion: nil)
    }
    
    @IBAction func pushBtnTouch(_ sender: Any) {
        let nextVC = getNextVC()
        self.animator = ExpandShrinkAnimator(fromView: self.imgView, toView: nextVC.destinationImgView)
        self.navigationController?.delegate = self.animator
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func testCodeScannerRX() {
        let scannerView = CodeScannerView()
        scannerView.addTo(view)
        scannerView.edgesToSuperView()
        scannerView.rx
            .startReading
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (event) in
                print(event)
                scannerView.removeFromSuperview()
                self?.navigationItem.rightBarButtonItem = self?.scannerBarBtn
            }
            .disposed(by: bag)
        
        let closeBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = closeBtn
        closeBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                scannerView.removeFromSuperview()
                self?.navigationItem.rightBarButtonItem = self?.scannerBarBtn
            })
            .disposed(by: bag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? NextViewControllerAlt {
            nextVC.destinationText = self.testTextfield.text!.isEmpty ? self.testTextfield.placeholder : self.testTextfield.text
            nextVC.destinationImage = self.imgView.image
            _ = nextVC.view // Fix for nil destinationImgView
            
            self.animator = ExpandShrinkAnimator(fromView: self.imgView, toView: nextVC.destinationImgView)
            if segue.identifier == "show" {
                nextVC.modalPresentationStyle = .fullScreen
                nextVC.transitioningDelegate = animator
            } else if segue.identifier == "push" {
                navigationController?.delegate = animator
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
//        testShowError()
    }
    
    func testShowError() { 
        let error = NSError(domain: "com.tvn.test", code: 500, userInfo: [NSLocalizedDescriptionKey: String.generateRandomString(length: 4)])
        error.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            let error = NSError(domain: "com.tvn.test", code: 500, userInfo: [NSLocalizedDescriptionKey: String.generateRandomString(length: 4)])
            error.show()
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentLength = (textField.text ?? "").count
        let newLength = currentLength + string.count - range.length
        if newLength == 0 {
            print("Last char deleted")
        }
        return true
    }
}
