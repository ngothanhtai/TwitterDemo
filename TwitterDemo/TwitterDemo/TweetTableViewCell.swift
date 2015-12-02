//
//  TweetTableViewCell.swift
//  TwitterDemo
//
//  Created by Ngo Thanh Tai on 11/28/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit

protocol TweetTableViewCellDelegate {
    func tweetTableViewCell (tweetTableViewCell:TweetTableViewCell, replyTo tweet:Tweet)
}

class TweetTableViewCell: UITableViewCell {
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var textMessageLabel: UILabel!
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetConstraintHeight: NSLayoutConstraint!
    
    var tweet: Tweet?
    var delegate: TweetTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()

        avatarImgView.clipsToBounds = true
        avatarImgView.layer.cornerRadius = 5
    }
    
    func updateUI(tweet:Tweet) {
        self.tweet = tweet
        
        screenNameLabel.text = tweet.user?.name
        usernameLabel.text = "@\((tweet.user?.screenName)!)"
        textMessageLabel.text = tweet.text
        avatarImgView.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
        timeLabel.text = tweet.createdAtString
        
        if tweet.isRetweet {
            retweetLabel.text = "\(tweet.retweetName!) retweeted"
            retweetConstraintHeight.constant = 21.0
        } else {
            retweetConstraintHeight.constant = 0.0
        }
        
        retweetButton.enabled = tweet.user?.screenName! != User.currentUser!.screenName
        
        updateImage()
    }
    
    func updateImage() {
        favoriteButton.setImage(UIImage(named: tweet!.favorited ? "like-action-on" : "like-action"), forState: UIControlState.Normal)
        retweetButton.setImage(UIImage(named: tweet!.retweeted ? "retweet-action-on" : "retweet-action"), forState: UIControlState.Normal)
    }
    
    @IBAction func onReply(sender: AnyObject) {
        delegate?.tweetTableViewCell(self, replyTo: tweet!)
    }
    
    @IBAction func onRetweet(sender: AnyObject) {
        if let tweet = tweet {
            if tweet.retweeted == false {
                TwitterClient.sharedInstance.retweet(tweet.id!) { (response, error) -> () in
                    if error == nil {
                        self.tweet?.updateFromDic(response!)
                        self.updateUI(self.tweet!)
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
                        self.updateUI(self.tweet!)
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
                        self.updateUI(self.tweet!)
                    }
                }
            } else {
                TwitterClient.sharedInstance.unfavorite(tweet.id!) { (response, error) -> () in
                    if error == nil {
                        self.tweet?.updateFromDic(response!)
                        self.updateUI(self.tweet!)
                    }
                }
            }
        }
    }
}