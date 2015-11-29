//
//  TweetTableViewCell.swift
//  TwitterDemo
//
//  Created by Ngo Thanh Tai on 11/28/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    @IBOutlet weak var retweetLabel:UILabel!
    @IBOutlet weak var screenNameLabel:UILabel!
    @IBOutlet weak var usernameLabel:UILabel!
    @IBOutlet weak var textMessageLabel:UILabel!
    @IBOutlet weak var avatarImgView:UIImageView!
    @IBOutlet weak var timeLabel:UILabel!

    @IBOutlet weak var retweetConstraintHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.avatarImgView.clipsToBounds = true
        self.avatarImgView.layer.cornerRadius = 5
    }
    
    func updateUI(tweet:Tweet) {
        self.screenNameLabel.text = tweet.user?.name
        self.usernameLabel.text = "@\((tweet.user?.screenName)!)"
        self.textMessageLabel.text = tweet.text
        self.avatarImgView.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
//        self.timeLabel.text = tweet.createdAtString
        
        if tweet.retweeted {
            retweetLabel.text = "\(tweet.retweetName) retweeted"
            retweetConstraintHeight.constant = 21.0
        } else {
            retweetConstraintHeight.constant = 0.0
        }
    }

}
