//
//  TweetComposeViewController.swift
//  TwitterDemo
//
//  Created by Ngo Thanh Tai on 11/29/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit

class TweetComposeViewController: UIViewController {
    
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var usernameLabel:UILabel!
    @IBOutlet weak var avatarImgView:UIImageView!
    @IBOutlet weak var messageTextField:UITextView!
    @IBOutlet weak var countBarButton:UIBarButtonItem!
    
    let TWEET_MAX_LENGTH:Int = 140
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.messageTextField.delegate = self

        self.messageTextField.text = ""
        self.updateTextCount()
        
        self.messageTextField.becomeFirstResponder()
        
        self.updateProfile()
    }
    
    func updateProfile() {
        
        self.avatarImgView.clipsToBounds = true
        self.avatarImgView.layer.cornerRadius = 5
        
        if let user = User.currentUser {
            self.avatarImgView.setImageWithURL(NSURL(string: user.profileImageUrl!)!)
            self.nameLabel.text = user.name!
            self.usernameLabel.text = "@\(user.screenName!)"
        }
        
    }

    @IBAction func onCancel(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onTweet(sender: AnyObject) {
        
    }

    func updateTextCount() {
        let strLength = (self.messageTextField.text?.characters.count)!
        
        UIView.setAnimationsEnabled(false)
        self.countBarButton.title = "\(TWEET_MAX_LENGTH - strLength)"
        UIView.setAnimationsEnabled(true)
    }
    
    
}

extension TweetComposeViewController : UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        self.updateTextCount()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let currentCharacterCount = self.messageTextField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        return newLength <= TWEET_MAX_LENGTH
    }
}
