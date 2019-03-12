//
//  ViewController.swift
//  WatchTerm
//
//  Created by Vlad Munteanu on 3/12/19.
//  Copyright © 2019 Vlad Munteanu. All rights reserved.
//

import UIKit

class CommandsTableVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        self.title = "Commands"
        self.navigationController?.navigationBar.layer.masksToBounds = false
    }

}

