//
//  tabBarCoordinator.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/02.
//

import UIKit
import RxSwift

final class TabBarCoordinator : ReactiveCoordinator<Void> {
    
    let rootViewController : TabBarViewController!
    let tabBarDIContainer : TabBarDIContainer!
    
    init(viewController: TabBarViewController, tabBarDIContainer: TabBarDIContainer) {
        self.rootViewController = viewController
        self.tabBarDIContainer = tabBarDIContainer
    }
    
    override func start() -> Observable<Void> {
        
        let tabBarController = self.rootViewController
        tabBarController?.coordinator = self
        
        let homeCoordinator =  tabBarDIContainer.makeHomeCoordinator(homeNavigationController.viewControllers[0])
        let searchCoordinator = tabBarDIContainer.makeSearchCoordinator(searchNavigationController.viewControllers[0])
        
        _ = [homeCoordinator, searchCoordinator].map {
            coordinate(to: $0)
        }
        
        tabBarController?.viewControllers = [
            homeNavigationController,
            searchNavigationController,
//            cartNavigationController,
//            favoriteNavigationController,
//            accountNavigationController
        ]
        
        return Observable.never()
    }
    
    private lazy var homeNavigationController : UINavigationController = {
        let controller = tabBarDIContainer.makeHomeViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem =  UITabBarItem(title: nil, image: UIImage(named: "house"), tag: 0)
        navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 5, bottom: -5, right: -5)
        navigationController.navigationBar.isHidden = true
        return navigationController
    }()
    
    private lazy var searchNavigationController : UINavigationController = {
        let controller = tabBarDIContainer.makeSearchViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem.title = "shop"
        navigationController.tabBarItem.image = nil
        navigationController.navigationBar.isHidden = false
        return navigationController
    }()
    
    private lazy var cartNavigationController : UINavigationController = {
        let controller = tabBarDIContainer.makeCartViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "cart"), tag: 1)
        navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 5, bottom: -5, right: -5)
        navigationController.navigationBar.isHidden = false
        return navigationController
    }()
    
    private lazy var favoriteNavigationController : UINavigationController = {
        let controller = tabBarDIContainer.makefavoriteViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "heart"), tag: 1)
        navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 5, bottom: -5, right: -5)
        navigationController.navigationBar.isHidden = false
        return navigationController
    }()
    
    private lazy var accountNavigationController : UINavigationController = {
        let controller = tabBarDIContainer.makeAccountViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "person"), tag: 1)
        navigationController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 5, bottom: -5, right: -5)
        navigationController.navigationBar.isHidden = false
        return navigationController
    }()
    
}
