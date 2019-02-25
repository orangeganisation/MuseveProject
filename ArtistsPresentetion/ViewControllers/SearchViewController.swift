//
//  SearchViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/15/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit
import SafariServices
import CoreData

class SearchViewController: UIViewController, UISearchBarDelegate {

    // MARK: - Vars
    static var internetDataManager = InternetDataManager()
    static var currentArtist:Artist?
    static var currentSearchText = String()
    let context = CoreDataManager.instance.persistentContainer.viewContext
    static var isInDataBase = false

    
    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!{
        didSet{
            searchBar.delegate = self
        }
        
    }
    @IBOutlet weak var searchResultsLabel: UILabel!
    @IBOutlet weak var searchSpinner: UIActivityIndicatorView!
    @IBOutlet weak var presentationView: UIView!
    @IBOutlet weak var artistImage: UIImageView!{
        didSet{
            artistImage.clipsToBounds = true
        }
    }
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var addAndRemoveButton: UIButton! {
        didSet {
            addAndRemoveButton.clipsToBounds = true
        }
    }
    @IBOutlet weak var resultButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultView: UIView!
    
    // MARK: - Actions
    @IBAction func loadFacebookPage(_ sender: UIButton) {
        if let artist = SearchViewController.currentArtist, let facebook = artist.getFacebookPage(){
            if let url = URL(string: facebook){
                InternetDataManager.openSafariPage(withUrl: url, byController: self)
            }
        }
    }
    
