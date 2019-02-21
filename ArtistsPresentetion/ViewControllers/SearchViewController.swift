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
    var internetDataManager = InternetDataManager()
    var currentArtist:Artist?
    static var currentSearchText = String()
    let context = CoreDataManager.instance.persistentContainer.viewContext
    var isInDataBase = false
    
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
    @IBOutlet weak var addAndRemoveButton: UIButton!
    @IBOutlet weak var resultButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultView: UIView!
    
    // MARK: - Actions
    @IBAction func loadFacebookPage(_ sender: UIButton) {
        if let artist = currentArtist, let facebook = artist.getFacebookPage(){
            if let url = URL(string: facebook){
                InternetDataManager.openSafariPage(withUrl: url, byController: self)
            }
        }
    }
    
    @IBAction func addToFavorites(_ sender: UIButton) {
        if isInDataBase {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteArtist")
            do {
                let results = try context.fetch(fetchRequest)
                for result in results as! [NSManagedObject] {
                    if (result.value(forKey: "name") as! String) == artistNameLabel.text {
                        context.delete(result)
                        CoreDataManager.instance.saveContext()
                    }
                }
                if let image = UIImage(named: "addStar.svg") {
                    self.addAndRemoveButton.setImage(image, for: .normal)
                }
                isInDataBase = false
                if let image = UIImage(named: "removed.svg") {
                    self.resultButton.setImage(image, for: .normal)
                }
                resultLabel.text = "Deleted"
                animateResult()
            } catch {
                print(error)
            }
        } else {
            if let entityDescription = NSEntityDescription.entity(forEntityName: "FavoriteArtist", in: context) {
                let managedObject = NSManagedObject(entity: entityDescription, insertInto: context)
                managedObject.setValue(currentArtist!.getName(), forKey: "name")
                if let facebook = currentArtist!.getFacebookPage() {
                    let facebookUrl = URL(string: facebook)
                    managedObject.setValue(facebookUrl, forKey: "facebook")
                }
                if let imageUrl = URL(string: currentArtist!.getThumbUrl()) {
                    if let data = try? Data(contentsOf: imageUrl) as NSData {
                        managedObject.setValue(data, forKey: "image_data")
                    }
                }
                CoreDataManager.instance.saveContext()
                if let image = UIImage(named: "remove.svg") {
                    self.addAndRemoveButton.setImage(image, for: .normal)
                }
                isInDataBase = true
                if let image = UIImage(named: "added.svg") {
                    self.resultButton.setImage(image, for: .normal)
                }
                resultLabel.text = "Added"
                animateResult()
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
        /*if loading {
            return
        }
        isLoading = true
        internetDataManager.getArtist(searchText: currentSearchText) { (error, artist) in
            isloading = false
            
        }*/
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
            internetDataManager.getArtist(viewController: self, searchText: codedSearchText) { (error, artist) in
                
                if error != nil {
                    DispatchQueue.main.async {
                        self.internetDataManager.presentFailedDataLoadingAlert(viewController: self)
                        self.searchSpinner.stopAnimating()
                    }
                    
                } else if let gotArtist = artist {
                    self.currentArtist = artist
                    if let imageUrl = URL(string: gotArtist.getImageUrl()), let imageData = try? Data(contentsOf: imageUrl){
                        if let image = UIImage(data: imageData){
                            DispatchQueue.main.async {
                                self.artistImage.image = image
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        if (self.currentArtist?.getFacebookPage()) != nil{
                            self.facebookButton.isEnabled = true
                        } else {
                            self.facebookButton.isEnabled = false
                        }
                        self.artistNameLabel.text = gotArtist.getName()
                        self.searchSpinner.stopAnimating()
                        self.presentationView.isHidden = false
                        self.searchResultsLabel.isHidden = true
                        self.isInDataBase = false
                        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteArtist")
                        do {
                            let results = try self.context.fetch(fetchRequest)
                            for result in results as! [NSManagedObject] {
                                if (result.value(forKey: "name") as! String) == self.artistNameLabel.text {
                                    self.isInDataBase = true
                                }
                            }
                        } catch {
                            print(error)
                        }
                        if self.isInDataBase {
                            if let image = UIImage(named: "remove.svg") {
                                self.addAndRemoveButton.setImage(image, for: .normal)
                            }
                        } else {
                            if let image = UIImage(named: "addStar.svg") {
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



extension SearchViewController{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0{
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
            if !internetDataManager.isConnectedToNetwork() {
                self.internetDataManager.presentConnectionAlert(viewController: self)
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
