//
//  ExtensionToolBox.swift
//  VoiceMemo
//
//  Created by 付 旦 on 8/22/17.
//  Copyright © 2017 付 旦. All rights reserved.
//

import UIKit

extension Date {
    func toTimeString() -> String{
        return DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .medium)
    }
}

extension UITableView {
    /**only good for one section*/
    func reloadAnimated() {
        self.reloadSections(IndexSet(integer:0), with: .automatic)
    }
    
    func addRefresh(with action : Selector) {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "PULL TO REFRESH") //, attributes: [NSForegroundColorAttributeName : UIColor.lightText]
        refreshControl.addTarget(nil, action: action, for: UIControlEvents.valueChanged)
        //refreshControl.tintColor = UIColor.lightText
        self.refreshControl = refreshControl
    }
    
    
    func endRefresh() {
        if self.refreshControl?.isRefreshing ?? false{
            self.refreshControl?.endRefreshing()
        }
    }
}
