//
//  AppDelegate.swift
//  CatCal
//
//  Created by Michael on 12/5/17.
//  Copyright © 2017 DotDev. All rights reserved.
//

import Google
import GoogleSignIn
import UIKit
import SwiftyBeaver

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func applicationDidFinishLaunching(_ application: UIApplication) {        
        // Initialize Sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
        // Set up logging
        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss.SSS$d $L $N.$F:$l $M"
        console.levelString.verbose = "⚪️ VERBOSE"
        console.levelString.debug = "🐞 DEBUG"
        console.levelString.info = "🔵 INFO"
        console.levelString.warning = "⚫️ WARNING"
        console.levelString.error = "🔴 ERROR"
        #if DEBUG
            console.asynchronously = false
        #else
            console.minLevel = .warning
        #endif
        log.addDestination(console)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
}

