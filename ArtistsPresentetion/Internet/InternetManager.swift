//
//  InternetManager.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 2/19/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import SafariServices

class InternetDataManager{
    
    public func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    static func openSafariPage(withUrl url: URL, byController viewController: UIViewController) {
        let safari = SFSafariViewController(url: url)
        safari.preferredBarTintColor = #colorLiteral(red: 0.1660079956, green: 0.1598443687, blue: 0.1949053109, alpha: 1)
        viewController.present(safari, animated: true, completion: nil)
    }
    
    
    func presentConnectionAlert(viewController:UIViewController){
        let alert = UIAlertController(title: "Internet Connection", message: "There is a problem with internet connection. Please, turn ON cellular or connect to WiFi.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: StringConstants.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: StringConstants.settings, style: .default, handler: { (action) in
            UIApplication.shared.open(URL(string: "App-Prefs:")!)
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    func presentFailedDataLoadingAlert(viewController:UIViewController){
        let alert = UIAlertController(title: "Data Loading", message: "Failed to load data. Please, try later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: StringConstants.ok, style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    func getArtist(viewController: UIViewController, searchText: String, completion: @escaping (_ error: Error?,_ artist: Artist?) -> Void) {
        if self.isConnectedToNetwork(){
            if let url = URL(string: StringConstants.getArtistUrl + searchText + StringConstants.appId){
                let task = URLSession.shared.dataTask(with: url) {(artistData, response, error) in
                    if error != nil{
                        completion(error, nil)
                    }else{
                        if let data = artistData{
                            if let artist = try? JSONDecoder().decode(Artist.self, from: data){
                                completion(nil, artist)
                            }else{
                                completion(nil, nil)
                            }
                        }
                    }
                }
                task.resume()
            }
        }else{
            self.presentConnectionAlert(viewController: viewController)
        }
    }
}
