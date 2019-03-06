//
//  RepoListViewModel.swift
//  RxGithub
//
//  Created by TienVu on 1/25/19.
//  Copyright © 2019 TienVu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import TVNExtensions

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

class RepoListViewModel: ViewModelType {
    struct Input {
        let refresh: Driver<Void>
        let selection: Driver<IndexPath>
        let loadMoreTrigger: (Driver<Bool>) -> Driver<Void>
        let searchTrigger: Driver<String>
    }
    
    struct Output {
        let repos: Driver<[Repo]>
        let selectedRepo: Driver<Repo>
        let loading: Driver<Bool>
        let error: Driver<Error>
    }
    
    static let perPage = 20
    static let defaultSearchText = "language:swift"
    
    func transform(input: RepoListViewModel.Input) -> RepoListViewModel.Output {
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        let repos = BehaviorRelay<[Repo]>(value: [])
        var totalCount = 0
        
        let refreshTrigger = Driver.merge(input.refresh.map({ "" }),
                                          input.searchTrigger)
        
        let currentParams = Driver.combineLatest(refreshTrigger, repos.asDriver()) { (text, repoArray) in
            return (text, repoArray.count/RepoListViewModel.perPage) //(searchText, currentPage)
        }
        
        let loadMoreTrigger = input.loadMoreTrigger(activityIndicator.asDriver())
            .withLatestFrom(currentParams)
            .filter({ $0.1 < totalCount/RepoListViewModel.perPage })
            .map({ ($0.0, $0.1+1) })
        
        _ = refreshTrigger
            .flatMapLatest { (text) in
                return self.fetchTopRepos(searchText: text, page: 1)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriver(onErrorJustReturn: Repos.empty)
            }
            .drive(onNext: { (newRepos) in
                repos.accept(newRepos.items)
                totalCount = newRepos.totalCount
            })
        
        _ = loadMoreTrigger
            .flatMapLatest { (text, page) in
                return self.fetchTopRepos(searchText: text, page: page)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriver(onErrorJustReturn: Repos.empty)
            }
            .drive(onNext: { (newRepos) in
                repos.accept(repos.value+newRepos.items)
                totalCount = newRepos.totalCount
            })

        let selectedRepo = input.selection
            .map({ (indexPath) -> Repo in
                return repos.value[indexPath.row]
            })
        
        return Output(repos: repos.asDriver(),
                      selectedRepo: selectedRepo,
                      loading: activityIndicator.asDriver(),
                      error: errorTracker.asDriver())
    }
    
    func fetchTopRepos(searchText: String, page: Int) -> Observable<Repos> {
        return Observable.from(["https://api.github.com/search/repositories?q=\(searchText.count > 0 ? searchText : RepoListViewModel.defaultSearchText)&per_page=\(RepoListViewModel.perPage)&page=\(page)"])
            .map { urlString -> URL in
                return URL(string: urlString)!
            }
            .map { url -> URLRequest in
                var request = URLRequest(url: url)
                //Add if want to use auth
                //request.addValue("Bearer ...", forHTTPHeaderField: "Authorization")
                return request
            }
            .flatMap { (request) -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            .map { (object) in
                let decoder = JSONDecoder()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                let repos = try decoder.decode(Repos.self, from: object.data)
                return repos
            }
    }
}
