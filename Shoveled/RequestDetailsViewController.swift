//
//  RequestDetailsViewController.swift
//  Shoveled
//
//  Created by Joshua Walsh on 1/17/17.
//  Copyright © 2017 Lucky Penguin. All rights reserved.
//

import UIKit
import Firebase

class RequestDetailsViewController: UITableViewController {
    
    fileprivate enum CellIdentifier: String {
        case addressCell = "addressCell"
        case descriptionCell = "descriptionCell"
        case moreInfoCell = "moreInfoCell"
        case priceCell = "priceCell"
        case acceptCell = "acceptCell"
    }
    
    fileprivate var tableViewData: [[CellIdentifier]] = []
    fileprivate var addressCell: RequestDetailCell?
    fileprivate var descriptionCell: RequestDetailCell?
    fileprivate var moreInfoCell: RequestDetailCell?
    fileprivate var priceCell: RequestDetailCell?
    fileprivate var acceptCell: RequestDetailCell?
    
    var addressString: String? {
        get {
            return self.addressCell?.addressLabel?.text
        }
        set {
            self.addressCell?.addressLabel?.text = newValue
        }
    }
    
    var descriptionString: String? {
        get {
            return self.descriptionCell?.descriptionLabel?.text
        }
        set {
            self.descriptionCell?.descriptionLabel?.text = newValue
        }
    }
    
    var moreInfoString: String? {
        get {
            return self.moreInfoCell?.moreInfoLabel?.text
        }
        set {
            self.moreInfoCell?.moreInfoLabel?.text = newValue
        }
    }
    
    var priceString: String? {
        get {
            return self.priceCell?.priceLabel?.text
        }
        set {
            self.priceCell?.priceLabel?.text = newValue
        }
    }
    
    var latitude: NSNumber?
    var longitude: NSNumber?
    var addedByUser: String?
    var otherInfo: String?
    var status: String?
    var id: String?
    var createdAt: String?
    var acceptedByUser: String?
    var stripeChargeToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rebuildTableViewDataAndRefresh()
    }

    fileprivate func rebuildTableViewDataAndRefresh() {
        let tableViewData: [[CellIdentifier]]
        
        tableViewData = self.tableViewDataForRequest()
        
        self.tableViewData = tableViewData
        self.tableView?.tableFooterView = UIView()
        self.tableView?.reloadData()
    }
    
    fileprivate func tableViewDataForRequest() -> [[CellIdentifier]] {
        var tableViewData: [[CellIdentifier]] = []
        var requestData: [CellIdentifier] = []
        
        requestData.append(.addressCell)
        requestData.append(.descriptionCell)
        requestData.append(.moreInfoCell)
        requestData.append(.priceCell)
        requestData.append(.acceptCell)
        
        tableViewData.append(requestData)
        
        return tableViewData
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewData[section].count
    }
    
    fileprivate func indexPathForCellIdentifier(_ identifier: CellIdentifier) -> IndexPath? {
        for (sectionIndex, sectionData) in self.tableViewData.enumerated() {
            for (rowIndex, cellIdentifier) in sectionData.enumerated() {
                if cellIdentifier == identifier {
                    return IndexPath(row: rowIndex, section: sectionIndex)
                }
            }
        }
        
        return nil
    }
    
    fileprivate func identifier(at indexPath: IndexPath) -> CellIdentifier? {
        return self.tableViewData[indexPath.section][indexPath.row]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellIdentifier = self.identifier(at: indexPath) else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier.rawValue)!
        
        switch cellIdentifier {
        case .addressCell:
            let addressCell = cell as! RequestDetailCell
            self.addressCell = addressCell
        case .descriptionCell:
            let descriptionCell = cell as! RequestDetailCell
            self.descriptionCell = descriptionCell
        case .moreInfoCell:
            let moreInfoCell = cell as! RequestDetailCell
            self.moreInfoCell = moreInfoCell
        case .priceCell:
            let priceCell = cell as! RequestDetailCell
            self.priceCell = priceCell
        case .acceptCell:
            let acceptCell = cell as! RequestDetailCell
            self.acceptCell = acceptCell
        }

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
