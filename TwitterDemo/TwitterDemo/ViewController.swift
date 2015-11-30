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

    @IBOutlet weak var loginButton:UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.masksToBounds = true
        
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor(red: 0.306, green: 0.655, blue: 0.878, alpha: 1.0).CGColor
        loginButton.layer.cornerRadius = 5

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

