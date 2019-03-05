//
//  DemoTableViewController.swift
//  DemoTest
//
//  Created by TienVu on 3/4/19.
//

import UIKit
import TVNExtensions

class DemoTableViewController: UITableViewController {
    
    enum DemoType: String, CaseIterable {
        case random = "Random"
        case quicklook = "QLPreviewController"
        case cameraLibrary = "UIImagePickerController"
    }
    
    var demos = DemoType.allCases

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
        var viewController: UIViewController!
        switch demos[indexPath.row] {
        case .random:
            viewController = ViewController.instantiate()
        case .quicklook:
            viewController = PreviewViewController()
        case .cameraLibrary:
            viewController = ImagePickerViewController()
        }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
