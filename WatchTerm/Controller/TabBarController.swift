//
//  TabBarController.swift
//  WatchTerm
//
//  Created by Vlad Munteanu on 3/12/19.
//  Copyright © 2019 Vlad Munteanu. All rights reserved.
//


import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tabBar.isTranslucent = false
        UITabBar.appearance().barTintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        let mainTableVC = CommandsTableVC()
        mainTableVC.tabBarItem.title = "Commands"
        mainTableVC.tabBarItem.image = UIImage(named: "CommandsIcon")
        
        let settingsVC = SettingsVC()
        settingsVC.tabBarItem.title = "Settings"
        settingsVC.tabBarItem.image = UIImage(named: "SettingsIcon")
        
        
        let viewControllerList = [mainTableVC, settingsVC]
        viewControllers = viewControllerList.map { UINavigationController(rootViewController: $0) }
    }
}
