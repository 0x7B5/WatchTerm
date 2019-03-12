//
//  CommandsView.swift
//  WatchTerm
//
//  Created by Vlad Munteanu on 3/12/19.
//  Copyright © 2019 Vlad Munteanu. All rights reserved.
//

import Foundation
import SnapKit

public class CommandsView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect.zero
        self.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        intializeUI()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func intializeUI() {
        
    }
    
    func createConstraints() {
        
    }
    
    
    
}
