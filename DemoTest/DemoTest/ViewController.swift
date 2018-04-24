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
        self.navigationController?.delegate = animator
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animator.originFrame = imgView.frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnTouch(_ sender: Any) {
        view.endEditing(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
//            self.performSegue(withIdentifier: "show", sender: self)
//            self.performSegue(withIdentifier: "push", sender: self) // Disable nextVC.transitioningDelegate = animator
            
            //W/o storyboard
            let nextVC = NextViewController()
            let _ = nextVC.view
            nextVC.destinationImgView.image = self.imgView.image
            nextVC.nextLabel.text = self.testTextfield.text!.isEmpty ? self.testTextfield.placeholder : self.testTextfield.text
            nextVC.transitioningDelegate = self.animator
            self.present(nextVC, animated: true, completion: nil)
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
