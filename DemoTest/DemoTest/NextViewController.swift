//
//  NextViewController.swift
//  DemoTest
//
//  Created by Tien Nhat Vu on 4/13/18.
//

import UIKit
import TVNExtensions

class NextViewController: UIViewController {

//    @IBOutlet weak var destinationImgView: UIImageView!
    
    lazy var destinationImgView: UIImageView = {
        let v = UIImageView(image: nil)
        return v
    }()

    lazy var nextLabel: UILabel = {
        let v = UILabel(frame: .zero)
        v.textAlignment = .center
        v.textColor = .white
        return v
    }()
    
    lazy var dismissBtn: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("Close", for: .normal)
        return v
    }()
    
    lazy var topLabel: UILabel = {
        let v = UILabel(frame: .zero)
        v.textAlignment = .center
        v.textColor = .white
        v.text = "Top"
        return v
    }()
    
    lazy var leftLabel: UILabel = {
        let v = UILabel(frame: .zero)
        v.textAlignment = .center
        v.textColor = .white
        v.text = "Left"
        return v
    }()
    
    lazy var rightLabel: UILabel = {
        let v = UILabel(frame: .zero)
        v.textAlignment = .center
        v.textColor = .white
        v.text = "Right"
        return v
    }()
    
    lazy var bottomTextfield: UITextField = {
        let v = UITextField(frame: .zero)
        v.borderStyle = .roundedRect
        v.placeholder = "Test"
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hexString: "854442")
        setupView()
        
        // Do any additional setup after loading the view.
//        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
//            if let nav = self.navigationController {
//                nav.popViewController(animated: true)
//            } else {
//                self.dismiss(animated: true, completion: nil)
//            }
//        }
        
        dismissBtn.addTouchUpInsideAction { [unowned self] (btn) in
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                ///Test dismiss with transition
//                self.dismiss(animated: true, completion: nil)
                
                ///Test change rootVC
                let vc = ViewController.instantiate()
                UIApplication.shared.keyWindow?.changeRootViewController(with: vc, animated: false, completion: nil)
            }
        }
    }
    
    func setupView() {
        destinationImgView.addTo(view)
        destinationImgView.top(to: view, by: 100)
        destinationImgView.centerX(to: view)
        destinationImgView.setWidth(200)
        destinationImgView.setWidthHeightRatio(ratio: 1)

        nextLabel.addTo(view)
        nextLabel.topToBottom(of: destinationImgView, by: 30)
        nextLabel.centerX(to: destinationImgView)
        
        dismissBtn.addTo(view)
        dismissBtn.topToBottom(of: nextLabel, by: 30)
        dismissBtn.centerX(to: destinationImgView)
        
        leftLabel.addTo(view)
        leftLabel.centerY(to: destinationImgView)
        leftLabel.rightToLeft(of: destinationImgView, by: 30)
        
        rightLabel.addTo(view)
        rightLabel.centerY(to: destinationImgView)
        rightLabel.leftToRight(of: destinationImgView, by: 30)
        
        topLabel.addTo(view)
        topLabel.centerX(to: destinationImgView)
        topLabel.bottomToTop(of: destinationImgView, by: 30)
        
        bottomTextfield.addTo(view)
        bottomTextfield.left(to: view, by: 16)
        bottomTextfield.right(to: view, by: 16)
        
        //Test auto bottom constraint
//        let tfBottomConstraint = KeyboardLayoutConstraint.create(with: bottomTextfield, to: view, isToTop: false, constant: 30)
//        tfBottomConstraint.isActive = true
//        tfBottomConstraint.excludeOriginConstant = true
        
        //Test auto top constraint
//        let tfTopConstraint = KeyboardLayoutConstraint.create(with: bottomTextfield, to: view, isToTop: true, constant: 500)
//        tfTopConstraint.isActive = true
//        tfTopConstraint.excludeOriginConstant = true
        
        //Test keyboard handling class
        let tfBottomConstraint = bottomTextfield.bottom(to: view, by: 30)
        self.observeKeyboardEvent { [unowned self] (up, height, duration) in
            tfBottomConstraint.constant = up ? tfBottomConstraint.constant+height : tfBottomConstraint.constant-height
            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension NextViewController: ExpandShrinkAnimatorProtocol {
    var destinationFrame: CGRect {
        get {
            return destinationImgView.frame
        }
    }
}
