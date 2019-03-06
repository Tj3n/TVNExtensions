//
//  DemoTableViewController.swift
//  DemoTest
//
//  Created by TienVu on 3/4/19.
//

import UIKit
import TVNExtensions
import RxSwift
import RxCocoa

class DemoTableViewController: UITableViewController {
    
    enum DemoType: String, CaseIterable {
        case random = "Random"
        case quicklook = "QLPreviewController"
        case cameraLibrary = "UIImagePickerController"
        case location = "LocationHelper"
        case rxGithub = "RxGithub"
    }
    
    var demos = DemoType.allCases
    var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.title = "Demo"
        self.clearsSelectionOnViewWillAppear = true
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = demos[indexPath.row].rawValue

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var viewController: UIViewController?
        switch demos[indexPath.row] {
        case .random:
            viewController = ViewController.instantiate()
        case .quicklook:
            viewController = PreviewViewController()
        case .cameraLibrary:
            viewController = ImagePickerViewController()
        case .location:
            updateLocation()
        case .rxGithub:
            viewController = RepoListViewController(viewModel: RepoListViewModel())
        }
        
        if let viewController = viewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension DemoTableViewController {
    func updateLocation() {
        LocationHelper.shared.rx.updateLocation
            .subscribe(onSuccess: { [weak self] in
                print($0)
                let alert = UIAlertController(title: "Loc", message: $0.description, preferredStyle: .alert, cancelTitle: "OK")
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
}
