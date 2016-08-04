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
    
    let favorites = FavoritesList.sharedFavoritesList
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = self.view.center
        tableView.addSubview(indicator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "RepositoryCell", forIndexPath: indexPath ) as! RepositoryCellView
        
        let repo = repositories[ indexPath.row ]
        
        cell.name.text      = repo.name
        cell.descr.text     = repo.descr
        cell.date.text      = repo.date
        
        cell.language.text  = repo.language
        cell.rating.text    = repo.rating
        cell.forks.text     = repo.forks
         
        cell.favoriteImage.hidden = !favorites.isFavorite( repo.id )
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let lastElement = repositories.count - 1
        if indexPath.row == lastElement {
            // handle your logic here to get more items, add it to dataSource and reload tableview
            
            dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
                self.loadData( self.text )
            }
        }
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
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
        let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
        if let repositoryView = segue.destinationViewController as? RepositoryViewController {
            repositoryView.repository = repositories[indexPath.row]
        }
    }
    
    
    // MARK: - Internal methods
    
    func loadData( filter : String ){
                
        // The mutex is required here because this code can be invoked simultaneously. Need to prevent internal data from data race.
        
        // Page count is 1-based
        let page = ( repositories.count / 100 ) + 1
        let requestURL = NSURL( string: "https://api.github.com/search/repositories?q=\(filter)&sort=stars&order=desc&page=\(page)&per_page=100" )
        
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

                    if let id = repo["id"] as? Int {
                        descr.id = String( format:"%d", id )
                    }
                    
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
                    
                    if let rating = repo["score"] as? Int {
                        descr.rating = String( format:"%d", rating )
                    }
                    
                    if let forks = repo["forks_count"] as? Int {
                        descr.forks = String( format:"%d", forks )
                    }
        
                    if let json_owner = repo["owner"] {
        
                        if let owner = json_owner["login"] as? String {
                            descr.owner = owner
                        }

                        if let repo = repo["name"] as? String {
                            descr.repo = repo
                        }

                        if let url = repo["html_url"] as? String {
                            descr.url = url
                        }
                    }

        
        
                    repositories.append( descr )
                }
            }
        }
        catch let error as NSError {
            NSLog ("JSON error: \(error)")
        }
    }
}
