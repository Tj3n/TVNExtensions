//
//  ParticleViewController.swift
//  DemoTest
//
//  Created by Tj3n-MacOS on 5/21/19.
//

import UIKit
import TVNExtensions
import ParticleIOS

class ParticleViewController: UIViewController {
    
    lazy var particleView = ParticleView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Particle"
        // Do any additional setup after loading the view.
        
        view.addSubview(particleView)
        particleView.edgesToSuperView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        particleView.start()
    }
}
