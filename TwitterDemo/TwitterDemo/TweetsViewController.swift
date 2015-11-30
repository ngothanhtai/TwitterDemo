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
    var maxId:String?
    var loadingMoreResult = false
    var loadingViewIndicator:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initControls()

        fetchData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.loadingViewIndicator.hidden = true
        self.loadingViewIndicator.stopAnimating()
        self.loadingMoreResult = false

        self.tableView.reloadData()
    }

    func fetchData(maxId:String = "") {

        var params:NSDictionary = NSDictionary()
        if maxId.isEmpty == false {
            params = [ "max_id": maxId]
        } else {
            refreshControl.beginRefreshing()
        }
        
        TwitterClient.sharedInstance.homeTimelineWithParams(params) { (tweets, error) -> () in
            if error != nil {
                if let error = error,
                let data = error.userInfo["com.alamofire.serialization.response.error.data"] as? NSData
                {
                    let dic = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                 
                    if let errors = dic["errors"],
                    let error = errors[0],
                    let message = error["message"] {
                        self.showAlert(title: "Error message", message: message as! String)
                    }
                }
                return
            }
            
            if maxId.isEmpty == false {
                if var tweets = tweets {
                    tweets.removeFirst()
                    self.tweets.appendContentsOf(tweets)
                }
            } else {
                self.tweets = tweets!
            }
            self.loadingMoreResult = false
            
            self.tableView.reloadData()
            
            self.refreshControl.endRefreshing()
            
            self.updateMaxId()
            
            self.loadingViewIndicator.hidden = true
            self.loadingViewIndicator.stopAnimating()
            
        }
    }
    
    func showAlert(title title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func updateMaxId() {
        if let lastTweet = self.tweets.last {
            self.maxId = lastTweet.id
        }
    }
    
    func initControls() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl = UIRefreshControl()
        refreshControl.endRefreshing()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: .ValueChanged)
        
        self.tableView.insertSubview(refreshControl, atIndex: 0)
        
        self.addLoadingViewIndicatorAtBottomOfTableView()
    }
    
    func onRefresh() {
        self.fetchData()
    }
    
    func addLoadingViewIndicatorAtBottomOfTableView() {
        // add trigger at the end icon
        let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        self.loadingViewIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        self.loadingViewIndicator.hidden = true
        self.loadingViewIndicator.stopAnimating()
        self.loadingViewIndicator.center = tableViewFooter.center
        
        tableViewFooter.addSubview(self.loadingViewIndicator)
        self.tableView.tableFooterView = tableViewFooter
        
        self.loadingViewIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["view": tableViewFooter, "newView": self.loadingViewIndicator]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[view]-(<=0)-[newView(320)]", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views)
        view.addConstraints(horizontalConstraints)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[view]-(<=0)-[newView(50)]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views)
        view.addConstraints(verticalConstraints)
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
        
        if self.loadingMoreResult == false && self.loadingViewIndicator.hidden && indexPath.row == self.tweets.count - 1{
            self.loadingViewIndicator.hidden = false
            self.loadingViewIndicator.startAnimating()
            self.fetchData(self.maxId!)
            self.loadingMoreResult = true
        }
        
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