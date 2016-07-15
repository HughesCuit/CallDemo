//
//  ProviderDelegate.swift
//  CallDemo
//
//  Created by 黄河 on 16/7/14.
//  Copyright © 2016年 HH. All rights reserved.
//

import UIKit
import CallKit
import AVFoundation

class ProviderDelegate: NSObject,CXProviderDelegate {
    private let provider:CXProvider
    
    private let callController = CXCallController()
    /// The app's provider configuration, representing its CallKit capabilities
    static var providerConfiguration: CXProviderConfiguration {
        let localizedName = "callDemo"
        let providerConfiguration = CXProviderConfiguration(localizedName: localizedName)
        providerConfiguration.maximumCallsPerCallGroup = 1
        return providerConfiguration
    }
    
    override init() {
        provider = CXProvider(configuration: self.dynamicType.providerConfiguration)
        super.init()
        provider.setDelegate(self, queue: nil)
        print("Current authorization status is \(CXProvider.authorizationStatus.rawValue)")
        if CXProvider.authorizationStatus == .notDetermined {
            provider.requestAuthorization()
        }
    }
    //MARK: - Call
    
    func call(handle:String) {
        let startCallAction = CXStartCallAction(call: UUID(),handle: CXHandle(type: .phoneNumber, value: handle))
        
        let transaction = CXTransaction()
        transaction.addAction(startCallAction)
        
        callController.request(transaction) { (err) in
            print(err)
        }
    }
    //MARK: - Ending Call
    func endCall(uuids : [UUID],completion: (UUID) -> Void) {
        let uuid = uuids.first
        
        let action = CXEndCallAction(call: uuid!)
        let trans = CXTransaction()
        trans.addAction(action)
        callController.request(trans, completion: { (err) in
            print(err)
            completion(action.uuid)
        })
        
    }

    
    // MARK: Incoming Calls
    
    /// Use CXProvider to report the incoming call to the system
    func reportIncomingCall(uuid: UUID, handle: String) {
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        let update = CXCallUpdate()
        update.callerIdentifier = handle
        
        // Report the incoming call to the system
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            /*
             Only add incoming call to the app's list of calls if the call was allowed (i.e. there was no error)
             since calls may be "denied" for various legitimate reasons. See CXErrorCodeIncomingCallError.
             */
            if error == nil {
                print("calling")
                
            }
        }
    }
    
    func providerDidReset(_ provider: CXProvider) {
        print("Provider did reset")
        

    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        let update = CXCallUpdate()
        update.remoteHandle = action.handle
        provider.reportOutgoingCall(with: action.uuid, startedConnectingAt: Date())
        NotificationCenter.default.post(name: "callStart" as Notification.Name, object: self, userInfo: ["uuid":action.uuid])
        action.fulfill(withDateStarted: Date())
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        NotificationCenter.default.post(name: "callStart" as Notification.Name, object: self, userInfo: ["uuid":action.uuid])
        action.fulfill(withDateConnected: Date())
        
    }
    
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
        NotificationCenter.default.post(name: "callEnd" as Notification.Name, object: self, userInfo: ["uuid":action.uuid.uuidString])
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        action.fulfill()
        print("Timed out \(#function)")
        
        // React to the action timeout if necessary, such as showing an error UI.
    }
    
    
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("Received \(#function)")
        
    }
    
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("Received \(#function)")
        
        /*
         Restart any non-call related audio now that the app's audio session has been
         de-activated after having its priority restored to normal.
         */
    }
    
    func provider(_ provider: CXProvider, didChange authorizationStatus: CXAuthorizationStatus) {
        print("Received \(#function)")
        
        // React to the authorization status change if necessary.
    }

}
