//
//  RepositoriesViewController.swift
//  gios
//
//  Created by Yuriy Velichko on 8/2/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

class RepositoriesViewController: UITableViewController, UISearchBarDelegate {

    var repositories : [RepositoryDescription] = []
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier( "RepositoryCell", forIndexPath: indexPath )
        
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
                self.onLoadingData()
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
    
    func onLoadingData() {
        NSLog( text )
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        
        dispatch_async(queue) {
        
            self.loadData( self.text )
        
            dispatch_async(dispatch_get_main_queue()) {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
                self.tableView.reloadData()
            }
        }
    }
    
    func loadData( filter : String ){
    }
}
