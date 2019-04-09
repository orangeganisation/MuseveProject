//
//  FavoritesViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/15/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import CoreData
import UIKit

final class FavoritesViewController: UIViewController {
    
    // MARK: - Vars & Lets
    private let coreDataInstance = CoreDataManager.instance
    private let dataStore = DataStore.shared
    private var removingList = [String]() {
        didSet {
            navigationBarTitle.title = !removingList.isEmpty ?  "\("Selected artists:".localized()) \(removingList.count)" : "Select artists".localized()
        }
    }
    private var numberOfFavoriteArtists: Int {
        if let section = coreDataInstance.fetchedResultsController.sections?.first {
            return section.numberOfObjects
        } else {
            return 0
        }
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var favoriteCollectionView: UICollectionView!
    @IBOutlet private weak var haveNoFavoritesLabel: UILabel!
    @IBOutlet private weak var editButton: UIBarButtonItem!
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var navigationBarTitle: UINavigationItem!
    @IBOutlet private weak var trashButton: UIBarButtonItem! {
        didSet {
            trashButton.isEnabled = !removingList.isEmpty
        }
    }
    
    
    // MARK: - Actions
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        navigationItem.leftBarButtonItem = nil
        navigationItem.setRightBarButton(editButton, animated: true)
        deselectAllArtists()
        favoriteCollectionView.allowsMultipleSelection = false
        navigationBarTitle.title = "Favorites".localized()
    }
    
    @IBAction func trashAction(_ sender: UIBarButtonItem) {
        if favoriteCollectionView.indexPathsForSelectedItems != nil {
            let removingArtistString = removingList.count == 1 ? "artist".localized() : "artists".localized()
            let alert = UIAlertController(title: "Removing".localized(), message: "\("Remove".localized()) \(removingList.count) \(removingArtistString)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Remove".localized(), style: .destructive, handler: { (action) in
                for artistName in self.removingList {
                    self.coreDataInstance.deleteObject(withName: artistName, forEntity: StringConstant.favoriteArtistEntity, completion: {
                        do {
                            try self.coreDataInstance.fetchedResultsController.performFetch()
                        } catch {
                            print(error)
                        }
                        if let currentArtist = self.dataStore.currentFoundArtist, artistName == currentArtist.name {
                            self.coreDataInstance.artistIsInDataBase = false
                        }
                    })
                }
                if let selectedIndeces = self.favoriteCollectionView.indexPathsForSelectedItems {
                    self.deselectAllArtists()
                    self.favoriteCollectionView.deleteItems(at: selectedIndeces)
                    self.coreDataInstance.saveContext()
                }
                self.configureAfterRemovingFavorites()
            }))
            alert.addAction(UIAlertAction(title: StringConstant.cancel, style: .cancel))
            present(alert, animated: true)
        }
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        navigationBarTitle.title = "Select artists".localized()
        navigationItem.setLeftBarButton(cancelButton, animated: true)
        navigationItem.setRightBarButton(trashButton, animated: true)
        favoriteCollectionView.allowsMultipleSelection = true
    }
    
    // MARK: - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setRightBarButton(editButton, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationItem.setLeftBarButton(nil, animated: true)
        navigationItem.setRightBarButton(editButton, animated: true)
        deselectAllArtists()
        navigationBarTitle.title = "Favorites".localized()
        favoriteCollectionView.allowsMultipleSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        do {
            try coreDataInstance.fetchedResultsController.performFetch()
            favoriteCollectionView.reloadData()
        } catch {
            print(error)
        }
        if numberOfFavoriteArtists == 0 {
            if navigationItem.rightBarButtonItem == editButton {
                editButton.isEnabled = false
            }
            editButton.isEnabled = false
            haveNoFavoritesLabel.isHidden = false
            favoriteCollectionView.isHidden = true
        } else {
            if navigationItem.rightBarButtonItem == editButton {
                editButton.isEnabled = true
            }
            editButton.isEnabled = true
            favoriteCollectionView.isHidden = false
            haveNoFavoritesLabel.isHidden = true
        }
    }
    
    // MARK: - MyTools
    func configureAfterRemovingFavorites() {
        trashButton.isEnabled = false
        navigationItem.leftBarButtonItem = nil
        navigationItem.setRightBarButton(self.editButton, animated: true)
        navigationBarTitle.title = "Favorites".localized()
        favoriteCollectionView.allowsMultipleSelection = false
        if numberOfFavoriteArtists == 0 {
            editButton.isEnabled = false
            haveNoFavoritesLabel.isHidden = false
            favoriteCollectionView.isHidden = true
        }
    }
    
    func deselectAllArtists(){
        if let indeces = favoriteCollectionView.indexPathsForSelectedItems {
            for index in indeces {
                favoriteCollectionView.deselectItem(at: index, animated: true)
            }
        }
        removingList.removeAll()
    }
}

// MARK: - Extension
extension FavoritesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfFavoriteArtists
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteArtistCell", for: indexPath) as? CustomCollectionViewCell else { return UICollectionViewCell() }
        let artist = CoreDataManager.instance.fetchedResultsController.object(at: indexPath) as? FavoriteArtist
        cell.configureCell(byData: artist)
        return cell
    }
}

extension FavoritesViewController: UICollectionViewDelegate {
    
    
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
            cell.focusCell(withTransform: .init(scaleX: 0.95, y: FloatConstant.cellScale))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
            cell.focusCell(withTransform: .identity)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if favoriteCollectionView.allowsMultipleSelection {
            trashButton.isEnabled = true
            if let artist = coreDataInstance.fetchedResultsController.object(at: indexPath) as? FavoriteArtist, let name = artist.name {
                removingList.append(name)
            }
        } else {
            let eventsStoryboard = UIStoryboard(name: "Events", bundle: nil)
            if let eventsViewController = eventsStoryboard.instantiateViewController(withIdentifier: StringConstant.eventsViewController) as? EventsViewController {
                if let artist = coreDataInstance.fetchedResultsController.object(at: indexPath) as? FavoriteArtist,
                    let name = artist.name, let id = artist.id {
                    dataStore.setPresentingOnMapArtist(name: name, id: id, upcomingEventsCount: Int(artist.upcomingEventsCount))
                }
                navigationController?.pushViewController(eventsViewController, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if favoriteCollectionView.allowsMultipleSelection {
            if let artist = coreDataInstance.fetchedResultsController.object(at: indexPath) as? FavoriteArtist, let name = artist.name {
                var index = 0
                for artistName in removingList {
                    if name == artistName {
                        removingList.remove(at: index)
                        trashButton.isEnabled = !removingList.isEmpty
                        break
                    }
                    index += 1
                }
            }
        }
    }
}

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidthAndHeight = (view.frame.size.width - 18) / 2.0
        return CGSize(width: cellWidthAndHeight, height: cellWidthAndHeight)
    }
}
