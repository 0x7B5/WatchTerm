//
//  SettingsVC.swift
//  WatchTerm
//
//  Created by Vlad Munteanu on 3/12/19.
//  Copyright © 2019 Vlad Munteanu. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC: UIViewController {
    
    //Load View
    public override func loadView() {
        //self.view = attackView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        self.title = "Settings"
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }

    
}
