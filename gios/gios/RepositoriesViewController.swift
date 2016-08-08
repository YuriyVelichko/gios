//
//  RepositoriesViewController.swift
//  gios
//
//  Created by Yuriy Velichko on 8/2/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

class RepositoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    // MARK: - properties
    
    private var lastFilter      : String = ""
    private var repositories    : [Repository] = []
    private var text            : String = ""
    
    private let favorites = FavoritesManager.sharedFavoritesManager
    
    private var scrollOffset   : CGFloat = 0.0
    
    @IBOutlet weak var tableView: UITableView!
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
        
        tableView.setContentOffset( CGPointMake(0, scrollOffset), animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        scrollOffset = tableView.contentOffset.y
    }

    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showDetails", sender: tableView)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 86.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier( "RepositoryCell", forIndexPath: indexPath ) as! RepositoryCell
        cell.updateView( repositories[ indexPath.row ], favorites : favorites )
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // Upload data on scrol to bottom
        let lastElement = repositories.count - 1
        if indexPath.row == lastElement {
            self.loadData( self.text )
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
        
        Webservice.load( Repository.initWebserviceResource( requestURL ) ){result in
            
            dispatch_async(dispatch_get_main_queue()) {
                if self.lastFilter != filter {
                    self.repositories.removeAll()
                }
                
                self.repositories.appendContentsOf( result ?? [] )
                self.lastFilter = filter;
                
                self.indicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
}
