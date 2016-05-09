//
//  SideMenuViewControllerTableViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 3/5/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit
import Firebase

protocol SidePanelViewControllerDelegate {
    func cellSelected(cell: MenuItems)
}

class SideMenuViewControllerTableViewController: UITableViewController {

    var delegate: SidePanelViewControllerDelegate?
    var cellItems: Array<MenuItems>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated. 
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellItems == nil ? 0 : cellItems.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MenuItemCell
        cell.configureForItems(cellItems[indexPath.row])
        return cell
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = cellItems[indexPath.row]
        if selectedItem.title == "Logout" {
            logoutUser()
        }
        delegate?.cellSelected(selectedItem)
    }

    func logoutUser() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            rootRef.unauth()
        })
    }
}
