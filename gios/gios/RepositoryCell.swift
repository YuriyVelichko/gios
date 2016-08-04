//
//  RepositoryCellView.swift
//  gios
//
//  Created by Yuriy Velichko on 8/3/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

class RepositoryCell: UITableViewCell {
    
    // MARK: - properties
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var descr: UILabel!
    @IBOutlet weak var date: UILabel!

    @IBOutlet weak var language: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var forks: UILabel!
    
    @IBOutlet weak var favoriteImage: UIImageView!
    
    // Mark - This class API
    
    func updateView(repository : Repository, favorites : FavoritesManager){
        
        name.text      = repository.name
        descr.text     = repository.descr
        date.text      = repository.date
        
        language.text  = repository.language
        rating.text    = repository.rating
        forks.text     = repository.forks
        
        favoriteImage.hidden = !favorites.isFavorite( repository.id )
    }
}
