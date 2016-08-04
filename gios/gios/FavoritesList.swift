//
//  FavoritesList.swift
//  gios
//
//  Created by Yuriy Velichko on 7/27/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

class FavoritesList {
    
    // MARK: - properties
    
    static let sharedFavoritesList = FavoritesList()
    
    private(set) var list : [RepositoryDescription] = []
    
    // MARK: - initializer 
    
    init()
    {
        if let data = NSData(contentsOfURL: FavoritesList.dataFileURL()) {
            if let object = NSKeyedUnarchiver.unarchiveObjectWithData( data ) as? [RepositoryDescription] {
                list = object
            }
        }
    }
    
    // MARK: - API
    
    func isFavorite(repoId: String) -> Bool {
        for it in list {
            if it.id == repoId {
            return true
            }
        }
        
        return false
    }
    
    func addFavorite(repo: RepositoryDescription) {
        if !isFavorite(repo.id) {
            list.append(repo)
            saveFavorites()
        }
    }
    
    func removeFavorite(repoId: String) {
        for index in 0..<list.count {
            if list[index].id == repoId {
                list.removeAtIndex( index )
                saveFavorites()
                return
            }
        }
    }
    
    func moveItem(fromIndex from: Int, toIndex to: Int) {
        let item = list[from]
        list.removeAtIndex(from)
        list.insert(item, atIndex: to)
        saveFavorites()
    }
    
     // MARK: - Internal Methods
    
    private func saveFavorites() {
        let data = NSKeyedArchiver.archivedDataWithRootObject( list )
        data.writeToURL( FavoritesList.dataFileURL(), atomically: true)
    }
        
    private static func dataFileURL() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask)
        return urls.first!.URLByAppendingPathComponent("favorites.arcive")
    }
}
