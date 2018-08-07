//
//  ViewController.swift
//  DemoTest
//
//  Created by Tien Nhat Vu on 4/11/18.
//

import UIKit
import TVNExtensions

class ViewController: UIViewController {

    @IBOutlet weak var testTextfield: UITextField!
    @IBOutlet weak var imgView: UIImageView!
    let animator = ExpandShrinkAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationController?.delegate = animator
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animator.originFrame = imgView.frame
    }

    @IBAction func btnTouch(_ sender: Any) {
        view.endEditing(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            ///Test animate transistion with sb
//            self.performSegue(withIdentifier: "show", sender: self) // Disable navigationController?.delegate = animator
//            self.performSegue(withIdentifier: "push", sender: self) // Disable nextVC.transitioningDelegate = animator
            
            ///W/o sb
            let nextVC = NextViewController()
            let _ = nextVC.view
            nextVC.destinationImgView.image = self.imgView.image
            nextVC.nextLabel.text = self.testTextfield.text!.isEmpty ? self.testTextfield.placeholder : self.testTextfield.text
            
            ///Test animate transistion without sb
//            nextVC.transitioningDelegate = self.animator
//            self.present(nextVC, animated: true, completion: nil)
            
            ///Test change rootVC
            UIApplication.shared.keyWindow?.changeRootViewController(with: nextVC, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? NextViewController  {
            let _ = nextVC.view
            nextVC.destinationImgView.image = imgView.image
            nextVC.nextLabel.text = self.testTextfield.text!.isEmpty ? self.testTextfield.placeholder : self.testTextfield.text
            nextVC.transitioningDelegate = animator
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
