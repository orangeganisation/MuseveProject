//
//  MainTabBarViewController.swift
//  ArtistsPresentetion
//
//  Created by Андрей Романюк on 4/4/19.
//  Copyright © 2019 Андрей Романюк. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    // MARK: - View Controllers
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    // MARK: - MyTools
    private func animatedSwitchTo(toIndex: Int) {
        if let currentController = selectedViewController,
            let fromView = currentController.view,
            let toView = viewControllers?[toIndex].view,
            let fromIndex = viewControllers?.firstIndex(of: currentController),
                fromIndex != toIndex
        {
            if abs(fromIndex - toIndex) > 1 {
                selectedIndex = toIndex
            } else {
                fromView.superview?.addSubview(toView)
                
                let screenWidth = UIScreen.main.bounds.size.width
                let scrollRight = toIndex > fromIndex
                let offset = scrollRight ? screenWidth : -screenWidth
                view.isUserInteractionEnabled = false
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0.0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0,
                    options: .curveEaseOut,
                    animations: {
                        fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y)
                        toView.center   = CGPoint(x: toView.center.x - offset, y: toView.center.y) },
                    completion: { finished in
                        self.view.isUserInteractionEnabled = true
                        fromView.removeFromSuperview()
                        self.selectedIndex = toIndex
                })
            }
        }
    }

    func switchToSearchController() {
        animatedSwitchTo(toIndex: 0)
    }
    
    func switchToFavoritesController() {
        animatedSwitchTo(toIndex: 1)
    }
    
    
    func switchToMapController() {
        animatedSwitchTo(toIndex: 2)
    }
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let toIndex = viewControllers?.firstIndex(of: viewController) {
            animatedSwitchTo(toIndex: toIndex)
            return true
        }
        return true
    }
}
