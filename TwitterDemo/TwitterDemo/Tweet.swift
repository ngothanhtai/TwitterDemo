//
//  Tweet.swift
//  TwitterDemo
//
//  Created by Ngo Thanh Tai on 11/27/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import Foundation

class Tweet {
    var id: String?
    var user: User?
    var text: String?
    var createdAtString: String?
    var createdAtFullInfoString: String?
    var createdAt: NSDate?
    var isRetweet = false
    var retweetName: String?
    
    var numRetweets = 0
    var numFavorites = 0
    var favorited = false
    var retweeted = false
    
    init(dictionary:NSDictionary) {
        var dic = dictionary

        if let reweetDic = dictionary["retweeted_status"] as? NSDictionary,
            userDic = dictionary["user"] as? NSDictionary {
            let retweetUser = User(dictionary: userDic)
            
            retweetName = retweetUser.name
            
            dic = reweetDic
            
            isRetweet = true
        }
        
        id = "\(dic["id"]!)"
        
        user = User(dictionary: dic["user"] as! NSDictionary)
        text = dic["text"] as? String
        createdAtString = dic["created_at"] as? String
        numRetweets  = dic["retweet_count"] as! Int
        numFavorites  = dic["favorite_count"] as! Int
        favorited  = dic["favorited"] as! Bool
        retweeted  = dic["retweeted"] as! Bool
        
        var formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
        
        formatter = NSDateFormatter()
        formatter.dateFormat = "yy/MM/dd"
        createdAtString = formatter.stringFromDate(createdAt!)
        
        formatter = NSDateFormatter()
        formatter.dateFormat = "yy/MM/dd EEE d HH:mm:ss"
        createdAtFullInfoString = formatter.stringFromDate(createdAt!)
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
    
    func updateFromDic(dic:NSDictionary) {
        let tweet = Tweet(dictionary: dic)
        self.id = tweet.id
        self.user = tweet.user
        self.text = tweet.text

        
        self.numRetweets = tweet.numRetweets
        self.numFavorites = tweet.numFavorites
        self.retweeted = tweet.retweeted
        self.favorited = tweet.favorited
    }
}