//
//  CallDirectoryHandler.swift
//  ext
//
//  Created by 黄河 on 16/7/14.
//  Copyright © 2016年 HH. All rights reserved.
//

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        guard let phoneNumbersToBlock = retrievePhoneNumbersToBlock() else {
            NSLog("Unable to retrieve phone numbers to block")
            let error = NSError(domain: "CallDirectoryHandler", code: 1, userInfo: nil)
            context.cancelRequest(withError: error)
            return
        }
        
        for phoneNumber in phoneNumbersToBlock {
            context.addBlockingEntry(withNextSequentialPhoneNumber: CXCallDirectoryPhoneNumber(phoneNumber)!)
        }
        
        guard let (phoneNumbersToIdentify, phoneNumberIdentificationLabels) = retrievePhoneNumbersToIdentifyAndLabels() else {
            NSLog("Unable to retrieve phone numbers to identify and their labels")
            let error = NSError(domain: "CallDirectoryHandler", code: 2, userInfo: nil)
            context.cancelRequest(withError: error)
            return
        }
        
        for (phoneNumber, label) in zip(phoneNumbersToIdentify, phoneNumberIdentificationLabels) {
            context.addIdentificationEntry(withNextSequentialPhoneNumber: CXCallDirectoryPhoneNumber(phoneNumber)!, label: label)
        }
        
        context.completeRequest { (suc) in
            print(suc)
        }
    }
    
    private func retrievePhoneNumbersToBlock() -> [String]? {
        // retrieve list of phone numbers to block
        return ["+8612345678901","+8618180100980"]
    }
    
    private func retrievePhoneNumbersToIdentifyAndLabels() -> (phoneNumbers: [String], labels: [String])? {
        // retrieve list of phone numbers to identify, and their labels
        return (["+8618380447991","+8645678901234"], ["abc","def"])
    }
    
}
