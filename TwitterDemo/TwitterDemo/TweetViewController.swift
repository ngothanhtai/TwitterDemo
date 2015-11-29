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
    @IBOutlet weak var usernameLabel:UILabel!
    @IBOutlet weak var messageLabel:UILabel!
    @IBOutlet weak var timeLabel:UILabel!
    @IBOutlet weak var numRetweetsLabel:UILabel!
    @IBOutlet weak var numFavoritesLabel:UILabel!
    @IBOutlet weak var retweetConstraintHeight:NSLayoutConstraint!
    @IBOutlet weak var avatarImgView:UIImageView!
    
    @IBOutlet weak var replyImgView: UIImageView!
    @IBOutlet weak var retweetImgView: UIImageView!
    @IBOutlet weak var favoriteImgView: UIImageView!
    
    var tweet:Tweet?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.avatarImgView.clipsToBounds = true
        self.avatarImgView.layer.cornerRadius = 5
        
       self.updateUI()
    }

    func updateUI() {
        
        if let tweet = tweet {
            self.nameLabel.text = tweet.user?.name
            self.usernameLabel.text = "@\((tweet.user?.screenName)!)"
            self.messageLabel.text = tweet.text
            self.avatarImgView.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
            self.timeLabel.text = tweet.createdAtString
            
            if tweet.isRetweet {
                self.retweetNameLabel.text = "\(tweet.retweetName!) retweeted"
                retweetConstraintHeight.constant = 21.0
            } else {
                retweetConstraintHeight.constant = 0.0
            }
            
            self.numRetweetsLabel.text = "\(tweet.numRetweets)"
            self.numFavoritesLabel.text = "\(tweet.numFavorites)"
            
            self.favoriteImgView.image = UIImage(named: tweet.favorited ? "like-action-on" : "like-action")
            self.retweetImgView.image = UIImage(named: tweet.favorited ? "retweet-action-on" : "retweet-action")
        }
    }

}