    @IBAction func addToFavorites(_ sender: UIButton) {
        if SearchViewController.isInDataBase {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteArtist")
            do {
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    if (result.value(forKey: "name") as! String) == artistNameLabel.text {
                        context.delete(result)
                        CoreDataManager.instance.saveContext()
                    }
                }
                if let image = UIImage(named: "addButton.svg") {
                    self.addAndRemoveButton.setImage(image, for: .normal)
                }
                SearchViewController.isInDataBase = false
                if let image = UIImage(named: "removed.svg") {
                    self.resultButton.setImage(image, for: .normal)
                }
                resultLabel.text = "Deleted"
                animateResult()
            } catch {
                print(error)
            }
        } else {
            if SearchViewController.internetDataManager.isConnectedToNetwork(){
                if let entityDescription = NSEntityDescription.entity(forEntityName: "FavoriteArtist", in: context) {
                    let managedObject = NSManagedObject(entity: entityDescription, insertInto: context)
                    managedObject.setValue(SearchViewController.currentArtist!.getName(), forKey: "name")
                    managedObject.setValue(SearchViewController.currentArtist!.getID(), forKey: "id")
                    managedObject.setValue(SearchViewController.currentArtist!.getUpcomingEventCount(), forKey: "upcoming_events_count")
                    if let imageUrl = URL(string: SearchViewController.currentArtist!.getThumbUrl()) {
                        if let data = try? Data(contentsOf: imageUrl) as NSData {
                            managedObject.setValue(data, forKey: "image_data")
                        }
                    }
                    CoreDataManager.instance.saveContext()
                    if let image = UIImage(named: "remove.svg") {
                        self.addAndRemoveButton.setImage(image, for: .normal)
                    }
                    SearchViewController.isInDataBase = true
                    if let image = UIImage(named: "added.svg") {
                        self.resultButton.setImage(image, for: .normal)
                    }
                    resultLabel.text = "Added"
                    animateResult()
                }
            } else {
                SearchViewController.internetDataManager.presentConnectionAlert(viewController: self)
            }
        }
    }
    
    @IBAction func showEvents(_ sender: UIButton) {
        if SearchViewController.internetDataManager.isConnectedToNetwork() {
            let eventsStoryboard = UIStoryboard(name: "Events", bundle: nil)
            let eventsViewController = eventsStoryboard.instantiateViewController(withIdentifier: "viewController")
            self.navigationController?.pushViewController(eventsViewController, animated: true)
            EventsViewController.artist = (SearchViewController.currentArtist!.getName(), SearchViewController.currentArtist!.getUpcomingEventCount())
        } else {
            SearchViewController.internetDataManager.presentConnectionAlert(viewController: self)
        }
    }
    
    @IBAction func presentEventsOnMap(_ sender: UIButton) {
        SearchViewController.internetDataManager.getEvents(forArtist: (SearchViewController.currentArtist?.getName())!, forDate: nil, viewController: self) { (error, events) in
            if error != nil{
                SearchViewController.internetDataManager.presentFailedDataLoadingAlert(viewController: self)
            } else if events != nil, events?.count != 0 {
                MapViewController.currentArtistName = SearchViewController.currentArtist?.getName()
                DispatchQueue.main.async {
                    MapViewController.needSetCenterValue = false
                    MapViewController.presentingEvents = events!
                    MapViewController.currentArtistId = SearchViewController.currentArtist?.getID()
                    self.tabBarController?.selectedIndex = 2
                }
            } else if events != nil {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Events", message: "This artist has no events", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                SearchViewController.internetDataManager.presentFailedDataLoadingAlert(viewController: self)
            }
        }
    }
    
    
    // MARK: - Search Bar & Keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchSpinner.startAnimating()
        searchAndPresentArtist()
    }
    
    
    // MARK: - View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !SearchViewController.isInDataBase {
            if let image = UIImage(named: "addButton.svg") {
                self.addAndRemoveButton.setImage(image, for: .normal)
            }
        }
        navigationController?.view.layoutSubviews()

    }

    //MARK: - Gestures
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        if searchBar.isFirstResponder{
            searchBar.resignFirstResponder()
        }
    }
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        if searchBar.isFirstResponder{
            searchBar.resignFirstResponder()
        }
    }
    
    // MARK: - MyTools
    func searchAndPresentArtist(){
        presentationView.isHidden = true
        presentationView.alpha = 0.0
        if !searchResultsLabel.isHidden{
            searchResultsLabel.isHidden = true
        }
        if let codedSearchText = SearchViewController.currentSearchText.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed){
            SearchViewController.internetDataManager.getArtist(viewController: self, searchText: codedSearchText) { (error, artist) in
                
                if error != nil {
                    DispatchQueue.main.async {
                        SearchViewController.internetDataManager.presentFailedDataLoadingAlert(viewController: self)
                        self.searchSpinner.stopAnimating()
                    }
                    
                } else if let gotArtist = artist {
                    SearchViewController.currentArtist = artist
                    if let imageUrl = URL(string: gotArtist.getImageUrl()), let imageData = try? Data(contentsOf: imageUrl){
                        if let image = UIImage(data: imageData){
                            DispatchQueue.main.async {
                                self.artistImage.image = image
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        if (gotArtist.getFacebookPage()) != nil{
                            self.facebookButton.isEnabled = true
                        } else {
                            self.facebookButton.isEnabled = false
                        }
                        self.artistNameLabel.text = gotArtist.getName()
                        self.searchSpinner.stopAnimating()
                        self.presentationView.isHidden = false
                        self.searchResultsLabel.isHidden = true
                        SearchViewController.isInDataBase = false
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteArtist")
                        do {
                            let results = try self.context.fetch(fetchRequest)
                            for result in results as! [NSManagedObject] {
                                if (result.value(forKey: "name") as! String) == self.artistNameLabel.text {
                                    SearchViewController.isInDataBase = true
                                }
                            }
                        } catch {
                            print(error)
                        }
                        if SearchViewController.isInDataBase {
                            if let image = UIImage(named: "remove.svg") {
                                self.addAndRemoveButton.setImage(image, for: .normal)
                            }
                        } else {
                            if let image = UIImage(named: "addButton.svg") {
                                self.addAndRemoveButton.setImage(image, for: .normal)
                            }
                        }
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0.0, options: .allowUserInteraction, animations: {
                            self.presentationView.alpha = 1.0
                        }, completion: nil)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.searchSpinner.stopAnimating()
                        self.searchResultsLabel.text = StringConstants.noResults
                        self.searchResultsLabel.isHidden = false
                    }
                }
            }
        }
    }
    
    func animateResult() {
        self.resultView.isHidden = false
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.4, delay: 0.0, options: .allowUserInteraction, animations: {
            self.resultView.alpha = 1.0
        }) { (position) in
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.4, delay: 1.0, options: .allowUserInteraction, animations: {
                self.resultView.alpha = 0.0
            }){ (position) in
                self.resultView.isHidden = true
            }
        }
    }
}


// MARK: - Extension
extension SearchViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0{
            SearchViewController.currentArtist = nil
            if !presentationView.isHidden{
                presentationView.isHidden = true
                presentationView.alpha = 0.0
            }
            if searchSpinner.isAnimating{
                searchSpinner.stopAnimating()
            }
            if searchResultsLabel.isHidden{
                searchResultsLabel.isHidden = false
            }
            searchResultsLabel.text = StringConstants.search
        }else if (1..<3).contains(searchText.count){
            SearchViewController.currentArtist = nil
            if !presentationView.isHidden{
                presentationView.isHidden = true
                presentationView.alpha = 0.0
            }
            if searchSpinner.isAnimating{
                searchSpinner.stopAnimating()
            }
            if searchResultsLabel.isHidden{
                searchResultsLabel.isHidden = false
            }
            searchResultsLabel.text = StringConstants.enterName
            if !SearchViewController.internetDataManager.isConnectedToNetwork() {
                SearchViewController.internetDataManager.presentConnectionAlert(viewController: self)
            }
            SearchViewController.currentSearchText = searchText
        }else{
            searchSpinner.startAnimating()
            if SearchViewController.currentSearchText != searchText {
                SearchViewController.currentSearchText = searchText
                searchAndPresentArtist()
            }
        }
    }
}
