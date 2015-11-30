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
    
    func tweet(message:String, callBack: (response:NSDictionary?, error:NSError?) -> ()) {
        
        let params = [
            "status": message
        ]

        TwitterClient.sharedInstance.POST("https://api.twitter.com/1.1/statuses/update.json", parameters: params, success: { (requestOperation:AFHTTPRequestOperation, response:AnyObject) -> Void in
                callBack(response: response as? NSDictionary, error: nil)
            }) { (requestOperation:AFHTTPRequestOperation?, error:NSError) -> Void in
                callBack(response: nil, error: error)
        }
    }
    
    func reply(message:String, id:String, callBack: (response:NSDictionary?, error:NSError?) -> ()) {
        
        let params = [
            "status": message,
            "in_reply_to_status_id": id
        ]
        
        TwitterClient.sharedInstance.POST("https://api.twitter.com/1.1/statuses/update.json", parameters: params, success: { (requestOperation:AFHTTPRequestOperation, response:AnyObject) -> Void in
            callBack(response: response as? NSDictionary, error: nil)
            }) { (requestOperation:AFHTTPRequestOperation?, error:NSError) -> Void in
                callBack(response: nil, error: error)
        }
    }
    
    func retweet(id:String, callBack: (response:NSDictionary?, error:NSError?) -> ()) {
   
        TwitterClient.sharedInstance.POST("https://api.twitter.com/1.1/statuses/retweet/\(id).json", parameters: nil, success: { (requestOperation:AFHTTPRequestOperation, response:AnyObject) -> Void in
            callBack(response: response as? NSDictionary, error: nil)
            }) { (requestOperation:AFHTTPRequestOperation?, error:NSError) -> Void in
                callBack(response: nil, error: error)
        }
    }
    
    func unretweet(id:String, callBack: (response:NSDictionary?, error:NSError?) -> ()) {
        
        TwitterClient.sharedInstance.GET("https://api.twitter.com/1.1/statuses/show/\(id).json?include_my_retweet=1", parameters: nil, success: { (reqOperation: AFHTTPRequestOperation, response: AnyObject) -> Void in

            
            if
            let dic = response as? NSDictionary,
            let current_user_retweet = dic["current_user_retweet"],
            let retweet_id = current_user_retweet["id_str"]
            {
                TwitterClient.sharedInstance.POST("https://api.twitter.com/1.1/statuses/destroy/\(retweet_id!).json", parameters: nil, success: { (requestOperation:AFHTTPRequestOperation, response:AnyObject) -> Void in
                    callBack(response: response as? NSDictionary, error: nil)
                    }) { (requestOperation:AFHTTPRequestOperation?, error:NSError) -> Void in
                        callBack(response: nil, error: error)
                }
            }
            
            }) { (reqOperation: AFHTTPRequestOperation?, error: NSError) -> Void in
                callBack(response: nil, error: error)
        }
    }
    
    func favorite(id:String, callBack: (response:NSDictionary?, error:NSError?) -> ()) {
        let params = [
            "id": id
        ]
        TwitterClient.sharedInstance.POST("https://api.twitter.com/1.1/favorites/create.json", parameters: params, success: { (requestOperation:AFHTTPRequestOperation, response:AnyObject) -> Void in
            callBack(response: response as? NSDictionary, error: nil)
            }) { (requestOperation:AFHTTPRequestOperation?, error:NSError) -> Void in
                callBack(response: nil, error: error)
        }
    }
    
    func unfavorite(id:String, callBack: (response:NSDictionary?, error:NSError?) -> ()) {
        let params = [
            "id": id
        ]
        TwitterClient.sharedInstance.POST("https://api.twitter.com/1.1/favorites/destroy.json", parameters: params, success: { (requestOperation:AFHTTPRequestOperation, response:AnyObject) -> Void in
            callBack(response: response as? NSDictionary, error: nil)
            }) { (requestOperation:AFHTTPRequestOperation?, error:NSError) -> Void in
                callBack(response: nil, error: error)
        }
    }
}
