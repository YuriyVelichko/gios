//
//  RepositoriesViewController.swift
//  gios
//
//  Created by Yuriy Velichko on 8/2/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

class RepositoriesViewController: UITableViewController, UISearchBarDelegate {

    // MARK: - properties
    
    private var lastFilter      : String = ""
    private var repositories    : [Repository] = []
    private var text            : String = ""
    
    private let favorites = FavoritesManager.sharedFavoritesManager

    // MARK: Views
    
    private var indicator = UIActivityIndicatorView()
    
    // MARK: - UIView API
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(RepositoryCell.self, forCellReuseIdentifier: "RepositoryCell")
        
        let nib = UINib(nibName: "RepositoryCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "RepositoryCell")
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = self.view.center
        self.indicator.hidesWhenStopped = true
        
        tableView.addSubview(indicator)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showDetails", sender: tableView)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier( "RepositoryCell", forIndexPath: indexPath ) as! RepositoryCell
        cell.updateView( repositories[ indexPath.row ], favorites : favorites )
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // Upload data on scrol to bottom
        let lastElement = repositories.count - 1
        if indexPath.row == lastElement {
            dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) ) {
                self.loadData( self.text )
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar( searchBar: UISearchBar, textDidChange searchText: String) {
        
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.whiteColor()
        
        // Do not perform searching for any change - wait a some time maybe user will input other text
        
        text = searchText
        
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, 500 * Int64( NSEC_PER_MSEC )),
            dispatch_get_main_queue()) {
                
            // Run searching only if current reques is equal to initial reques for this task
            if self.text == searchText {
                self.loadData( self.text )
            }
        }
    }
    
    func searchBarSearchButtonClicked( theSearchBar : UISearchBar ) {
        theSearchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing( theSearchBar : UISearchBar ) {
        theSearchBar.resignFirstResponder()
    }
   
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if  let repositoryView = segue.destinationViewController as? RepositoryViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            repositoryView.repository = repositories[indexPath.row]
        }
    }
    
    
    // MARK: - Internal methods
    
    private func loadData( filter : String ){
        
        // TODO:
        // The mutex is required here because this code can be invoked simultaneously. 
        // Need to prevent internal data from data race.
        
        // NOTE: Page count is 1-based
        let pageNum = ( repositories.count / 100 ) + 1
        let urlString = "https://api.github.com/search/repositories?q=\(filter)&sort=stars&order=desc&page=\(pageNum)&per_page=100"
        
        guard let requestURL = NSURL( string: urlString ) else {
            self.showAlertInMainQueue( "Wrong URL for string \(urlString) ")
            dispatch_async(dispatch_get_main_queue()) {
                self.indicator.stopAnimating()
            }
            
            return;
        }
        
  /*      Webservice.load(){result in
            print(result)
        }*/
        
        NSURLSession.sharedSession().dataTaskWithURL(requestURL) { (data, response, error) in
            
            if error != nil {
                self.showAlertInMainQueue( "\(error)" )
                return
            }
        
            if self.lastFilter != filter {
                self.repositories.removeAll()
            }
                
            self.onDataRecieved(data)
            self.lastFilter = filter;        
    
            dispatch_async(dispatch_get_main_queue()) {
                    self.indicator.stopAnimating()
                    self.tableView.reloadData()
            }
        }.resume()
    }
    
    func onDataRecieved( data: NSData! ) {
                        
        guard let data = data else {
            self.showAlertInMainQueue( "Request result is empty" )
            return
        }
                        
        do {
                
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions([]))
            if let items = json["items"] as? [[String: AnyObject]] {
                for info in items {
                    repositories.append( Repository( data: info ) )
                }
            }
        }
        catch let error as NSError {
            self.showAlertInMainQueue("JSON error: \(error)" )
        }
    }
}
