//
//  SearchViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/15/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController, UISearchBarDelegate {

    // MARK: - Vars
    var internetDataManager = InternetDataManager()
    var currentArtist:Artist?
    var currentSearchText = String()
    
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
    
    // MARK: - Actions
    @IBAction func loadFacebookPage(_ sender: UIButton) {
        if let artist = currentArtist{
            if let url = URL(string: artist.getFacebookPage()){
                let safari = SFSafariViewController(url: url)
                safari.preferredBarTintColor = #colorLiteral(red: 0.1660079956, green: 0.1598443687, blue: 0.1949053109, alpha: 1)
                present(safari, animated: true, completion: nil)
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
        if let codedSearchText = currentSearchText.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed){
            if let url = URL(string: StringConstants().getArtistUrl + codedSearchText + StringConstants().appId){
                let task = URLSession.shared.dataTask(with: url) {(artistData, response, error) in
                    if error != nil{
                        DispatchQueue.main.async {
                            self.internetDataManager.presentConnectionAlert(viewController: self)
                            self.searchSpinner.stopAnimating()
                        }
                    }else{
                        if let data = artistData{
                            if let artist = try? JSONDecoder().decode(Artist.self, from: data){
                                self.currentArtist = artist
                                if let imageUrl = URL(string: artist.getImageUrl()){
                                    if let imageData = try? Data(contentsOf: imageUrl){
                                        DispatchQueue.main.async {
                                            if URL(string: artist.getFacebookPage()) != nil{
                                                self.facebookButton.isEnabled = true
                                            }else{
                                                self.facebookButton.isEnabled = false
                                            }
                                            if let image = UIImage(data: imageData){
                                                self.artistImage.image = image
                                            }
                                            self.artistNameLabel.text = artist.getName()
                                            self.searchSpinner.stopAnimating()
                                            self.presentationView.isHidden = false
                                            self.searchResultsLabel.isHidden = true
                                            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0.0, options: .allowUserInteraction, animations: {
                                                self.presentationView.alpha = 1.0
                                            }, completion: nil)
                                        }
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    if self.searchSpinner.isAnimating{
                                        self.searchSpinner.stopAnimating()
                                    }
                                    self.searchResultsLabel.text = StringConstants().noResults
                                    self.searchResultsLabel.isHidden = false
                                }
                            }
                        }
                    }
                }
                task.resume()
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
            searchResultsLabel.text = StringConstants().search
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
            searchResultsLabel.text = StringConstants().enterName
            if let url = URL(string: "https://google.com"){
                let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                    if error != nil{
                        DispatchQueue.main.async {
                            self.internetDataManager.presentConnectionAlert(viewController: self)
                        }
                    }
                }
                task.resume()
            }
            currentSearchText = searchText
        }else{
            searchSpinner.startAnimating()
            if currentSearchText != searchText {
                currentSearchText = searchText
                searchAndPresentArtist()
            }
        }
    }
}
