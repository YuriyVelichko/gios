//
//  Webservice.swift
//  gios
//
//  Created by Yuriy Velichko on 8/5/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

struct Resource<A> {
    let resourceURL : NSURL
    let parse       : NSData -> A?
}

extension Resource {
    init(url: NSURL, parseJSON: AnyObject -> A?) {
        self.resourceURL = url
        self.parse = { data in
            let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
            return json.flatMap(parseJSON)
        }
    }
}

final class Webservice {
    static func load<A>(resource: Resource<A>, completion: (A?) -> ()) {
        NSURLSession.sharedSession().dataTaskWithURL(resource.resourceURL) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            
            completion(resource.parse(data))
        }.resume()
    }
}