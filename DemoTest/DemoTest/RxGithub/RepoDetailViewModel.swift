//
//  RepoDetailViewModel.swift
//  RxGithub
//
//  Created by TienVu on 1/23/19.
//  Copyright © 2019 TienVu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RepoDetailViewModel: ViewModelType {
    struct Input {
        let openGitHtmlURLTrigger: Driver<Void>
    }
    
    struct Output {
        let repo: Driver<Repo>
        let openGitHtmlURL: Driver<Void>
    }
    
    private let repo: Repo
    
    init(repo: Repo) {
        self.repo = repo
    }
    
    func transform(input: RepoDetailViewModel.Input) -> RepoDetailViewModel.Output {
        
        let openGitHtmlURL = input.openGitHtmlURLTrigger
            .map { self.repo.htmlURL }
            .flatMap { Driver.from(optional: URL(string: $0)) }
            .do(onNext: { (url) in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            })
            .map({ _ in })
        
        return Output(repo: Driver.just(repo),
                      openGitHtmlURL: openGitHtmlURL)
    }
}
