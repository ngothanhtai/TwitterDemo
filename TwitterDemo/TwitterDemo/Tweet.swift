//
//  Tweet.swift
//  TwitterDemo
//
//  Created by Ngo Thanh Tai on 11/27/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import Foundation
import SwiftMoment

class Tweet {
    var id:String?
    var user: User?
    var text: String?
    var createdAtString: String?
    var createdAtFullInfoString: String?
    var createdAt: NSDate?
    var isRetweet:Bool = false
    var retweetName:String?
    
    var numRetweets:Int = 0
    var numFavorites:Int = 0
    var favorited:Bool = false
    var retweeted:Bool = false
    
    init(dictionary:NSDictionary) {
        
//        let nsData = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted)
//        print(NSString(data: nsData, encoding: NSUTF8StringEncoding))
        
        var dic = dictionary

        if dictionary["retweeted_status"] != nil {
            let retweetUser = User(dictionary: dic["user"] as! NSDictionary)
            
            self.retweetName = retweetUser.name
            
            dic = dictionary["retweeted_status"] as! NSDictionary
            
            self.isRetweet = true
        }
        
        self.id = "\(dic["id"]!)"
        
        self.user = User(dictionary: dic["user"] as! NSDictionary)
        self.text = dic["text"] as? String
        self.createdAtString = dic["created_at"] as? String
        self.numRetweets  = dic["retweet_count"] as! Int
        self.numFavorites  = dic["favorite_count"] as! Int
        self.favorited  = dic["favorited"] as! Bool
        self.retweeted  = dic["retweeted"] as! Bool
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        self.createdAt = formatter.dateFromString(createdAtString!)
        
        let createdAtMoment = moment(self.createdAt!)
        self.createdAtString = createdAtMoment.format("yy/MM/dd")
        self.createdAtFullInfoString = createdAtMoment.format("yy/MM/dd EEE d HH:mm:ss")
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
    
    func updateFromDic(dic:NSDictionary) {
        print(dic)
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