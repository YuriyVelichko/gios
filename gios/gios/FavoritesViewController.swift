//
//  FavoritesViewController.swift
//  gios
//
//  Created by Yuriy Velichko on 8/2/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

class FavoritesViewController: UITableViewController {
    
    // MARK: - properties
    
    private var favorites = FavoritesList.sharedFavoritesList
    
    // MARK: - UIView API

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - UITableViewController API
    
    // MARK: datasource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.list.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier( "FavoriteCell", forIndexPath: indexPath ) as! FavoritesCellView
        
        cell.name.text = favorites.list[indexPath.row].name
        
        return cell
    }
    
    // MARK: editing
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // Delete the row from the data source
            let favorite = favorites.list[indexPath.row]
            favorites.removeFavorite(favorite.id)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        favorites.moveItem( fromIndex: sourceIndexPath.row,
            toIndex: destinationIndexPath.row)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
        if let repositoryView = segue.destinationViewController as? RepositoryViewController {
            repositoryView.repository = favorites.list[indexPath.row]
        }
    }    
}
