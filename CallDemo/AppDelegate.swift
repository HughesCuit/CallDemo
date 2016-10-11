//
//  AppDelegate.swift
//  CallDemo
//
//  Created by 黄河 on 16/7/14.
//  Copyright © 2016年 HH. All rights reserved.
//

import UIKit
import PushKit
import CallKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,PKPushRegistryDelegate {

    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow?
    let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    var providerDelegate:ProviderDelegate?
    

    internal func applicationDidFinishLaunching(_ application: UIApplication) {
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
        
        providerDelegate = ProviderDelegate()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        return true
    }
    
    // MARK: PKPushRegistryDelegate
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, forType type: PKPushType) {
        /*
         Store push credentials on server for the active user.
         For sample app purposes, do nothing since everything is being done locally.
         */
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, forType type: PKPushType) {
        guard type == .voIP else { return }
        
        if let uuidString = payload.dictionaryPayload["UUID"] as? String,
            let handle = payload.dictionaryPayload["handle"] as? String,
            let hasVideo = payload.dictionaryPayload["hasVideo"] as? Bool,
            let uuid = UUID(uuidString: uuidString)
        {
            displayIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo)
        }
    }
    
    /// Display the incoming call to the user
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil) {
        providerDelegate?.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
    }

}

