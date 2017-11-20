//
//  AppDelegate.swift
//  BufferPlayer
//
//  Created by Jake Bromberg on 11/19/17.
//  Copyright © 2017 Jake Bromberg. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var task: URLSessionDataTask?
    var session: URLSession?
    let queue = OperationQueue()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        session = URLSession(
            configuration: URLSessionConfiguration.background(withIdentifier: "hello"),
            delegate: DataStreamer(),
            delegateQueue: .current
        )
        
        task = session?.dataTask(with: URL.WXYCStream)
        task?.resume()

        return true
    }
}
