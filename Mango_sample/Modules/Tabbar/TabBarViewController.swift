//
//  tabBarViewController.swift
//  Mango_sample
//
//  Created by rayeon lee on 2024/04/02.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    var coordinator: TabBarCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
            appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
            self.tabBar.scrollEdgeAppearance = appearance
            self.tabBar.standardAppearance = appearance
            self.tabBar.tintColor = .black
        }else {
            UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
            self.tabBar.barTintColor = .white
            self.tabBar.isTranslucent = false
            self.tabBar.tintColor = .black
        }
        
        
        // Do any additional setup after loading the view.
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
