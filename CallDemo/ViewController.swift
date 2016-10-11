//
//  ViewController.swift
//  CallDemo
//
//  Created by 黄河 on 16/7/14.
//  Copyright © 2016年 HH. All rights reserved.
//

import UIKit
import CallKit

class ViewController: UIViewController {

    @IBOutlet weak var console: UITextView!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBAction func call(_ sender: AnyObject) {
        AppDelegate.shared.providerDelegate?.call(handle: phoneNumber.text!)
//        CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: "Hughes.CallDemo.ext") { (err) in
//            print(err?.localizedDescription)
//        }
        
    }
    @IBAction func simulateCall(_ sender: AnyObject) {
        AppDelegate.shared.providerDelegate?.reportIncomingCall(uuid: UUID(), handle: phoneNumber.text!, hasVideo: false, completion: { (err) in
            print(err)
        })
    }
    @IBAction func endCall(_ sender: AnyObject) {
        AppDelegate.shared.providerDelegate?.endCall(uuids: activeCalls){ (uuid) in

        }
    }
    
    var activeCalls:[UUID] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.callStart(noti:)), name: Notification.Name("callStart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.callEnd(noti:)), name: Notification.Name("callEnd"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func callStart(noti:Notification) {
        let text = "call:\(noti.userInfo!["uuid"]!) Started!\n"
        console.text = console.text + text
        activeCalls.append(noti.userInfo!["uuid"]! as! UUID)
    }

    func callEnd(noti:Notification) {
        let text = "call:\(noti.userInfo!["uuid"]!) Ended!\n"
        console.text = console.text + text
    }
}

