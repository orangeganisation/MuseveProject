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
    
    // MARK: - Outlets
    @IBOutlet weak var favoriteCollectionView: UICollectionView!{
        didSet{
            favoriteCollectionView.delegate = self
            favoriteCollectionView.dataSource = self
        }
    }
    @IBOutlet weak var haveNoFavoritesLabel: UILabel!
    
    
    
    // MARK: - ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        isCellLayoutInNeed = false
        let width = (view.frame.size.width - 6.0) / 2.0
        let height = width + width / 10
        let layout = favoriteCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize.width = width
        layout.itemSize.height = height
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
            haveNoFavoritesLabel.isHidden = false
            favoriteCollectionView.isHidden = true
        } else {
            favoriteCollectionView.isHidden = false
            haveNoFavoritesLabel.isHidden = true
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

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
        return cell
    }
    
}
