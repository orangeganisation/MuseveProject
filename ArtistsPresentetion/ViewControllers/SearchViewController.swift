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

class SearchViewController: UIViewController {

    // MARK: - Vars
    let context = CoreDataManager.instance.persistentContainer.viewContext
    enum addAndRemoveButtonImage {
        case add
        case remove
        var image: UIImage {
            switch self {
                case .add: return UIImage(named: "addButton.svg")!
                case .remove: return UIImage(named: "remove.svg")!
            }
        }
    }
    enum dbResultButtonImage {
        case added
        case removed
        var image: UIImage {
            switch self {
                case .added: return UIImage(named: "removed.svg")!
                case .removed: return UIImage(named: "added.svg")!
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    @IBOutlet weak var searchResultsLabel: UILabel!
    @IBOutlet weak var searchSpinner: UIActivityIndicatorView!
    @IBOutlet weak var presentationView: UIView!
    @IBOutlet weak var artistImage: UIImageView! {
        didSet {
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
        if let artist = DataStore.Search.currentFoundArtist, let facebook = artist.getFacebookPage(){
            if let url = URL(string: facebook) {
                InternetDataManager.openSafariPage(withUrl: url, byController: self)
            }
        }
    }
    
    @IBAction func addToFavorites(_ sender: UIButton) {
        if DataStore.Search.artistIsInDataBase {
            CoreDataManager.instance.deleteObject(withName: artistNameLabel.text!, forEntity: "FavoriteArtist") {
                self.addAndRemoveButton.setImage(addAndRemoveButtonImage.add.image, for: .normal)
                DataStore.Search.artistIsInDataBase = false
                self.resultButton.setImage(dbResultButtonImage.removed.image, for: .normal)
                resultLabel.text = StringConstants.Search.removed
                animateResult()
            }
        } else {
            if InternetDataManager.shared.isConnectedToNetwork(){
                CoreDataManager.instance.addFavoriteArtist(withName: (DataStore.Search.currentFoundArtist?.getName())!, withID: (DataStore.Search.currentFoundArtist?.getID())!, withEventsCount: (DataStore.Search.currentFoundArtist?.getUpcomingEventCount())!, withImageDataURL: (DataStore.Search.currentFoundArtist?.getThumbUrl())!) {
                    self.addAndRemoveButton.setImage(addAndRemoveButtonImage.remove.image, for: .normal)
                    self.resultButton.setImage(dbResultButtonImage.added.image, for: .normal)
                    resultLabel.text = StringConstants.Search.added
                    animateResult()
                    DataStore.Search.artistIsInDataBase = true
                }
            } else {
                Alerts.presentConnectionAlert(viewController: self)
            }
        }
    }
    
    @IBAction func showEvents(_ sender: UIButton) {
        if InternetDataManager.shared.isConnectedToNetwork() {
            let eventsStoryboard = UIStoryboard(name: "Events", bundle: nil)
            let eventsViewController = eventsStoryboard.instantiateViewController(withIdentifier: "viewController") as! EventsViewController
            eventsViewController.artist = (DataStore.Search.currentFoundArtist!.getName(), DataStore.Search.currentFoundArtist!.getUpcomingEventCount())
            self.navigationController?.pushViewController(eventsViewController, animated: true)
        } else {
            Alerts.presentConnectionAlert(viewController: self)
        }
    }
    
    @IBAction func presentEventsOnMap(_ sender: UIButton) {
        InternetDataManager.shared.getEvents(forArtist: (DataStore.Search.currentFoundArtist?.getName())!, forDate: nil, viewController: self) { (error, events) in
            if error != nil {
                Alerts.presentFailedDataLoadingAlert(viewController: self)
            } else if events != nil, events?.count != 0 {
                DataStore.Map.currentEventsArtistName = DataStore.Search.currentFoundArtist?.getName()
                DispatchQueue.main.async {
                    DataStore.Map.needSetCenterMap = false
                    DataStore.Map.presentingEvents = events!
                    DataStore.Map.currentEventsArtistId = DataStore.Search.currentFoundArtist?.getID()
                    self.tabBarController?.selectedIndex = 2
                }
            } else if events != nil {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: StringConstants.ArtistEvents.events, message: StringConstants.ArtistEvents.noEvents, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                Alerts.presentFailedDataLoadingAlert(viewController: self)
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
        if !DataStore.Search.artistIsInDataBase {
            self.addAndRemoveButton.setImage(addAndRemoveButtonImage.add.image, for: .normal)
        }
        navigationController?.view.layoutSubviews()

    }

    //MARK: - Gestures
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
    
    // MARK: - MyTools
    func hidePresentationView() {
        presentationView.isHidden = true
        presentationView.alpha = 0.0
        if !searchResultsLabel.isHidden {
            searchResultsLabel.isHidden = true
        }
    }
    
    func configureAndShowPresentationView() {
        self.searchSpinner.stopAnimating()
        self.presentationView.isHidden = false
        self.searchResultsLabel.isHidden = true
        DataStore.Search.artistIsInDataBase = CoreDataManager.instance.objectIsInDataBase(objectName: self.artistNameLabel.text!, forEntity: "FavoriteArtist")
        if DataStore.Search.artistIsInDataBase {
            self.addAndRemoveButton.setImage(addAndRemoveButtonImage.remove.image, for: .normal)
        } else {
            self.addAndRemoveButton.setImage(addAndRemoveButtonImage.add.image, for: .normal)
        }
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0.0, options: .allowUserInteraction, animations: {
            self.presentationView.alpha = 1.0
        }, completion: nil)
    }
    
    func searchAndPresentArtist() {
        hidePresentationView()
        InternetDataManager.shared.getArtist(viewController: self, searchText: DataStore.Search.currentSearchText) { (error, artist) in
            if DataStore.Search.currentSearchText.count > 2 {
                if error != nil {
                    DispatchQueue.main.async {
                        Alerts.presentFailedDataLoadingAlert(viewController: self)
                        self.searchSpinner.stopAnimating()
                    }
                } else if let gotArtist = artist {
                    DataStore.Search.currentFoundArtist = artist
                    if let imageUrl = URL(string: gotArtist.getImageUrl()), let imageData = try? Data(contentsOf: imageUrl) {
                        if let image = UIImage(data: imageData) {
                            DispatchQueue.main.async {
                                self.artistImage.image = image
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        if (gotArtist.getFacebookPage()) != nil {
                            self.facebookButton.isEnabled = true
                        } else {
                            self.facebookButton.isEnabled = false
                        }
                        self.artistNameLabel.text = gotArtist.getName()
                        self.configureAndShowPresentationView()
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.searchSpinner.stopAnimating()
                        self.searchResultsLabel.text = StringConstants.Search.noResults
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
            }) { (position) in
                self.resultView.isHidden = true
            }
        }
    }
    
    func showResultLabel() {
        DataStore.Search.currentFoundArtist = nil
        presentationView.isHidden = true
        presentationView.alpha = 0.0
        searchSpinner.stopAnimating()
        searchResultsLabel.isHidden = false
    }
}


// MARK: - Extension
extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            showResultLabel()
            searchResultsLabel.text = StringConstants.Search.search
        } else if (1..<3).contains(searchText.count) {
            showResultLabel()
            searchResultsLabel.text = StringConstants.Search.enterName
            if !InternetDataManager.shared.isConnectedToNetwork() {
                Alerts.presentConnectionAlert(viewController: self)
            }
            DataStore.Search.currentSearchText = searchText
        } else {
            searchSpinner.startAnimating()
            if DataStore.Search.currentSearchText != searchText {
                DataStore.Search.currentSearchText = searchText
                searchAndPresentArtist()
            }
        }
    }
}
