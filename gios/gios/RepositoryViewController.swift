//
//  RepositoryViewController.swift
//  gios
//
//  Created by Yuriy Velichko on 8/3/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit
import Foundation

class RepositoryViewController: UIViewController {
    
    // MARK: - properties
    
    private let favorites = FavoritesList.sharedFavoritesList
    
    var repository : RepositoryDescription = RepositoryDescription()
    
    // MARK: otlets
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: - Actions
    
    @IBAction func onAddToFavorites(sender: UIButton) {
        favorites.addFavorite( repository )
        addButton.hidden = true
    }
    
    // MARK: - UIView API
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicator.startAnimating()
        
        let addButton = UIBarButtonItem( barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "showInBrowser")
        navigationItem.rightBarButtonItem = addButton
        
        loadReadme()
    }
    
    // MARK: - This class API
    
    func showInBrowser() {
        let urlToShow = NSURL( string: repository.url )!
        UIApplication.sharedApplication().openURL( urlToShow )
    }
    
    private func loadReadme(){
        
        // GET INFO        
        
        guard let requestURL = NSURL( string: "https://api.github.com/repos/\(repository.owner)/\(repository.repo)/readme" ) else {
            return
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(requestURL) { (data, response, error) in
        
            // DOWNLOAD CONTENT
            
            guard let data = data else {
                self.showAlertInMainQueue("Readme file is empty")
                return
            }
                            
            do {
                    
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions([]))
                if let url = json["download_url"] as? String{
                    
                    guard let dataURL = NSURL(string:url) else {
                        self.showAlertInMainQueue("Invalid URL for string \(url)")
                        return
                    }
                    
                    let dataTask = NSURLSession.sharedSession().dataTaskWithURL(dataURL) { (data, response, error) in
                        let dataString  = String(data: data!, encoding: NSUTF8StringEncoding)
                        let markdown    = MarkdownBridge()
                        let html        = markdown.convertToHTML( dataString )
                            
                        dispatch_async( dispatch_get_main_queue() ) {
                            
                            self.webView.loadHTMLString( html, baseURL: nil)                            
                            self.webView.hidden = false
                            self.addButton.hidden = self.favorites.isFavorite( self.repository.id )
                            
                            self.loadingIndicator.stopAnimating()
                        }
                    }
                    
                    dataTask.resume()
                }
            }
            catch let error as NSError {
                dispatch_async(dispatch_get_main_queue()) {
                    self.showAlertInMainQueue("JSON error: \(error)" )
                }
            }
        }
        
        task.resume()
    }
}
