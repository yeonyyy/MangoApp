//
//  FavoriteCoordinator.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/02.
//

import RxSwift

class FavoriteCoordinator : ReactiveCoordinator<Void> {
    
    public let rootController: UIViewController
    private var tabBarDIContainer : TabBarDIContainer
    
    init(_ diContainer : TabBarDIContainer) {
        self.rootController = diContainer.makefavoriteViewController()
        self.tabBarDIContainer = diContainer
    }
    
    override func start() -> Observable<Void> {
        
        return Observable.never()
    }
    
}
