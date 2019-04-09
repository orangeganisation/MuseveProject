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
            if let collectionView = self.superview as? UICollectionView {
                if collectionView.allowsMultipleSelection {
                    if isSelected {
                        checkedImage.isHidden = false
                        imageView.alpha = 0.5
                    } else {
                        checkedImage.isHidden = true
                        imageView.alpha = 1
                    }
                }
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var checkedImage: UIImageView!
    
    // MARK: - View Methods
    override func awakeFromNib() {
        layer.cornerRadius = 10
    }
    
    // MARK: - Methods
    func configureCell(byData artist: FavoriteArtist?) {
        if let data = artist?.imageData, let image = UIImage(data: data) {
            imageView.image = image
        }
        nameLabel.text = artist?.name
    }
    
    func focusCell(withTransform transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.3) {
            self.transform = transform
        }
    }
}
