//
//  ViewController.swift
//  RxGithub
//
//  Created by TienVu on 1/23/19.
//  Copyright © 2019 TienVu. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

class RepoListViewController: UIViewController {
    
    let bag = DisposeBag()
    var viewModel: RepoListViewModel!
    
    var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl(frame: .zero)
        return view
    }()
    
    let tableView: UITableView = {
        var tableView = UITableView(frame: .zero)
        tableView.estimatedRowHeight = 10
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(RepoListCell.self, forCellReuseIdentifier: RepoListCell.reuseIdentifier)
        return tableView
    }()
    
    let searchController: UISearchController = {
        var view = UISearchController(searchResultsController: nil)
        view.dimsBackgroundDuringPresentation = false
        return view
    }()
    
    let indicatorView = UIActivityIndicatorView(style: .gray)
    
    let footerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
    
    let dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Repo>>(
        configureCell: { (_, tableView, ip, repository: Repo) in
            let cell = tableView.dequeueReusableCell(RepoListCell.self, for: ip)
            cell.configure(repo: repository)
            return cell
    })
    
    init(viewModel: RepoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.tableFooterView = footerView
        footerView.addSubview(indicatorView)
        indicatorView.startAnimating()
        
        indicatorView.snp.makeConstraints({ (make) in
            make.center.equalToSuperview()
        })
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "RxGithub"
        definesPresentationContext = true
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .automatic
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.addSubview(refreshControl)
            tableView.tableHeaderView = searchController.searchBar
        }
        
        assert(viewModel != nil)
        bindViewModel(vm: viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            tableView.refreshControl = refreshControl
            extendedLayoutIncludesOpaqueBars = true
        }
    }
    
    func bindViewModel(vm: RepoListViewModel) {
        let tableView: UITableView = self.tableView
        
        let pull = refreshControl.rx
            .controlEvent(.valueChanged)
            .withLatestFrom(searchController.searchBar.rx.text.orEmpty) //To not trigger when searching
            .filter({ $0.count == 0 })
            .map({ _ in })
            .asDriver(onErrorRecover: { _ in return Driver.empty() })
            .startWith(()) //Disable to use Driver.merged with viewWillAppear, .startWith emit 1 event from start
        
        //first version of loadMoreTrigger is in last commit
        let loadMoreTrigger2: (Driver<Bool>) -> (Driver<Void>) = { isLoading in
            tableView.rx.willEndDragging.asDriver()
                .withLatestFrom(isLoading)
                .flatMap({ (loading) in
                    let currentOffset = tableView.contentOffset.y
                    let maximumOffset = tableView.contentSize.height - tableView.frame.size.height
                    
                    // Change 10.0 to adjust the distance from bottom
                    if maximumOffset - currentOffset <= 30.0 && !loading {
                        return Driver.just(())
                    }
                    return Driver.empty()
                })
        }
        
        let searchTrigger = searchController.searchBar.rx.text.orEmpty
            .throttle(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter({ $0.count != 0 })
            .asDriver { (_) in
                return Driver.empty()
            }
        
        let searchDidDismiss = searchController.rx.didDismiss
            .asDriver { (_) in
                return Driver.empty()
        }
        
        let input = RepoListViewModel.Input(refresh: Driver.merge(pull, searchDidDismiss),
                                            selection: tableView.rx.itemSelected.asDriver(),
                                            loadMoreTrigger: loadMoreTrigger2,
                                            searchTrigger: searchTrigger)
        let output = vm.transform(input: input)
        
        output.repos
            .map { [AnimatableSectionModel(model: "Repositories", items: $0)] }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        
        output.selectedRepo
            .map { (repo) in
                return RepoDetailViewController(viewModel: RepoDetailViewModel(repo: repo))
            }
            .do(onNext: { [weak self] (vc) in
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .drive()
            .disposed(by: bag)
        
        output.loading
            .drive(indicatorView.rx.isAnimating)
            .disposed(by: bag)
        
        output.loading
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: bag)
        
        output.loading
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: bag)
        
        output.error
            .map { (error) -> UIAlertController in
                print(error)
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                return alert
            }
            .drive(onNext: { [weak self] (alert) in
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
}

class RepoListCell: UITableViewCell {
    static let reuseIdentifier = "RepoListCell"
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(repo: Repo) {
        textLabel?.text = repo.name
        detailTextLabel?.text = repo.owner.login
    }
}
