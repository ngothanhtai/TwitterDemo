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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initControls()

        TwitterClient.sharedInstance.homeTimelineWithParams(nil) { (tweets, error) -> () in
            if error != nil {
                print("homeTimeline", error)
                return
            }
            self.tweets = tweets!
            
            self.tableView.reloadData()
            print(tweets)
        }
    }
    
    func initControls() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func logout(sender:AnyObject) {
        User.currentUser?.logout()
    }
}

extension TweetsViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TwitterCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.tweets[indexPath.row].user?.name
        return cell
    }
}
