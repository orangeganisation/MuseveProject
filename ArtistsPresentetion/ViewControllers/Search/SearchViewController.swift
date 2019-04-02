//
//  SearchViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/15/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import CoreData
import SafariServices
import UIKit

final class SearchViewController: UIViewController {

    // MARK: - Vars
    private let context = CoreDataManager.instance.persistentContainer.viewContext
    private var foundArtist: Artist? {
        return DataStore.shared.currentFoundArtist
    }
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
                case .added: return UIImage(named: "added.svg")!
                case .removed: return UIImage(named: "removed.svg")!
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    @IBOutlet private weak var searchResultsLabel: UILabel!
    @IBOutlet private weak var searchSpinner: UIActivityIndicatorView!
    @IBOutlet private weak var presentationView: UIView!
    @IBOutlet private weak var artistImage: UIImageView! {
        didSet {
            artistImage.layer.cornerRadius = 15
            artistImage.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    @IBOutlet private weak var artistNameLabel: UILabel! {
        didSet {
            artistNameLabel.layer.cornerRadius = 12
            artistNameLabel.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    @IBOutlet private weak var facebookButton: UIButton!
    @IBOutlet private weak var addAndRemoveButton: UIButton! {
        didSet {
            addAndRemoveButton.clipsToBounds = true
        }
    }
    @IBOutlet private weak var resultButton: UIButton!
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var resultView: UIView!
    
    // MARK: - Actions
    @IBAction func loadFacebookPage(_ sender: UIButton) {
        if let artist = foundArtist, let facebookUrl = artist.getFacebookUrl() {
            EventsViewController.openSafariPage(withUrl: facebookUrl, byController: self)
        }
    }
    
    @IBAction func addToFavorites(_ sender: UIButton) {
        if let artistName = artistNameLabel.text, CoreDataManager.instance.artistIsInDataBase {
            CoreDataManager.instance.deleteObject(withName:artistName, forEntity: StringConstants.Favorites.entity) {
                self.addAndRemoveButton.setImage(addAndRemoveButtonImage.add.image, for: .normal)
                CoreDataManager.instance.artistIsInDataBase = false
                self.resultButton.setImage(dbResultButtonImage.removed.image, for: .normal)
                resultLabel.text = StringConstants.Search.removed
                animateResult()
            }
        } else {
            if InternetDataManager.shared.isConnectedToNetwork() {
                if let name = foundArtist?.getName(), let id = foundArtist?.getID(), let eventsCount = foundArtist?.getUpcomingEventCount(), let imageUrl = foundArtist?.getImageUrl() {
                    CoreDataManager.instance.addFavoriteArtist(
                        withName: name,
                        withID: id,
                        withEventsCount: eventsCount,
                        withImageDataURL: imageUrl
                    ) {
                        self.addAndRemoveButton.setImage(addAndRemoveButtonImage.remove.image, for: .normal)
                        self.resultButton.setImage(dbResultButtonImage.added.image, for: .normal)
                        resultLabel.text = StringConstants.Search.added
                        animateResult()
                        CoreDataManager.instance.artistIsInDataBase = true
                    }
                }
            } else {
                Alerts.presentConnectionAlert(viewController: self)
            }
        }
    }
    
    @IBAction func showEvents(_ sender: UIButton) {
        if InternetDataManager.shared.isConnectedToNetwork() {
            let eventsStoryboard = UIStoryboard(name: "Events", bundle: nil)
            if let eventsViewController = eventsStoryboard.instantiateViewController(withIdentifier: "viewController") as? EventsViewController,
                let name = foundArtist?.getName(),
                let id = foundArtist?.getID(),
                let eventsCount = foundArtist?.getUpcomingEventCount() {
                DataStore.shared.presentingOnMapArtist.setName(name: name)
                DataStore.shared.presentingOnMapArtist.setUpcomingEventsCount(count: eventsCount)
                DataStore.shared.presentingOnMapArtist.setId(id: id)
                navigationController?.pushViewController(eventsViewController, animated: true)
            }
        } else {
            Alerts.presentConnectionAlert(viewController: self)
        }
    }
    
    @IBAction func presentEventsOnMap(_ sender: UIButton) {
        DataStore.shared.needSetCenterMap = false
        if InternetDataManager.shared.isConnectedToNetwork() {
            if let name = foundArtist?.getName() {
                InternetDataManager.shared.getEvents(forArtist: name) { (error, events) in
                    if error != nil {
                        Alerts.presentFailedDataLoadingAlert(viewController: self)
                    } else if let events = events, events.count != 0,
                        let id = self.foundArtist?.getID(),
                        let eventsCount = self.foundArtist?.getUpcomingEventCount() {
                        DataStore.shared.presentingOnMapArtist.setName(name: name)
                        DataStore.shared.presentingOnMapArtist.setUpcomingEventsCount(count: eventsCount)
                        DataStore.shared.presentingOnMapArtist.setId(id: id)
                        DispatchQueue.main.async {
                            DataStore.shared.needSetCenterMap = false
                            DataStore.shared.presentingEvents = events
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
        } else {
            Alerts.presentConnectionAlert(viewController: self)
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
        if !CoreDataManager.instance.artistIsInDataBase {
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
        searchSpinner.stopAnimating()
        presentationView.isHidden = false
        searchResultsLabel.isHidden = true
        if let artistName = artistNameLabel.text {
            CoreDataManager.instance.artistIsInDataBase = CoreDataManager.instance.objectIsInDataBase(objectName: artistName, forEntity: StringConstants.Favorites.entity)
        }
        if CoreDataManager.instance.artistIsInDataBase {
            addAndRemoveButton.setImage(addAndRemoveButtonImage.remove.image, for: .normal)
        } else {
            addAndRemoveButton.setImage(addAndRemoveButtonImage.add.image, for: .normal)
        }
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0.0, options: .allowUserInteraction, animations: {
            self.presentationView.alpha = 1.0
        })
    }
    
    func searchAndPresentArtist() {
        hidePresentationView()
        if InternetDataManager.shared.isConnectedToNetwork() {
            InternetDataManager.shared.getArtist(searchText: DataStore.shared.currentSearchText) { (error, artist) in
                if DataStore.shared.currentSearchText.count > 2 {
                    if error != nil {
                        DispatchQueue.main.async {
                            Alerts.presentFailedDataLoadingAlert(viewController: self)
                            self.searchSpinner.stopAnimating()
                        }
                    } else if let gotArtist = artist {
                        DataStore.shared.currentFoundArtist = artist
                        if let imageUrl = URL(string: gotArtist.getImageUrl()), let imageData = try? Data(contentsOf: imageUrl), let image = UIImage(data: imageData) {
                            DispatchQueue.main.async {
                                self.artistImage.image = image
                            }
                        }
                        DispatchQueue.main.async {
                            if (gotArtist.getFacebookUrl()) != nil {
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
        } else {
            Alerts.presentConnectionAlert(viewController: self)
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
        DataStore.shared.currentFoundArtist = nil
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
            DataStore.shared.currentSearchText = searchText
        } else {
            searchSpinner.startAnimating()
            if DataStore.shared.currentSearchText != searchText {
                DataStore.shared.currentSearchText = searchText
                searchAndPresentArtist()
            }
        }
    }
}
