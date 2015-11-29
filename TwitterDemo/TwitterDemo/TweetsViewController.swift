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
        
        refreshControl.beginRefreshing()
        TwitterClient.sharedInstance.homeTimelineWithParams(nil) { (tweets, error) -> () in
            if error != nil {
                print("homeTimeline", error)
                return
            }
            self.tweets = tweets!
            
            self.tableView.reloadData()
            
            self.refreshControl.endRefreshing()
        }
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
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        
        self.performSegueWithIdentifier("TweetDetail", sender: indexPath)
    }
}
