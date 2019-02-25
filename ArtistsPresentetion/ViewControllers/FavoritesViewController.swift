//
//  FavoritesViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/15/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Vars
    var fetchedResultsController = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteArtist")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.instance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
        }() as NSFetchedResultsController<NSFetchRequestResult>
    var isCellLayoutInNeed = true
    var removingList = [String]() {
        didSet {
            if removingList.count != 0{
                navigationBarTitle.title = "Selected artists: \(removingList.count)"
            } else {
                navigationBarTitle.title = "Select artists"
            }
        }
    }
    static var multiplySelectionIsAllowed = false
    static var selectedArtistName = String()
    
    // MARK: - Outlets
    @IBOutlet weak var favoriteCollectionView: UICollectionView!
    @IBOutlet weak var haveNoFavoritesLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem! {
        didSet {
            trashButton.isEnabled = !removingList.isEmpty
        }
    }
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    
    
    // MARK: - Actions
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setRightBarButton(editButton, animated: true)
        deselectAllArtists()
        favoriteCollectionView.allowsMultipleSelection = false
        navigationBarTitle.title = "Favorites"
    }
    
    @IBAction func trashAction(_ sender: UIBarButtonItem) {
        if self.favoriteCollectionView.indexPathsForSelectedItems != nil {
            var removingArtistString = "artist"
            if removingList.count > 1 {
                removingArtistString = "artists"
            }
            let alert = UIAlertController(title: "Removing", message: "Remove \(removingList.count) \(removingArtistString)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { (action) in
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteArtist")
                do {
                    let results = try CoreDataManager.instance.persistentContainer.viewContext.fetch(fetchRequest)
                    for artistName in self.removingList {
                        for result in results as! [NSManagedObject] {
                            if (result.value(forKey: "name") as! String) == artistName {
                                CoreDataManager.instance.persistentContainer.viewContext.delete(result)
                                try self.fetchedResultsController.performFetch()
                            }
                        }
                        if let currentArtist = SearchViewController.currentArtist {
                            if artistName == currentArtist.getName() {
                                SearchViewController.isInDataBase = false
                            }
                        }
                    }
                    let selectedIndexes = self.favoriteCollectionView.indexPathsForSelectedItems!
                    self.deselectAllArtists()
                    self.favoriteCollectionView.deleteItems(at: selectedIndexes)
                    CoreDataManager.instance.saveContext()
                    self.trashButton.isEnabled = false
                    self.navigationItem.leftBarButtonItem = nil
                    self.navigationItem.setRightBarButton(self.editButton, animated: true)
                    self.navigationBarTitle.title = "Favorites"
                    self.favoriteCollectionView.allowsMultipleSelection = false
                    if self.favoriteCollectionView.numberOfItems(inSection: 0) == 0 {
                        self.editButton.isEnabled = false
                        self.haveNoFavoritesLabel.isHidden = false
                        self.favoriteCollectionView.isHidden = true
                    }
                } catch {
                    print(error)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        navigationBarTitle.title = "Select artists"
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        favoriteCollectionView.reloadData()
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
extension FavoritesViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let artist = fetchedResultsController.object(at: indexPath) as! FavoriteArtist
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteArtistCell", for: indexPath) as! CustomCollectionViewCell
        if let data = artist.image_data {
            if let image = UIImage(data: data){
                cell.imageView.image = image
            }
        }
        cell.nameLabel.text = artist.name
        if(cell.isSelected){
            cell.backgroundColor = UIColor.red
        }else{
            cell.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if favoriteCollectionView.allowsMultipleSelection {
            trashButton.isEnabled = true
            let artist = fetchedResultsController.object(at: indexPath) as! FavoriteArtist
            if let name = artist.name{
                removingList.append(name)
            }
        } else {
            let artist = fetchedResultsController.object(at: indexPath) as! FavoriteArtist
            if let name = artist.name {
                FavoritesViewController.selectedArtistName = name
                EventsViewController.artist = (name, Int(artist.upcoming_events_count))
            }
            let eventsStoryboard = UIStoryboard(name: "Events", bundle: nil)
            let eventsViewController = eventsStoryboard.instantiateViewController(withIdentifier: "viewController")
            self.navigationController?.pushViewController(eventsViewController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if favoriteCollectionView.allowsMultipleSelection {
            let artist = fetchedResultsController.object(at: indexPath) as! FavoriteArtist
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
            FavoritesViewController.selectedArtistName = ""
        }
    }
    
}
