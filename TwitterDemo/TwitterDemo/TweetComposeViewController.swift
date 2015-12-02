//
//  TweetComposeViewController.swift
//  TwitterDemo
//
//  Created by Ngo Thanh Tai on 11/29/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit

protocol TweetComposeViewDelegate {
    func tweetComposeView(tweetComposeViewContorller:TweetComposeViewController, response:NSDictionary?)
}

class TweetComposeViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var countBarButton: UIBarButtonItem!
    
    let tweetMaxLength = 140
    
    var delegate: TweetComposeViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextField.delegate = self

        messageTextField.text = ""
        updateTextCount()
        
        messageTextField.becomeFirstResponder()
        
        updateProfile()
    }
    
    func updateProfile() {
        avatarImgView.clipsToBounds = true
        avatarImgView.layer.cornerRadius = 5
        
        if let user = User.currentUser {
            avatarImgView.setImageWithURL(NSURL(string: user.profileImageUrl!)!)
            nameLabel.text = user.name!
            usernameLabel.text = "@\(user.screenName!)"
        }
        
    }

    @IBAction func onCancel(sender: AnyObject) {
        hide()
    }
    
    @IBAction func onTweet(sender: AnyObject) {
        if messageTextField.text.characters.count > 0 {
            TwitterClient.sharedInstance.tweet(messageTextField.text, callBack: { (response, error) -> () in
                if error != nil {
                    print(error)
                    return
                }
                self.delegate?.tweetComposeView(self, response: response)
            })
           
            hide()
        }
    }
    
    func hide(){
        dismissViewControllerAnimated(true, completion: nil)
    }

    func updateTextCount() {
        let strLength = (messageTextField.text?.characters.count)!
        
        UIView.setAnimationsEnabled(false)
        countBarButton.title = "\(tweetMaxLength - strLength)"
        UIView.setAnimationsEnabled(true)
    }
}

extension TweetComposeViewController : UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        updateTextCount()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let currentCharacterCount = messageTextField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        return newLength <= tweetMaxLength
    }
}