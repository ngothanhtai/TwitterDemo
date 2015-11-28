//
//  ViewController.swift
//  TwitterDemo
//
//  Created by Ngo Thanh Tai on 11/27/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogin(sender:AnyObject) {
        TwitterClient.sharedInstance.loginWithCompletion { (user, error) -> Void in
            if error != nil {
                print(error)
                return
            }
            
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
    }

}

