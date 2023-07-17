//
//  Coordinator.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 10/10/18.
//

import Foundation
import UIKit

enum CoordinatorTransitionType {
    case root, modal, push
}

protocol CoordinatorType {
    func transition(to vc: UIViewController, animated: Bool, type: CoordinatorTransitionType, completetion: @escaping ()->())
    func pop(animated: Bool, completetion: @escaping ()->())
}

/// This class can be use as Coordinator chain to pass to viewModel or viewController to manage transistion, no support for childViewController
/// Should subclass to add more features
/// ViewControllers creation and variable injection should be manage by another enum/struct to suit different apps
class Coordinator: CoordinatorType {
    
    fileprivate var window: UIWindow
    fileprivate var currentViewController: UIViewController
    
    required init(window: UIWindow) {
        self.window = window
        currentViewController = window.rootViewController!
    }
    
    func transition(to vc: UIViewController, animated: Bool, type: CoordinatorTransitionType, completetion: @escaping () -> ()) {
        switch type {
        case .root:
            window.changeRootViewController(with: vc, animated: animated, completion: completetion)
            currentViewController = UIViewController.getTopViewController(from: vc) ?? vc
        case .modal:
            currentViewController.present(vc, animated: animated, completion: completetion)
            currentViewController = UIViewController.getTopViewController(from: vc) ?? vc
        case .push:
            guard let navigationController = currentViewController.navigationController else {
                fatalError("Can't push a view controller without a navigation controller")
            }
            navigationController.pushViewController(vc, animated: animated)
            currentViewController = UIViewController.getTopViewController(from: vc) ?? vc
        }
    }
    
    func pop(animated: Bool, completetion: @escaping () -> ()) {
        if let modalPresenter = currentViewController.presentingViewController {
            currentViewController.dismiss(animated: animated) {
                completetion()
                self.currentViewController = UIViewController.getTopViewController(from: modalPresenter) ?? modalPresenter
            }
        } else if let navigationController = currentViewController.navigationController {
            guard navigationController.popViewController(animated: animated) != nil else {
                fatalError("No more VC before \(currentViewController) in nav stack")
            }
            currentViewController = UIViewController.getTopViewController(from: navigationController.viewControllers.last) ?? navigationController.visibleViewController!
            completetion()
        } else {
            fatalError("No Navigation controller and no modal presenting \(currentViewController)")
        }
    }
}
