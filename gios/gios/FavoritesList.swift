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
    
    private(set) var favorites:[String]
    
    private let keyFavorites : String  = "favorites"
    
    init()
    {
        let defaults        = NSUserDefaults.standardUserDefaults()
        let storedFavorites = defaults.objectForKey( keyFavorites ) as? [String]
        
        favorites = storedFavorites != nil ? storedFavorites! : []
    }
    
    func addFavorite(repoId: String) {
        if !favorites.contains(repoId) {
            favorites.append(repoId)
            saveFavorites()
        }
    }
    
    func isFavorite(repoId: String) -> Bool {
        return favorites.contains( repoId )
    }    
    
    func removeFavorite(repoId: String) {
        if let index = favorites.indexOf(repoId) {
            favorites.removeAtIndex(index)
            saveFavorites()
        }
    }
    
    private func saveFavorites() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(favorites, forKey: keyFavorites )
        defaults.synchronize()
    }
    
    func moveItem(fromIndex from: Int, toIndex to: Int) {
        let item = favorites[from]
        favorites.removeAtIndex(from)
        favorites.insert(item, atIndex: to)
        saveFavorites()
    }
}
