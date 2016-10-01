//
//  SideMenuViewControllerTableViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 3/5/16.
//  Copyright © 2016 Lucky Penguin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

protocol SidePanelViewControllerDelegate {
    func cellSelected(_ cell: MenuItems)
}

class SideMenuViewControllerTableViewController: UITableViewController {

    var delegate: SidePanelViewControllerDelegate?
    var cellItems: Array <MenuItems>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellItems == nil ? 0 : cellItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MenuItemCell
        cell.configureForItems(cellItems[(indexPath as NSIndexPath).row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = cellItems[(indexPath as NSIndexPath).row]
        if selectedItem.title == "Logout" {
            logoutUser()
        } 
        delegate?.cellSelected(selectedItem)
    }

    func logoutUser() {
        try! FIRAuth.auth()!.signOut()
        self.performSegue(withIdentifier: "notLoggedIn", sender: nil)
    }
    
}
