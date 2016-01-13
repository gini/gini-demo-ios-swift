//
//  GINIDemoDocumentDetailTableViewController.swift
//  gini-swift-demo-ios
//
//  Created by Gini on 07/01/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

class GINIDemoDocumentTableViewController: UITableViewController {
    
    // Public properties
    var extractions: [String:String]?
    
    // Private properties
    private var sortedKeys: Array<String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (extractions != nil) {
            self.sortedKeys = self.extractions!.keys.sort()
            print(self.sortedKeys)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (extractions != nil) {
            return self.extractions!.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("documentDetailCell", forIndexPath: indexPath)
        let key = sortedKeys![indexPath.row]
        let value = self.extractions![key]
        cell.textLabel?.text = value
        cell.detailTextLabel?.text = key
        return cell
    }
    
    // MARK: Memory management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
