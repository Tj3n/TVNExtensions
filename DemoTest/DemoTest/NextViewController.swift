//
//  NextViewController.swift
//  DemoTest
//
//  Created by Tien Nhat Vu on 4/13/18.
//

import UIKit
import TVNExtensions
import RxSwift
import RxCocoa

class NextViewController: UIViewController {

    var destinationImage: UIImage?
    var destinationText: String?
    
    lazy var destinationImgView: UIImageView = {
        let view = UIImageView(image: nil)
        return view
    }()

    lazy var nextLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.textAlignment = .center
        view.textColor = .white
        return view
    }()
    
    lazy var dismissBtn: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("Close", for: .normal)
        return view
    }()
    
    lazy var topLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.textAlignment = .center
        view.textColor = .white
        view.text = "Top"
        return view
    }()
    
    lazy var leftLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.textAlignment = .center
        view.textColor = .white
        view.text = "Left"
        return view
    }()
    
    lazy var rightLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.textAlignment = .center
        view.textColor = .white
        view.text = "Right"
        return view
    }()
    
    lazy var bottomTextfield: UITextField = {
        let view = UITextField(frame: .zero)
        view.borderStyle = .roundedRect
        view.placeholder = "Test"
        return view
    }()
    
    let bag = DisposeBag()
    
    deinit {
        print(#file+" "+#function)
    }
    
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
        
        destinationImgView.image = destinationImage
        bottomTextfield.text = destinationText
        
        dismissBtn.addTouchUpInsideAction { [unowned self] (_) in
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                ///Test dismiss with transition
                self.dismiss(animated: true, completion: nil)
                
                ///Test change rootVC
//                let vc = ViewController.instantiate()
//                UIApplication.shared.keyWindow?.changeRootViewController(with: vc, animated: false, completion: nil)
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
//        let tfBottomConstraint = KeyboardLayoutConstraint(from: bottomTextfield, to: view, constant: 50, isToTop: false, relatedBy: .equal, excludeOriginConstant: true, keyboardActiveAmount: 16)
//        tfBottomConstraint.isActive = true
        
        //Test auto top constraint
//        let tfTopConstraint = KeyboardLayoutConstraint(from: bottomTextfield, to: view, constant: 500, isToTop: true)
//        tfTopConstraint.isActive = true
        
        //Test keyboard handling class
        let tfBottomConstraint = bottomTextfield.bottom(to: view, by: 30)
//        self.observeKeyboardEvent { [view = self.view] (isUp, height, duration) in
//            tfBottomConstraint.constant = isUp ? tfBottomConstraint.constant+height : tfBottomConstraint.constant-height
//            UIView.animate(withDuration: duration, animations: {
//                view?.layoutIfNeeded()
//            })
//        }
        
        //RX
        NotificationCenter.default.rx.keyboardTracking()
            .subscribe(onNext: { [view = self.view] (height, duration) in
                tfBottomConstraint.constant = 30+height
                UIView.animate(withDuration: duration, animations: {
                    view?.layoutIfNeeded()
                })
            })
            .disposed(by: bag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
