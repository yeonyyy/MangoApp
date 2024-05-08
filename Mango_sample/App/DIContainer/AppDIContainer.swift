//
//  AppDIContainer.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/03.
//

import Foundation

final class AppDIContainer {
    
    func makeMainDIContainer() -> TabBarDIContainer {
        return TabBarDIContainer.init()
    }
    
}
