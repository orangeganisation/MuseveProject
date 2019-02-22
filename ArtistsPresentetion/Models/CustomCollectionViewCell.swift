//
//  CustomCollectionViewCell.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/20/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet{
            if FavoritesViewController.multiplySelectionIsAllowed {
                if isSelected {
                    self.checkedImage.isHidden = false
                    self.imageView.alpha = 0.5
                } else {
                    self.checkedImage.isHidden = true
                    self.imageView.alpha = 1
                }
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 10.0
            imageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkedImage: UIImageView! {
        didSet {
            checkedImage.image = checkedImage.image?.withRenderingMode( .alwaysTemplate)
            checkedImage.tintColor = #colorLiteral(red: 0.6219168305, green: 0.112661697, blue: 0.3066232204, alpha: 1)
        }
    }
}
