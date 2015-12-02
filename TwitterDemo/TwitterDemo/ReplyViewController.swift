//
//  ReplyViewController.swift
//  TwitterDemo
//
//  Created by Ngo Thanh Tai on 11/30/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit

protocol ReplyViewControllerDelegate {
    func replyView(replyViewController:ReplyViewController, response:NSDictionary?)
}

class ReplyViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var countBarButton: UIBarButtonItem!
    
    let tweetReplyMaxLength = 140
    
    var targetUserName = ""
    var id = ""
    var delegate: ReplyViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextField.becomeFirstResponder()
        
        messageTextField.delegate = self
        
        messageTextField.text = "\(targetUserName) "
        
        messageTextField.becomeFirstResponder()
        
        updateTextCount()
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
    
    @IBAction func onReply(sender: AnyObject) {
        if messageTextField.text.characters.count > 0 {
            TwitterClient.sharedInstance.reply(messageTextField.text, id: id, callBack: { (response, error) -> () in
                self.delegate?.replyView(self, response: response!)
                self.hide()
            })
        }
    }

    func hide() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateTextCount() {
        let strLength = (messageTextField.text?.characters.count)!
        
        UIView.setAnimationsEnabled(false)
        countBarButton.title = "\(tweetReplyMaxLength - strLength)"
        UIView.setAnimationsEnabled(true)
    }
}

extension ReplyViewController : UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        updateTextCount()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let currentCharacterCount = messageTextField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        return newLength <= tweetReplyMaxLength
    }
}