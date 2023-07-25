//
//  BackblazeDemo_macOSApp.swift
//  BackblazeDemo_macOS
//
//  Created by Klajd Deda on 7/25/23.
//

import SwiftUI
import B2Api
import XCTestDynamicOverlay

@main
struct BackblazeDemo_macOSApp: App {
    init() {
        LoggingSystem.bootstrap { label in
            ConsoleHandler(label: label)
        }
        //
        //  TODO: kdeda
        // fix this for ios apps ...
        //        Log4swift.configure(appName: "BackBlazeDemoApp")
    }

    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                AppView(store: .init(
                    initialState: .login(.init()),
                    reducer: AppReducer.init
                ))
            }
        }
    }
}
