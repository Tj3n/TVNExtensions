//
//  ViewController.swift
//  DemoTest
//
//  Created by Tien Nhat Vu on 4/11/18.
//

import UIKit
import TVNExtensions

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
    var animator: ExpandShrinkAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = UIColor(hexString: "fff4e6")
        
        let testFontFamilyName = "Beautiful People Personal Use"
        guard UIFont.familyNames.contains(testFontFamilyName) else {
            if let font = UIFont.loadFont(fontFileName: testFontFamilyName, fileType: "ttf", bundle: .main, size: 17) {
                print("font font \(font.fontDescriptor)\n\(font.description)\n\(font.familyName)\n\(UIFont.fontNames(forFamilyName: font.familyName))")
                testTextfield.font = font
            }
            return
        }
        print(UIFont.fontNames(forFamilyName: testFontFamilyName))
        testTextfield.font = UIFont(name: testFontFamilyName.removeCharacters(from: " "), size: 17)
    }
    
    @objc func testImageViewer(_ sender: UIGestureRecognizer) {
        print(#function)
        let viewer = ImageViewerViewController(image: imgView.image, from: imgView)
//        let viewer = ImageViewerViewController(imageURL: URL(string: "https://www.gstatic.com/webp/gallery3/1.png")!, placeholderImage: imgView.image, from: imgView)
        self.present(viewer, animated: true, completion: nil)
    }
    
    func getNextVC() -> NextViewController {
        let nextVC = NextViewController()
        nextVC.destinationText = self.testTextfield.text!.isEmpty ? self.testTextfield.placeholder : self.testTextfield.text
        nextVC.destinationImage = self.imgView.image
        return nextVC
    }

    @IBAction func modalBtnTouch(_ sender: Any) {
        let nextVC = getNextVC()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? NextViewControllerAlt {
            nextVC.destinationText = self.testTextfield.text!.isEmpty ? self.testTextfield.placeholder : self.testTextfield.text
            nextVC.destinationImage = self.imgView.image
            let _ = nextVC.view // Fix for nil destinationImgView
            
            self.animator = ExpandShrinkAnimator(fromView: self.imgView, toView: nextVC.destinationImgView)
            if segue.identifier == "show" {
                nextVC.transitioningDelegate = animator
            } else if segue.identifier == "push" {
                navigationController?.delegate = animator
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
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
