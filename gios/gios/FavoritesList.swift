//
//  FavoritesList.swift
//  gios
//
//  Created by Yuriy Velichko on 7/27/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import Foundation
import UIKit

class FavoritesList {
    
    static let sharedFavoritesList = FavoritesList()
    
    private(set) var favorites : [RepositoryDescription] = []
    
    init()
    {
        if let data = NSData(contentsOfURL: FavoritesList.dataFileURL()) {
            
            if let f = NSKeyedUnarchiver.unarchiveObjectWithData( data ) {
                favorites = f as! [RepositoryDescription]
            }
        }
    }
    
    func addFavorite(repo: RepositoryDescription) {
        if !isFavorite(repo.id) {
            favorites.append(repo)
            saveFavorites()
        }
    }
    
    func isFavorite(repoId: String) -> Bool {
        
        for it in favorites {
            if it.id == repoId {
                return true
            }
        }
        
        return false
    }    
    
    func removeFavorite(repoId: String) {
        
        for index in 0..<favorites.count {
            if favorites[index].id == repoId {
                favorites.removeAtIndex( index )
                saveFavorites()
                return
            }
        }
    }
    
    private func saveFavorites() {
        let data = NSKeyedArchiver.archivedDataWithRootObject( favorites )
        data.writeToURL( FavoritesList.dataFileURL(), atomically: true)
    }
    
    func moveItem(fromIndex from: Int, toIndex to: Int) {
        let item = favorites[from]
        favorites.removeAtIndex(from)
        favorites.insert(item, atIndex: to)
        saveFavorites()
    }
    
    static func dataFileURL() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask)
        return urls.first!.URLByAppendingPathComponent("favorites.arcive")
    }
}
