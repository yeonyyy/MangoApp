//
//  AppCoordinator.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/02.
//

import RxSwift

final class AppCoordinator : ReactiveCoordinator<Void> {
    
    var window: UIWindow
    var appDIContainer : AppDIContainer
    
    init(window: UIWindow, appDIContainer: AppDIContainer) {
        self.window = window
        self.appDIContainer = appDIContainer
    }
    
    override func start() -> Observable<Void> {
        
        let tabBarController = TabBarViewController()
        let tabbarCoordinator = TabBarCoordinator(viewController: tabBarController,
                                                  tabBarDIContainer: appDIContainer.makeMainDIContainer())
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        return coordinate(to: tabbarCoordinator).take(1)
        
    }
    
}
