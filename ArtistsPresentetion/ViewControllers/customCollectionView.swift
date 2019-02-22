//
//  customCollectionView.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/21/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit

class customCollectionView: UICollectionView {
    
    override var allowsMultipleSelection: Bool {
        didSet {
            FavoritesViewController.multiplySelectionIsAllowed = allowsMultipleSelection
        }
    }

}
