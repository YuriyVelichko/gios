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
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    
    var owner   : String! = ""
    var repo    : String! = ""
    var url     : String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingIndicator.startAnimating()
        
        let addButton = UIBarButtonItem( barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "insertNewObject")
        navigationItem.rightBarButtonItem = addButton
        
        loadReadme()
    }

    @IBAction func onAddToFavorites(sender: UIButton) {
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

                        NSLog( dataString! )
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
