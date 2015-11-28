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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(tweet:Tweet) {
        self.screenNameLabel.text = tweet.user?.screenName
        self.usernameLabel.text = tweet.user?.name
        self.textMessageLabel.text = tweet.text
        self.avatarImgView.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
    }

}
