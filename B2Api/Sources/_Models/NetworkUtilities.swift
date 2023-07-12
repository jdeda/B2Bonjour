//
//  NetworkUtilities.swift
//  B2Api
//
//  Created by Klajd Deda on 3/28/23.
//  Copyright © 2023 Backblaze. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

public struct NetworkUtilities {
    static var defaultBackblazeHeaders: [String: String] {
        var headers: [String: String] = [:]
        
#if os(iOS)
        // set user-agent.
        // Example: "Backblaze/3.2.1 (com.backblaze.BzBackupBrowser; build:53; iPhone; iOS 12.1.4)"
        // fyi -- Alamofire's was: "Backblaze/3.2.1 (com.backblaze.BzBackupBrowser; build:53; iOS 12.1.4) Alamofire/4.8.1"
        if let info = Bundle.main.infoDictionary,
           let appName = info["CFBundleExecutable"],
           let appVersion = info["CFBundleShortVersionString"],
           let appBuild = info["CFBundleVersion"],
           let appBundleIdentifier = info["CFBundleIdentifier"]  {
            let iosVersion = UIDevice.current.systemVersion
            let deviceType = UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone"
            
            headers = [ "User-Agent": "\(appName)/\(appVersion) (\(appBundleIdentifier); build:\(appBuild); \(deviceType); iOS \(iosVersion))"]
            
            // Accept-Language HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
            // i.e., "en-US;q=1.0, es-US;q=0.9, zh-Hans-US;q=0.8, zh-Hant-US;q=0.7, ru-US;q=0.6"
            var acceptLanguages: [String] = [String]()
            var rank: Decimal = 1.0
            for language in NSLocale.preferredLanguages.enumerated() {
                if rank <= 0.5 {
                    break
                }
                acceptLanguages.append("\(language.element);q=\(rank)")
                rank -= 0.1
            }
            headers["Accept-Language"] = acceptLanguages.joined(separator: ", ")
            
            headers["Accept-Encoding"] = "gzip;q=1.0, compress;q=0.5"
        }
#else
        let appVersion = "1.0.1" // infoDictionary["CFBundleShortVersionString"]
        let macVersion = ProcessInfo.processInfo.operatingSystemVersionString
        headers = ["User-Agent":"bzbrowser/\(String(describing: appVersion)) mac/\(macVersion)"]
//        if let infoDictionary = Bundle.init(for: self.classForCoder()).infoDictionary {
//            let appVersion = infoDictionary["CFBundleShortVersionString"]
//            let macVersion = ProcessInfo.processInfo.operatingSystemVersionString
//            headers = ["User-Agent":"bzbrowser/\(String(describing: appVersion)) mac/\(macVersion)"]
//        }
#endif
        
        return headers
    }
}

