//
//  RepositoryCellView.swift
//  gios
//
//  Created by Yuriy Velichko on 8/3/16.
//  Copyright © 2016 Yuriy Velichko. All rights reserved.
//

import UIKit

class RepositoryCellView: UITableViewCell {
    
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var descr: UILabel!
    @IBOutlet weak var date: UILabel!

    @IBOutlet weak var language: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var forks: UILabel!
}
