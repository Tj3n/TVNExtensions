//
//  NextViewControllerAlt.swift
//  DemoTest
//
//  Created by TienVu on 11/14/18.
//

import UIKit

class NextViewControllerAlt: UIViewController {
    
    @IBOutlet weak var destinationImgView: UIImageView!
    @IBOutlet weak var bottomTextfield: UITextField!
    
    var destinationImage: UIImage?
    var destinationText: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(hexString: "854442")
        destinationImgView.image = destinationImage
        bottomTextfield.text = destinationText
    }
    
    @IBAction func dismissBtnTouch(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}
