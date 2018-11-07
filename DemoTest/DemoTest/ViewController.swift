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

    @IBOutlet weak var imgView: UIImageView!
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

    @IBAction func btnTouch(_ sender: Any) {
        view.endEditing(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            ///Test animate transistion with sb
//            self.performSegue(withIdentifier: "show", sender: self) // Disable navigationController?.delegate = animator
            self.performSegue(withIdentifier: "push", sender: self) // Disable nextVC.transitioningDelegate = animator
            return
            
            ///W/o sb
            let nextVC = NextViewController()
            nextVC.destinationText = self.testTextfield.text!.isEmpty ? self.testTextfield.placeholder : self.testTextfield.text
            nextVC.destinationImage = self.imgView.image
            let _ = nextVC.view
            
            ///Test animate transistion without sb
            self.animator = ExpandShrinkAnimator(fromView: self.imgView, toView: nextVC.destinationImgView)
//            nextVC.transitioningDelegate = self.animator
//            self.present(nextVC, animated: true, completion: nil)
            self.navigationController?.delegate = self.animator
            self.navigationController?.pushViewController(nextVC, animated: true)
            
            ///Test change rootVC
//            UIApplication.shared.keyWindow?.changeRootViewController(with: nextVC, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? NextViewController  {
            nextVC.destinationText = self.testTextfield.text!.isEmpty ? self.testTextfield.placeholder : self.testTextfield.text
            nextVC.destinationImage = self.imgView.image
            let _ = nextVC.view
            
            self.animator = ExpandShrinkAnimator(fromView: self.imgView, toView: nextVC.destinationImgView)
//            nextVC.transitioningDelegate = self.animator
            self.navigationController?.delegate = self.animator
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
