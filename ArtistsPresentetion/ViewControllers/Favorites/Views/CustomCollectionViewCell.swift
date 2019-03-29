//
//  CustomCollectionViewCell.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/20/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit

final class CustomCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Vars
    override var isSelected: Bool {
        didSet{
            if DataStore.shared.multiplySelectionIsAllowed {
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
    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 10.0
            imageView.clipsToBounds = true
        }
    }
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var checkedImage: UIImageView! {
        didSet {
            checkedImage.image = checkedImage.image?.withRenderingMode( .alwaysTemplate)
            checkedImage.tintColor = #colorLiteral(red: 0.6219168305, green: 0.112661697, blue: 0.3066232204, alpha: 1)
        }
    }
    
    static func configuredCell(of collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        let artist = CoreDataManager.instance.fetchedResultsController.object(at: indexPath) as! FavoriteArtist
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteArtistCell", for: indexPath) as! CustomCollectionViewCell
        if let data = artist.image_data, let image = UIImage(data: data) {
            cell.imageView.image = image
        }
        cell.nameLabel.text = artist.name
        return cell
    }
}
