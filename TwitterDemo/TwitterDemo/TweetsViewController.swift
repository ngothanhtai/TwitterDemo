//
//  TweetsViewController.swift
//  TwitterDemo
//
//  Created by Ngo Thanh Tai on 11/28/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {
    @IBOutlet weak var tableView:UITableView!
    var tweets: [Tweet] = [Tweet]()
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initControls()

        fetchData()
    }

    func fetchData() {
        
        self.tableView.hidden = tweets.count == 0
        refreshControl.beginRefreshing()
        TwitterClient.sharedInstance.homeTimelineWithParams(nil) { (tweets, error) -> () in
            if error != nil {
                print("homeTimeline", error)
                return
            }
            self.tableView.hidden = false
            self.tweets = tweets!
            
            self.tableView.reloadData()
            
            self.refreshControl.endRefreshing()
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    
    func initControls() {
        
        

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl = UIRefreshControl()
        refreshControl.endRefreshing()
        refreshControl.addTarget(self, action: "fetchData", forControlEvents: .ValueChanged)
        
        self.tableView.insertSubview(refreshControl, atIndex: 0)
    }

    @IBAction func logout(sender:AnyObject) {
        User.currentUser?.logout()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tweetVC = segue.destinationViewController as? TweetViewController {
            if let selectedIndexPath = sender as? NSIndexPath {
                tweetVC.tweet = self.tweets[selectedIndexPath.row]
                tweetVC.delegate = self
            }
        } else if let navigationController = segue.destinationViewController as? UINavigationController {
            if let tweetCompose = navigationController.topViewController as? TweetComposeViewController {
                tweetCompose.delegate = self
            } else if let tweetReply = navigationController.topViewController as? ReplyViewController {
                let tweet = sender as! Tweet
                tweetReply.targetUserName = "@\(tweet.user!.screenName!) "
                tweetReply.id = tweet.id!
                tweetReply.delegate = self
            }
        }
    }
}

extension TweetsViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TwitterCell", forIndexPath: indexPath) as! TweetTableViewCell
        cell.updateUI(self.tweets[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        
        self.performSegueWithIdentifier("TweetDetail", sender: indexPath)
    }
}

extension TweetsViewController:TweetComposeViewDelegate {
    func tweetComposeView(tweetComposeViewContorller: TweetComposeViewController, response: NSDictionary?) {
        if response != nil {
            self.tweets.insert(Tweet(dictionary: response!), atIndex: 0)
            self.tableView.reloadData()
        }
    }
}

extension TweetsViewController:ReplyViewDelegate {
    
    func replyView(replyViewController: ReplyViewController, response: NSDictionary?) {
        if response != nil {
            self.tweets.insert(Tweet(dictionary: response!), atIndex: 0)
            self.tableView.reloadData()
        }
    }

}

extension TweetsViewController : TweetTableViewCellDelegate {
    func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, replyTo tweet: Tweet) {
        self.performSegueWithIdentifier("TweetReply", sender: tweet)
    }
}