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
        v.text = "NextVC"
        v.textAlignment = .center
        return v
    }()
    
    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .white
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func setupView() {
        destinationImgView.addTo(view: view)
            .top(to: view, by: 30)
            .centerX()
            .setWidth(200)
            .setWidthHeightRatio(ratio: 1)
        nextLabel.addTo(view: view)
            .topToBottom(of: destinationImgView, by: 30)
            .centerX(to: destinationImgView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NextViewController: ExpandShrinkAnimatorProtocol {
    var destinationFrame: CGRect {
        get {
            return destinationImgView.frame
        }
    }
}
