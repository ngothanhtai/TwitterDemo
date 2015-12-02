//
//  TweetViewController.swift
//  TwitterDemo
//
//  Created by Ngo Thanh Tai on 11/30/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController {

    @IBOutlet weak var retweetNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var numRetweetsLabel: UILabel!
    @IBOutlet weak var numFavoritesLabel: UILabel!
    @IBOutlet weak var retweetConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var avatarImgView: UIImageView!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var tweet: Tweet?
    var delegate: ReplyViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        avatarImgView.clipsToBounds = true
        avatarImgView.layer.cornerRadius = 5
        
        updateUI()
    }

    func updateUI() {
        if let tweet = tweet {
            nameLabel.text = tweet.user?.name
            usernameLabel.text = "@\((tweet.user?.screenName)!)"
            messageLabel.text = tweet.text
            avatarImgView.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
            timeLabel.text = tweet.createdAtFullInfoString
            
            if tweet.isRetweet {
                retweetNameLabel.text = "\(tweet.retweetName!) retweeted"
                retweetConstraintHeight.constant = 21.0
            } else {
                retweetConstraintHeight.constant = 0.0
            }
            
            numRetweetsLabel.text = "\(tweet.numRetweets)"
            numFavoritesLabel.text = "\(tweet.numFavorites)"
            
            retweetButton.enabled = tweet.user?.screenName! != User.currentUser!.screenName
            
            updateImage()
        }
    }
    
    func updateImage() {
        favoriteButton.setImage(UIImage(named: tweet!.favorited ? "like-action-on" : "like-action"), forState: UIControlState.Normal)
        retweetButton.setImage(UIImage(named: tweet!.retweeted ? "retweet-action-on" : "retweet-action"), forState: UIControlState.Normal)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nc = segue.destinationViewController as? UINavigationController {
            if let replyVC = nc.topViewController as? ReplyViewController {
                replyVC.targetUserName = usernameLabel.text!
                replyVC.id = tweet!.id!
                replyVC.delegate = delegate
            }
        }
    }

    @IBAction func onReply(sender: AnyObject) {
        performSegueWithIdentifier("TweetReply", sender: self)
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        if let tweet = tweet {
            if tweet.retweeted == false {
                TwitterClient.sharedInstance.retweet(tweet.id!) { (response, error) -> () in
                    if error == nil {
                        self.tweet?.updateFromDic(response!)
                        self.updateUI()
                    }
                }
            } else {
                TwitterClient.sharedInstance.unretweet(tweet.id!) { (response, error) -> () in
                    if error == nil {
                        self.tweet?.updateFromDic(response!)
                        self.tweet?.numRetweets--
                        if self.tweet?.numRetweets < 0 {
                            self.tweet?.numRetweets = 0
                        }
                        self.tweet?.retweeted = false
                        self.updateUI()
                    }
                }
            }
            
        }
    }
    
    @IBAction func onFavorite(sender: AnyObject) {
        if let tweet = tweet {
            if tweet.favorited == false {
                TwitterClient.sharedInstance.favorite(tweet.id!) { (response, error) -> () in
                    if error == nil {
                        self.tweet?.updateFromDic(response!)
                        self.updateUI()
                    }
                }
            } else {
                TwitterClient.sharedInstance.unfavorite(tweet.id!) { (response, error) -> () in
                    if error == nil {
                        self.tweet?.updateFromDic(response!)
                        self.updateUI()
                    }
                }
            } 
        }
    }
}