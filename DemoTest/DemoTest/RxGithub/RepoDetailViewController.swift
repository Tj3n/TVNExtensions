//
//  RepoDetailViewController.swift
//  RxGithub
//
//  Created by TienVu on 1/23/19.
//  Copyright © 2019 TienVu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RepoDetailViewController: UIViewController {
    
    var viewModel: RepoDetailViewModel!
    private let bag = DisposeBag()
    
    let tableView: UITableView = {
        var tableView = UITableView(frame: .zero)
        tableView.estimatedRowHeight = 10
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(RepoListCell.self, forCellReuseIdentifier: RepoListCell.reuseIdentifier)
        return tableView
    }()
    
    let goBarButton: UIBarButtonItem = {
        let view = UIBarButtonItem(title: "Go", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        return view
    }()
    
    init(viewModel: RepoDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        view.addSubview(tableView)
        navigationItem.rightBarButtonItem = goBarButton
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let output = viewModel.transform(input: RepoDetailViewModel.Input(openGitHtmlURLTrigger: goBarButton.rx.tap.asDriver()))
        output.repo
            .map({ (repo) -> [(label: String?, value: String)] in
                let mirror = Mirror(reflecting: repo)
                return mirror.children.map({ return (label: $0.label, value: "\($0.value)") })
            })
            .drive(tableView.rx.items(cellIdentifier: RepoListCell.reuseIdentifier,
                                      cellType: RepoListCell.self)) { _, element, cell in
                                        cell.textLabel?.text = element.label
                                        cell.detailTextLabel?.text = element.value
                                        cell.selectionStyle = .none
            }
            .disposed(by: bag)
        
        output.openGitHtmlURL
            .drive()
            .disposed(by: bag)
        
        output.repo
            .map({ $0.name })
            .drive(navigationItem.rx.title)
            .disposed(by: bag)
    }
}
