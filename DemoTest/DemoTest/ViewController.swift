//
//  ViewController.swift
//  DemoTest
//
//  Created by Tien Nhat Vu on 4/11/18.
//

import UIKit
import TVNExtensions

class ViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    let animator = ExpandShrinkAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.delegate = animator
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
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
            
            let nextVC = NextViewController()
            let _ = nextVC.view
            nextVC.destinationImgView.image = self.imgView.image
            nextVC.transitioningDelegate = self.animator
            self.present(nextVC, animated: true, completion: nil)
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? NextViewController  {
            let _ = nextVC.view
            nextVC.destinationImgView.image = imgView.image
            nextVC.transitioningDelegate = animator
        }
    }
}
