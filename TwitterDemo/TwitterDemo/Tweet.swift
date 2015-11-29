//
//  Tweet.swift
//  TwitterDemo
//
//  Created by Ngo Thanh Tai on 11/27/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import Foundation
import SwiftMoment

struct Tweet {
    var user: User?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?
    var momentTime:String?
    var isRetweet:Bool = false
    var retweetName:String?
    
    var numRetweets:Int = 0
    var numFavorites:Int = 0
    var favorited:Bool = false
    var retweeted:Bool = false
    
    init(dictionary:NSDictionary) {
        
        let nsData = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted)
        print(NSString(data: nsData, encoding: NSUTF8StringEncoding))
        
        var dic = dictionary
        if dictionary["retweeted_status"] != nil {
            let retweetUser = User(dictionary: dic["user"] as! NSDictionary)
            
            self.retweetName = retweetUser.name
            
            dic = dictionary["retweeted_status"] as! NSDictionary
            
            self.isRetweet = true
        }
        
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
        
        let yesterday = moment(self.createdAt!)
        self.momentTime = yesterday.format()
    }
    
    static func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
}