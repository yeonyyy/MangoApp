//
//  HomeCoordinator.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/02.
//

import RxSwift

class HomeCoordinator : ReactiveCoordinator<Void> {
    
    private let rootController: UIViewController
    private var tabBarDIContainer : TabBarDIContainer
    
    init(_ diContainer : TabBarDIContainer) {
        self.rootController = diContainer.makeHomeViewController()
        self.tabBarDIContainer = diContainer
    }
    
    override func start() -> Observable<Void> {
        
        return Observable.never()
    }
    
}
