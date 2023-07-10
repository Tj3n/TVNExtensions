//
//  ReachabilityType.swift
//  TVNExtensions
//
//  Created by TienVu on 2/21/19.
//

import Foundation
import RxSwift
import class Dispatch.DispatchQueue
import TVNExtensions

public enum ReachabilityStatus {
    case reachable(viaWiFi: Bool)
    case unreachable
}

extension ReachabilityStatus {
    var reachable: Bool {
        switch self {
        case .reachable:
            return true
        case .unreachable:
            return false
        }
    }
}

public protocol ReachabilityService {
    var reachability: Observable<ReachabilityStatus> { get }
}

public enum ReachabilityServiceError: Error {
    case failedToCreate
}

public class DefaultReachabilityService: ReachabilityService {
    
    private let _reachabilitySubject: BehaviorSubject<ReachabilityStatus>
    
    public var reachability: Observable<ReachabilityStatus> {
        return _reachabilitySubject.asObservable()
    }
    
    let _reachability: Reachability
    
    init() throws {
        guard let reachabilityRef = Reachability() else { throw ReachabilityServiceError.failedToCreate }
        let reachabilitySubject = BehaviorSubject<ReachabilityStatus>(value: .unreachable)
        
        // so main thread isn't blocked when reachability via WiFi is checked
        let backgroundQueue = DispatchQueue(label: "reachability.wificheck")
        
        reachabilityRef.whenReachable = { reachability in
            backgroundQueue.async {
                reachabilitySubject.on(.next(.reachable(viaWiFi: reachabilityRef.connection == .wifi)))
            }
        }
        
        reachabilityRef.whenUnreachable = { reachability in
            backgroundQueue.async {
                reachabilitySubject.on(.next(.unreachable))
            }
        }
        
        try reachabilityRef.startNotifier()
        _reachability = reachabilityRef
        _reachabilitySubject = reachabilitySubject
    }
    
    deinit {
        _reachability.stopNotifier()
    }
}

extension ObservableConvertibleType {
    public func retryOnBecomesReachable(_ valueOnFailure:Element, reachabilityService: ReachabilityService) -> Observable<Element> {
        return self.asObservable()
            .catchError { (Element) -> Observable<Element> in
                reachabilityService.reachability
                    .skip(1)
                    .filter { $0.reachable }
                    .flatMap { _ in
                        Observable.error(Element)
                    }
                    .startWith(valueOnFailure)
            }
            .retry()
    }
}
