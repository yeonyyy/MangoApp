//
//  TabBarDIContainer.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/03.
//

import UIKit

final class TabBarDIContainer {
    
    // MARK: - Home
    func makeHomeViewController() -> HomeViewController {
        return HomeViewController(viewModel: makeHomeViewModel())
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel()
    }
    
    func makeHomeCoordinator() -> HomeCoordinator {
        return HomeCoordinator(self)
    }
    
    // MARK: - Search
    func makeSearchViewController() -> SearchViewController {
        return SearchViewController(viewModel: makeSearchViewModel())
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        return SearchViewModel()
    }
    
    func makeSearchCoordinator() -> SearchCoordinator {
        return SearchCoordinator(self)
    }
    
    // MARK: - Cart
    func makeCartViewController() -> CartViewController {
        return CartViewController.init()
    }
    
    func makeCartCoordinator() -> CartCoordinator {
        return CartCoordinator(self)
    }
    
    // MARK: - Favorite
    func makefavoriteViewController() -> FavoriteViewController {
        return FavoriteViewController.init()
    }
    
    func makeFavoriteCoordinator() -> FavoriteCoordinator {
        return FavoriteCoordinator(self)
    }
    
    // MARK: - Account
    func makeAccountViewController() -> AccountViewController {
        return AccountViewController.init()
    }
    
    func makeAccountCooridnator() -> AccountCoordinator {
        return AccountCoordinator(self)
    }
    
}
