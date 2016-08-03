//
//  RepositoriesViewController.swift
//  gios
//
//  Created by Yuriy Velichko on 8/2/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

class RepositoriesViewController: UITableViewController, UISearchBarDelegate {

    var lastFilter      : String = ""
    var repositories    : [RepositoryDescription] = []
    
    var indicator = UIActivityIndicatorView()
    
    var text : String = ""


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = self.view.center
        tableView.addSubview(indicator)
    }

    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "RepositoryCell", forIndexPath: indexPath ) as! RepositoryCellView
        
        cell.name.text      = repositories[ indexPath.row ].name
        cell.descr.text     = repositories[ indexPath.row ].descr
        cell.date.text      = repositories[ indexPath.row ].date
        
        cell.language.text  = repositories[ indexPath.row ].language
        cell.rating.text    = repositories[ indexPath.row ].rating
        cell.forks.text     = repositories[ indexPath.row ].forks
        
        return cell
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar( searchBar: UISearchBar, textDidChange searchText: String) {
        
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.whiteColor()
        
        text = searchText
        
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, 300 * Int64( NSEC_PER_MSEC )),
            dispatch_get_main_queue()) {
            if self.text == searchText {
                self.loadData( self.text )
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Internal methods
    
    func loadData( filter : String ){
                
        // The mutex is required here because this code can be invoked simultaneously. Need to prevent internal data from data race.
                
        let requestURL = NSURL( string: "https://api.github.com/search/repositories?q=\(filter)&sort=stars&order=desc" )
        let task = NSURLSession.sharedSession().dataTaskWithURL(requestURL!) { (data, response, error) in
    
                    
                if self.lastFilter != filter {
                    self.repositories.removeAll()
                }
                    
                self.onDataRecieved(data)
                    
                self.lastFilter = filter;
        
        
                dispatch_async(dispatch_get_main_queue()) {
                        self.indicator.stopAnimating()
                        self.indicator.hidesWhenStopped = true
                        self.tableView.reloadData()
                }
            }
        
        task.resume()
    }
    
    func onDataRecieved( data: NSData! ) {
                        
        guard let data = data else {
            NSLog ("handleTwitterData() received no data")
            return
        }
                        
        do {
                
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions([]))
            if let items = json["items"] as? [[String: AnyObject]] {
                for repo in items {
        
                    var descr = RepositoryDescription()

                    if let name = repo["full_name"] as? String {
                        descr.name = name
                    }
        
                    if let repo_decr = repo["description"] as? String {
                        descr.descr = repo_decr
                    }
                    
                    if let date = repo["updated_at"] as? String {
                        descr.date = date
                    }
                    
                    if let language = repo["language"] as? String {
                        descr.language = language
                    }
                    
                    if let rating = repo["score"] as? Double {
                        descr.rating = String( format:"%f", rating )
                    }
                    
                    if let forks = repo["forks_count"] as? Int {
                        descr.forks = String( format:"%d", forks )
                    }
        
                    repositories.append( descr )
                }
            }
            
                
                
            /*
                
            userRealNameLabel.text = (tweetDict["name"] as! String)
            userScreenNameLabel.text = (tweetDict["screen_name"] as! String)
            userLocationLabel.text = (tweetDict["location"] as! String)
            userDescriptionLabel.text = (tweetDict["description"] as! String)

*/
            
        }
        catch let error as NSError {
            NSLog ("JSON error: \(error)")
        }
    }
}
