//
//  AVAudioSession+Extension.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 2/2/18.
//

import Foundation
import AVFoundation

extension AVAudioSession {
    public static var isHeadphonesConnected: Bool {
        return sharedInstance().isHeadphonesConnected
    }
    
    public var isHeadphonesConnected: Bool {
        return !currentRoute.outputs.filter { $0.isHeadphones }.isEmpty
    }
    
    public class func mixWithBackgroundMusic() {
        _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
    }
}

extension AVAudioSessionPortDescription {
    public var isHeadphones: Bool {
        return portType == AVAudioSessionPortHeadphones
    }
}

public class AudioDetection {
    var callback: ((_ isConnected: Bool)->())?
    
    public init(callback: @escaping ((_ isConnected: Bool)->())) {
        self.callback = callback;
        self.listenForNotifications()
    }
    
    deinit {
        callback = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    func listenForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
    @objc func handleRouteChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let reasonRaw = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber,
            let reason = AVAudioSessionRouteChangeReason(rawValue: reasonRaw.uintValue)
            else { fatalError("Strange... could not get routeChange") }
        switch reason {
        case .oldDeviceUnavailable:
            callback?(false)
        case .newDeviceAvailable:
            print("newDeviceAvailable")
            if AVAudioSession.isHeadphonesConnected {
                callback?(true)
            }
        case .routeConfigurationChange:
            print("routeConfigurationChange")
        case .categoryChange:
            print("categoryChange")
        default:
            print("not handling reason")
        }
    }
}



