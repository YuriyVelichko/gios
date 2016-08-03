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
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
    
    
    var owner   : String! = ""
    var repo    : String! = ""
    var url     : String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicator.startAnimating()
        
        let addButton = UIBarButtonItem( barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "showInBrowser")
        navigationItem.rightBarButtonItem = addButton
        
        loadReadme()
    }

    @IBAction func onAddToFavorites(sender: UIButton) {
        
    }
    
    func showInBrowser() {
        let urlToShow = NSURL( string: url )!
        UIApplication.sharedApplication().openURL( urlToShow )
    }
    
    func loadReadme(){
        
        // GET INFO        
        
        let requestURL = NSURL( string: "https://api.github.com/repos/\(owner)/\(repo)/readme" )
        let task = NSURLSession.sharedSession().dataTaskWithURL(requestURL!) { (data, response, error) in
        
            //DOWNLOAD CONTENT
            
            guard let data = data else {
                NSLog ("handleTwitterData() received no data")
                return
            }
                            
            do {
                    
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions([]))
                if let url = json["download_url"] as? String{
                    
                        let dataURL = NSURL( string: url )
                        let dataTask = NSURLSession.sharedSession().dataTaskWithURL(dataURL!) { (data, response, error) in
                                    
                        let dataString = String(data: data!, encoding: NSUTF8StringEncoding)
                            
                        let md = MarkdownBridge()
                        
                        let html = md.convertToHTML( dataString )
                            
                        dispatch_async( dispatch_get_main_queue() ) {
                            
                            self.webView.loadHTMLString( html, baseURL: nil)                            
                            self.webView.hidden = false
                        }
                    }
                    
                    dataTask.resume()
                }
            }
            catch let error as NSError {
                NSLog ("JSON error: \(error)")
            }

        
        
        }
        
        task.resume()
    }

}
