//
//  RepositoryViewController.swift
//  gios
//
//  Created by Yuriy Velichko on 8/3/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit
import WebKit
import Foundation
import SVProgressHUD


class RepositoryViewController: UIViewController {
    
    // MARK: - properties
    
    private let favorites = FavoritesManager.sharedFavoritesManager
    
    var repository : Repository = Repository()
    
    // MARK: otlets
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var webViewPanel: UIView!
    
    var webView: WKWebView?

    // MARK: - Actions
    
    @IBAction func onAddToFavorites(sender: UIButton) {
        favorites.addFavorite( repository )
        updateFavoritesButtons()
    }
    
    @IBAction func onRemoveFromFavorites(sender: UIButton) {
        favorites.removeFavorite( repository.id )
        updateFavoritesButtons()
    }
    
    // MARK: - UIView API
    
    override func loadView() {
        super.loadView()
        
        // Tune WKWebView
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        webView = WKWebView(frame: webViewPanel.bounds, configuration: configuration)
        if let theWebView = webView {
            
            // Adapt size on rotation
            theWebView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            webViewPanel.addSubview( theWebView )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationTitle.title = repository.name
        
        let showButton = UIBarButtonItem( barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: #selector(showInBrowser) )
        navigationItem.rightBarButtonItem = showButton
        
        SVProgressHUD.setBackgroundColor( UIColor.grayColor() )
        SVProgressHUD.showWithStatus("Fetching data...")
        
        updateFavoritesButtons()
        
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
        
        Webservice.load( RepositoryViewController.initWebserviceResourceMDURL( requestURL ) ){ url in
            
            guard let readmeURL = url else {
                self.showAlertInMainQueue("Invalid URL for string \(requestURL)")
                return
            }
            
            Webservice.load( RepositoryViewController.initWebserviceResourceMDData( readmeURL ) ) { html in
            
                guard let readmeHTML = html else {
                    self.showAlertInMainQueue("Readme file is empty")
                    return
                }

                dispatch_async( dispatch_get_main_queue() ) {
                    
                    if let theWebView = self.webView {
                        theWebView.loadHTMLString( readmeHTML, baseURL: nil)
                    }
                    
                    self.addButton.hidden = self.favorites.isFavorite( self.repository.id )
                    
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    private func updateFavoritesButtons(){
        let isFavorite = favorites.isFavorite( repository.id )
        addButton.hidden = isFavorite
        removeButton.hidden = !isFavorite
    }
}

extension RepositoryViewController {
    
    static func initWebserviceResourceMDData( url: NSURL ) -> Resource<String>
    {
        return Resource<String>(resourceURL: url, parse: { data in
            
            let dataString  = String(data: data, encoding: NSUTF8StringEncoding)
            let markdown    = MarkdownBridge()
            let html        = markdown.convertToHTML( dataString )
            
            return html;
        } )
    }
    
    static func initWebserviceResourceMDURL( url: NSURL ) -> Resource<NSURL>
    {
        return Resource<NSURL>(url: url, parseJSON: { json in
            
            if  let url     = json["download_url"] as? String,
                let dataURL = NSURL(string:url) {
                    return dataURL
            }
            
            return nil;
        } )
    }
}

