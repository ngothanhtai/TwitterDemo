//
//  TweetsViewController.swift
//  TwitterDemo
//
//  Created by Ngo Thanh Tai on 11/28/15.
//  Copyright © 2015 Ngo Thanh Tai. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var tweets: [Tweet] = [Tweet]()
    var refreshControl: UIRefreshControl!
    var maxId: String?
    var loadingMoreResult = false
    var loadingViewIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initControls()
        fetchData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        loadingViewIndicator.hidden = true
        loadingViewIndicator.stopAnimating()
        loadingMoreResult = false

        tableView.reloadData()
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
                data = error.userInfo["com.alamofire.serialization.response.error.data"] as? NSData
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
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func updateMaxId() {
        if let lastTweet = tweets.last {
            maxId = lastTweet.id
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
        
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        addLoadingViewIndicatorAtBottomOfTableView()
    }
    
    func onRefresh() {
        fetchData()
    }
    
    func addLoadingViewIndicatorAtBottomOfTableView() {
        // add trigger at the end icon
        let tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        loadingViewIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadingViewIndicator.hidden = true
        loadingViewIndicator.stopAnimating()
        loadingViewIndicator.center = tableViewFooter.center
        
        tableViewFooter.addSubview(loadingViewIndicator)
        tableView.tableFooterView = tableViewFooter
        
        loadingViewIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["view": tableViewFooter, "newView": loadingViewIndicator]
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
                tweetVC.tweet = tweets[selectedIndexPath.row]
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
        cell.updateUI(tweets[indexPath.row])
        cell.delegate = self
        
        if !loadingMoreResult && loadingViewIndicator.hidden && indexPath.row == tweets.count - 1{
            loadingViewIndicator.hidden = false
            loadingViewIndicator.startAnimating()
            fetchData(maxId!)
            loadingMoreResult = true
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        performSegueWithIdentifier("TweetDetail", sender: indexPath)
    }
}

extension TweetsViewController:TweetComposeViewDelegate {
    func tweetComposeView(tweetComposeViewContorller: TweetComposeViewController, response: NSDictionary?) {
        if response != nil {
            tweets.insert(Tweet(dictionary: response!), atIndex: 0)
            tableView.reloadData()
        }
    }
}

extension TweetsViewController:ReplyViewControllerDelegate {
    
    func replyView(replyViewController: ReplyViewController, response: NSDictionary?) {
        if response != nil {
            tweets.insert(Tweet(dictionary: response!), atIndex: 0)
            tableView.reloadData()
        }
    }

}

extension TweetsViewController : TweetTableViewCellDelegate {
    func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, replyTo tweet: Tweet) {
        performSegueWithIdentifier("TweetReply", sender: tweet)
    }
}