//
//  TwitterClient.swift
//  TwitterDemo
//
//  Created by Ngo Thanh Tai on 11/27/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let twitterConsumerKey = "OObCvXjd1L9WvhLzyqW1b6acb"
let twitterConsumerSecret = "1H1F3wudFIjIhuPtIpKt3ADj0R5UcuYgu6bxJEOB4N3pQluggJ"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion:((user:User?, error:NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        
        return Static.instance
    }
    
    func loginWithCompletion(completion: (user:User?, error:NSError?) -> Void) {
        
        self.loginCompletion = completion
        self.requestSerializer.removeAccessToken()
        self.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterdemo://oauth"), scope: nil,
            success: { (credential:BDBOAuth1Credential!) -> Void in
                
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(credential.token)")!
            UIApplication.sharedApplication().openURL(authURL)
                
        }, failure:  { (error:NSError!) -> Void in
            
            self.loginCompletion?(user: nil, error: error)
            
        })
    }
    
    func homeTimelineWithParams(params:NSDictionary?, competion: (tweets:[Tweet]?, error:NSError?) -> ()) {
        
        TwitterClient.sharedInstance.GET("1.1/statuses/home_timeline.json", parameters: params,
            success: { (requestOperation:AFHTTPRequestOperation, response:AnyObject!) -> Void in
                //                        print("\(response)")
                
                let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                
                competion(tweets: tweets, error: nil)
            },
            failure: { (requestOperation:AFHTTPRequestOperation?, error:NSError) -> Void in
                
                competion(tweets: nil, error: error)
                
            }
        )
        
    }
    
    func openURL(url:NSURL) {
        self.fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query!), success: { (credential:BDBOAuth1Credential!) -> Void in
            
            self.requestSerializer.saveAccessToken(credential)
            self.GET("1.1/account/verify_credentials.json", parameters: nil,
                success: { (requestOperation:AFHTTPRequestOperation, response:AnyObject!) -> Void in
                    //                        print("\(response)")
                    
                    let user = User(dictionary: response as! NSDictionary)
                    User.currentUser = user
                    self.loginCompletion?(user: user, error: nil)
                },
                failure: { (requestOperation:AFHTTPRequestOperation?, error:NSError) -> Void in
                    self.loginCompletion?(user: nil, error: error)
                }
            )
            
            },
            failure: { (error:NSError!) -> Void in
                self.loginCompletion?(user: nil, error: error)
            }
        )

        
    }
}
