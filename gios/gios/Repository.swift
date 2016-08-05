//
//  RepositoryDescription.swift
//  gios
//
//  Created by Yuriy Velichko on 8/2/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import Foundation

class Repository : NSObject, NSCoding
{
    var id          = ""
    var name        = ""
    var descr       = ""
    var date        = ""
    
    var language    = ""
    var rating      = ""
    var forks       = ""
    
    var owner       = ""
    var repo        = ""
    var url         = ""
    
    override init(){        
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        
        id          = decoder.decodeObjectForKey("id"       ) as! String
        name        = decoder.decodeObjectForKey("name"     ) as! String
        descr       = decoder.decodeObjectForKey("descr"    ) as! String
        date        = decoder.decodeObjectForKey("date"     ) as! String
        
        language    = decoder.decodeObjectForKey("language" ) as! String
        rating      = decoder.decodeObjectForKey("rating"   ) as! String
        forks       = decoder.decodeObjectForKey("forks"    ) as! String
        
        owner       = decoder.decodeObjectForKey("owner"    ) as! String
        repo        = decoder.decodeObjectForKey("repo"     ) as! String
        url         = decoder.decodeObjectForKey("url"      ) as! String
    }
    
    func encodeWithCoder(coder: NSCoder) {
        
        coder.encodeObject( id          , forKey: "id"      )
        coder.encodeObject( name        , forKey: "name"    )
        coder.encodeObject( descr       , forKey: "descr"   )
        coder.encodeObject( date        , forKey: "date"    )
        
        coder.encodeObject( language    , forKey: "language")
        coder.encodeObject( rating      , forKey: "rating"  )
        coder.encodeObject( forks       , forKey: "forks"   )
        
        coder.encodeObject( owner       , forKey: "owner"   )
        coder.encodeObject( repo        , forKey: "repo"    )
        coder.encodeObject( url         , forKey: "url"     )
    }
    
    init?( data: AnyObject?)
    {
        super.init()
        
        guard let json = data else {
            return nil
        }
        
        if let id = json["id"] as? Int {
            self.id = String( format:"%d", id )
        }
        
        if let name = json["full_name"] as? String {
            self.name = name
        }
        
        if let json_decr = json["description"] as? String {
            self.descr = json_decr
        }
        
        if let date = json["updated_at"] as? String {
            self.date = date
        }
        
        if let language = json["language"] as? String {
            self.language = language
        }
        
        if let rating = json["score"] as? Int {
            self.rating = String( format:"%d", rating )
        }
        
        if let forks = json["forks_count"] as? Int {
            self.forks = String( format:"%d", forks )
        }
        
        if let json_owner = json["owner"]! {
            
            if let owner = json_owner["login"] as? String {
                self.owner = owner
            }
            
            if let repo = json["name"] as? String {
                self.repo = repo
            }
            
            if let url = json["html_url"] as? String {
                self.url = url
            }
        }
    }
}

extension Repository {
    
    static func initWebserviceResource( url: NSURL ) -> Resource<[Repository]>
    {
        return Resource<[Repository]>(url: url, parseJSON: { json in
        
            var res : [Repository] = []
            
            if let items = json["items"] as? [[String: AnyObject]] {
                for info in items {
                    if let repo = Repository( data: info ) {
                        res.append( repo )
                    }
                }
            }
            
            return res;
        } )
    }
}
