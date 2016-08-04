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
}