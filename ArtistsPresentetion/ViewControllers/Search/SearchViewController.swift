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

    // MARK: - Enums
    enum AddButtonImage {
        case add
        case remove
        
        var image: UIImage {
            switch self {
            case .add: return UIImage(named: "addButton.svg")!
            case .remove: return UIImage(named: "remove.svg")!
            }
        }
    }
    enum SaveButtonImage {
        case added
        case removed
        
        var image: UIImage {
            switch self {
            case .added: return UIImage(named: "added.svg")!
            case .removed: return UIImage(named: "removed.svg")!
            }
        }
    }
    
    // MARK: - Vars & Lets
    private let internetDataManager = InternetDataManager.shared
    private let dataStore = DataStore.shared
    private let coreDataInstance = CoreDataManager.instance
    private let context = CoreDataManager.instance.persistentContainer.viewContext
    private var foundArtist: Artist? {
        return dataStore.currentFoundArtist
    }
    
    // MARK: - Outlets
    @IBOutlet private weak var searchResultsLabel: UILabel!
    @IBOutlet private weak var searchSpinner: UIActivityIndicatorView!
    @IBOutlet private weak var presentationView: UIView!
    @IBOutlet private weak var facebookButton: UIButton!
    @IBOutlet private weak var addAndRemoveButton: UIButton!
    @IBOutlet private weak var resultButton: UIButton!
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var resultView: UIView!
    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
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
    
    // MARK: - Actions
    @IBAction func loadFacebookPage(_ sender: UIButton) {
        if let artist = foundArtist, let facebookUrl = artist.getFacebookUrl() {
            SafariManager.openPageInBrowser(withUrl: facebookUrl)
        }
    }
    
    @IBAction func addToFavorites(_ sender: UIButton) {
        if let artistName = artistNameLabel.text, coreDataInstance.artistIsInDataBase {
            coreDataInstance.deleteObject(withName:artistName, forEntity: StringConstant.favoriteArtistEntity) {
                addAndRemoveButton.setImage(AddButtonImage.add.image, for: .normal)
                coreDataInstance.artistIsInDataBase = false
                resultButton.setImage(SaveButtonImage.removed.image, for: .normal)
                resultLabel.text = StringConstant.removed
                animateResult()
            }
        } else {
            if internetDataManager.isConnectedToNetwork() {
                if let name = foundArtist?.name, let id = foundArtist?.id, let eventsCount = foundArtist?.upcomingEventsCount, let imageUrl = foundArtist?.getImageUrl() {
                    coreDataInstance.addFavoriteArtist(
                        withName: name,
                        withID: id,
                        withEventsCount: eventsCount,
                        withImageDataURL: imageUrl
                    ) {
                        addAndRemoveButton.setImage(AddButtonImage.remove.image, for: .normal)
                        resultButton.setImage(SaveButtonImage.added.image, for: .normal)
                        resultLabel.text = StringConstant.added
                        animateResult()
                        coreDataInstance.artistIsInDataBase = true
                    }
                }
            } else {
                Alerts.presentConnectionAlert()
            }
        }
    }
    
    @IBAction func showEvents(_ sender: UIButton) {
        if internetDataManager.isConnectedToNetwork() {
            let eventsStoryboard = UIStoryboard(name: "Events", bundle: nil)
            if let eventsViewController = eventsStoryboard.instantiateViewController(withIdentifier: StringConstant.eventsViewController) as? EventsViewController,
                let name = foundArtist?.name,
                let id = foundArtist?.id,
                let eventsCount = foundArtist?.upcomingEventsCount {
                dataStore.presentingOnMapArtist.name = name
                dataStore.presentingOnMapArtist.upcomingEventsCount = eventsCount
                dataStore.presentingOnMapArtist.id = id
                navigationController?.pushViewController(eventsViewController, animated: true)
            }
        } else {
            Alerts.presentConnectionAlert()
        }
    }
    
    @IBAction func presentEventsOnMap(_ sender: UIButton) {
        dataStore.needSetCenterMap = false
        if internetDataManager.isConnectedToNetwork() {
            if let name = foundArtist?.name {
                internetDataManager.getEvents(forArtist: name) { (error, events) in
                    if error != nil {
                        Alerts.presentFailedDataLoadingAlert()
                    } else if let events = events, events.count != 0,
                        let id = self.foundArtist?.id,
                        let eventsCount = self.foundArtist?.upcomingEventsCount {
                        self.dataStore.presentingOnMapArtist.name = name
                        self.dataStore.presentingOnMapArtist.upcomingEventsCount = eventsCount
                        self.dataStore.presentingOnMapArtist.id = id
                        DispatchQueue.main.async {
                            self.dataStore.needSetCenterMap = false
                            self.dataStore.presentingEvents = events
                            (self.tabBarController as? MainTabBarViewController)?.switchToMapController()
                        }
                    } else if events != nil {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: StringConstant.events, message: StringConstant.noEvents, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: StringConstant.ok, style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        Alerts.presentFailedDataLoadingAlert()
                    }
                }
            }
        } else {
            Alerts.presentConnectionAlert()
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
        navigationController?.view.backgroundColor = #colorLiteral(red: 0.1660079956, green: 0.1598443687, blue: 0.1949053109, alpha: 1)
        navigationItem.titleView = searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !coreDataInstance.artistIsInDataBase {
            self.addAndRemoveButton.setImage(AddButtonImage.add.image, for: .normal)
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
    
    @IBAction func showKeyboard(_ sender: UISwipeGestureRecognizer) {
        if !searchBar.isFirstResponder {
            searchBar.becomeFirstResponder()
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
            coreDataInstance.artistIsInDataBase = coreDataInstance.objectIsInDataBase(objectName: artistName, forEntity: StringConstant.favoriteArtistEntity)
        }
        coreDataInstance.artistIsInDataBase ? addAndRemoveButton.setImage(AddButtonImage.remove.image, for: .normal) : addAndRemoveButton.setImage(AddButtonImage.add.image, for: .normal)
        UIView.animate(withDuration: 0.5) {
            self.presentationView.alpha = 1.0
        }
    }
    
    func searchAndPresentArtist() {
        hidePresentationView()
        if internetDataManager.isConnectedToNetwork() {
            internetDataManager.getArtist(searchText: dataStore.currentSearchText) { (error, artist) in
                if self.dataStore.currentSearchText.count > IntConstant.minSearchCharactersCount {
                    if error != nil {
                        DispatchQueue.main.async {
                            Alerts.presentFailedDataLoadingAlert()
                            self.searchSpinner.stopAnimating()
                        }
                    } else if let foundArtist = artist {
                        self.dataStore.currentFoundArtist = artist
                        if let imageUrl = foundArtist.getImageUrl(), let imageData = try? Data(contentsOf: imageUrl), let image = UIImage(data: imageData) {
                            DispatchQueue.main.async {
                                self.artistImage.image = image
                            }
                        }
                        DispatchQueue.main.async {
                            if (foundArtist.getFacebookUrl()) != nil {
                                self.facebookButton.isEnabled = true
                            } else {
                                self.facebookButton.isEnabled = false
                            }
                            self.artistNameLabel.text = foundArtist.name
                            self.configureAndShowPresentationView()
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            self.searchSpinner.stopAnimating()
                            self.searchResultsLabel.text = StringConstant.noResults
                            self.searchResultsLabel.isHidden = false
                        }
                    }
                }
            }
        } else {
            Alerts.presentConnectionAlert()
        }
    }
    
    func animateResult() {
        resultView.isUserInteractionEnabled = true
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.4, delay: 0.0, options: .allowUserInteraction, animations: {
            self.resultView.alpha = 1.0
        }) { (position) in
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.4, delay: 1.0, options: .allowUserInteraction, animations: {
                self.resultView.alpha = 0.0
            }) { (position) in
                self.resultView.isUserInteractionEnabled = false
            }
        }
    }
    
    func showResultLabel() {
        dataStore.resetCurrentFoundArtist()
        presentationView.isHidden = true
        presentationView.alpha = 0.0
        searchSpinner.stopAnimating()
        searchResultsLabel.isHidden = false
    }
}


// MARK: - Extension
extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            showResultLabel()
            searchResultsLabel.text = StringConstant.search
        } else if searchText.count > IntConstant.minSearchCharactersCount {
            searchSpinner.startAnimating()
            if dataStore.currentSearchText != searchText {
                dataStore.currentSearchText = searchText
                searchAndPresentArtist()
            }
        } else {
            showResultLabel()
            searchResultsLabel.text = StringConstant.enterName
            if !internetDataManager.isConnectedToNetwork() {
                Alerts.presentConnectionAlert()
            }
            dataStore.currentSearchText = searchText
        }
    }
}
