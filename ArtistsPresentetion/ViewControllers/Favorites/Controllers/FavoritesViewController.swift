//
//  FavoritesViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/15/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import CoreData
import UIKit

final class FavoritesViewController: UIViewController, UICollectionViewDataSource {
    
    // MARK: - Vars
    private var isCellLayoutInNeed = true
    private var removingList = [String]() {
        didSet {
            let multiplySelectionIsAllowed = DataStore.shared.multiplySelectionIsAllowed
            if removingList.count != 0 && multiplySelectionIsAllowed {
                navigationBarTitle.title = "\(NSLocalizedString("Selected artists:", comment: "")) \(removingList.count)"
            } else if multiplySelectionIsAllowed {
                navigationBarTitle.title = NSLocalizedString("Select artists", comment: "")
            }
        }
    }
    private var selectedArtistName = String()
    
    // MARK: - Outlets
    @IBOutlet private weak var favoriteCollectionView: UICollectionView!
    @IBOutlet private weak var haveNoFavoritesLabel: UILabel!
    @IBOutlet private weak var editButton: UIBarButtonItem!
    @IBOutlet private weak var trashButton: UIBarButtonItem! {
        didSet {
            trashButton.isEnabled = !removingList.isEmpty
        }
    }
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var navigationBarTitle: UINavigationItem!
    
    
    // MARK: - Actions
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setRightBarButton(editButton, animated: true)
        deselectAllArtists()
        favoriteCollectionView.allowsMultipleSelection = false
        navigationBarTitle.title = NSLocalizedString("Favorites", comment: "")
    }
    
    @IBAction func trashAction(_ sender: UIBarButtonItem) {
        if self.favoriteCollectionView.indexPathsForSelectedItems != nil {
            var removingArtistString = NSLocalizedString("artist", comment: "")
            if removingList.count > 1 && !(2...4).contains((removingList.count % 10)) {
                removingArtistString = NSLocalizedString("artists", comment: "")
            }
            let alert = UIAlertController(title: NSLocalizedString("Removing", comment: ""), message: "\(NSLocalizedString("Remove", comment: "")) \(removingList.count) \(removingArtistString)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: .destructive, handler: { (action) in
                for artistName in self.removingList {
                    CoreDataManager.instance.deleteObject(withName: artistName, forEntity: "FavoriteArtist", completion: {
                        do {
                            try CoreDataManager.instance.fetchedResultsController.performFetch()
                        } catch {
                            print(error)
                        }
                        if let currentArtist = DataStore.shared.currentFoundArtist, artistName == currentArtist.getName() {
                            DataStore.shared.artistIsInDataBase = false
                        }
                    })
                }
                let selectedIndeces = self.favoriteCollectionView.indexPathsForSelectedItems!
                self.deselectAllArtists()
                self.favoriteCollectionView.deleteItems(at: selectedIndeces)
                CoreDataManager.instance.saveContext()
                self.trashButton.isEnabled = false
                self.navigationItem.leftBarButtonItem = nil
                self.navigationItem.setRightBarButton(self.editButton, animated: true)
                self.navigationBarTitle.title = NSLocalizedString("Favorites", comment: "")
                self.favoriteCollectionView.allowsMultipleSelection = false
                if self.favoriteCollectionView.numberOfItems(inSection: 0) == 0 {
                    self.editButton.isEnabled = false
                    self.haveNoFavoritesLabel.isHidden = false
                    self.favoriteCollectionView.isHidden = true
                }
            }))
            alert.addAction(UIAlertAction(title: StringConstants.AlertsStrings.cancel, style: .cancel))
            present(alert, animated: true)
        }
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        navigationBarTitle.title = NSLocalizedString("Select artists", comment: "")
        self.navigationItem.setLeftBarButton(cancelButton, animated: true)
        self.navigationItem.setRightBarButton(trashButton, animated: true)
        favoriteCollectionView.allowsMultipleSelection = true
    }
    
    // MARK: - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        isCellLayoutInNeed = false
        let width = (view.frame.size.width - 6.0) / 2.0
        let height = width + width / 10
        let layout = favoriteCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize.width = width
        layout.itemSize.height = height
        self.navigationItem.setRightBarButton(editButton, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationItem.setLeftBarButton(nil, animated: true)
        self.navigationItem.setRightBarButton(editButton, animated: true)
        deselectAllArtists()
        navigationBarTitle.title = NSLocalizedString("Favorites", comment: "")
        favoriteCollectionView.allowsMultipleSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        do {
            try CoreDataManager.instance.fetchedResultsController.performFetch()
            favoriteCollectionView.reloadData()
        } catch {
            print(error)
        }
        if favoriteCollectionView.numberOfItems(inSection: 0) == 0 {
            if self.navigationItem.rightBarButtonItem == editButton {
                editButton.isEnabled = false
            }
            editButton.isEnabled = false
            haveNoFavoritesLabel.isHidden = false
            favoriteCollectionView.isHidden = true
        } else {
            if self.navigationItem.rightBarButtonItem == editButton {
                editButton.isEnabled = true
            }
            editButton.isEnabled = true
            favoriteCollectionView.isHidden = false
            haveNoFavoritesLabel.isHidden = true
        }
    }
    
    // MARK: - MyTools
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
extension FavoritesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = CoreDataManager.instance.fetchedResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return CustomCollectionViewCell.configuredCell(of: collectionView, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if favoriteCollectionView.allowsMultipleSelection {
            trashButton.isEnabled = true
            let artist = CoreDataManager.instance.fetchedResultsController.object(at: indexPath) as! FavoriteArtist
            if let name = artist.name {
                removingList.append(name)
            }
        } else {
            let eventsStoryboard = UIStoryboard(name: "Events", bundle: nil)
            let eventsViewController = eventsStoryboard.instantiateViewController(withIdentifier: "viewController") as! EventsViewController
            let artist = CoreDataManager.instance.fetchedResultsController.object(at: indexPath) as! FavoriteArtist
            if let name = artist.name {
                selectedArtistName = name
                DataStore.shared.currentEventsArtist = (name, Int(artist.upcoming_events_count), artist.id!)
            }
            self.navigationController?.pushViewController(eventsViewController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if favoriteCollectionView.allowsMultipleSelection {
            let artist = CoreDataManager.instance.fetchedResultsController.object(at: indexPath) as! FavoriteArtist
            if let name = artist.name {
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
        } else {
            selectedArtistName = ""
        }
    }
    
}
