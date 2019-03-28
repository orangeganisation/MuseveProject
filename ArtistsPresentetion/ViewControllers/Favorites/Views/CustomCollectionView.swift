//
//  customCollectionView.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/21/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit

class CustomCollectionView: UICollectionView {
    
    // MARK: - Vars
    override var allowsMultipleSelection: Bool {
        didSet {
            DataStore.shared.multiplySelectionIsAllowed = allowsMultipleSelection
        }
    }

}
