//
//  SearchViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/15/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {

    // MARK: - Vars
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
    
    //MARK: - Search Bar & Keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchSpinner.startAnimating()
        searchResultsLabel.isHidden = true
        searchAndPresentArtist()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0{
            if searchSpinner.isAnimating{
                searchSpinner.stopAnimating()
            }
            if searchResultsLabel.isHidden{
                searchResultsLabel.isHidden = false
            }
            searchResultsLabel.text = "Search"
        }else if (1..<3).contains(searchText.count){
            if searchSpinner.isAnimating{
                searchSpinner.stopAnimating()
            }
            if searchResultsLabel.isHidden{
                searchResultsLabel.isHidden = false
            }
            searchResultsLabel.text = "Enter name"
            if let url = URL(string: "https://google.com"){
                let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                    if error != nil{
                        DispatchQueue.main.async {
                            self.presentConnectionAlert()
                        }
                    }
                }
                task.resume()
            }
        }else{
            searchSpinner.startAnimating()
            if currentSearchText != searchText {
                currentSearchText = searchText
                searchResultsLabel.isHidden = true
                searchAndPresentArtist()
            }
        }
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
    func presentConnectionAlert(){
        let alert = UIAlertController(title: "Internet Connection", message: "There is a problem with internet connection. Please, turn ON cellular or connect to WiFi", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
            UIApplication.shared.open(URL(string: "App-Prefs:")!)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func searchAndPresentArtist(){
        if let codedSearchText = currentSearchText.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed){
            if let url = URL(string: "https://rest.bandsintown.com/artists/\(codedSearchText)?app_id=ArtEve"){
                let task = URLSession.shared.dataTask(with: url) {(artistData, response, error) in
                    if error != nil{
                        DispatchQueue.main.async {
                            self.presentConnectionAlert()
                            self.searchSpinner.stopAnimating()
                        }
                    }else{
                        if let data = artistData{
                            if let artist = try? JSONDecoder().decode(Artist.self, from: data){
                                self.currentArtist = artist
                                DispatchQueue.main.async {
                                    self.searchSpinner.stopAnimating()
                                }
                            }else{
                                DispatchQueue.main.async {
                                    if self.searchSpinner.isAnimating{
                                        self.searchSpinner.stopAnimating()
                                    }
                                    self.searchResultsLabel.text = "No results"
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
