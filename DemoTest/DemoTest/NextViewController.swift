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
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func setupView() {
        destinationImgView.addTo(view: view)
        destinationImgView.top(to: view, by: 100)
        destinationImgView.centerX(to: view)
        destinationImgView.setWidth(200)
        destinationImgView.setWidthHeightRatio(ratio: 1)

        nextLabel.addTo(view: view)
        nextLabel.topToBottom(of: destinationImgView, by: 30)
        nextLabel.centerX(to: destinationImgView)
        
        dismissBtn.addTo(view: view)
        dismissBtn.topToBottom(of: nextLabel, by: 30)
        dismissBtn.centerX(to: destinationImgView)
        
        leftLabel.addTo(view: view)
        leftLabel.centerY(to: destinationImgView)
        leftLabel.rightToLeft(of: destinationImgView, by: 30)
        
        rightLabel.addTo(view: view)
        rightLabel.centerY(to: destinationImgView)
        rightLabel.leftToRight(of: destinationImgView, by: 30)
        
        topLabel.addTo(view: view)
        topLabel.centerX(to: destinationImgView)
        topLabel.bottomToTop(of: destinationImgView, by: 30)
    }
}

extension NextViewController: ExpandShrinkAnimatorProtocol {
    var destinationFrame: CGRect {
        get {
            return destinationImgView.frame
        }
    }
}
