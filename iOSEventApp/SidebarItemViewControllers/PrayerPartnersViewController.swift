//
//  PrayerPartnersTableViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/6/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

class PrayerPartnersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TakesArrayData {

  @IBOutlet weak var tableView: UITableView!

  var dataArray: [Any]?
  var stringArray: [String]? {
    get {
      return (dataArray as? [PrayerPartnerGroup])?.map({ $0.students! })
    }
  }
  let cellReuseIdentifier = "prayerPartnersReuseIdentifier"
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Table view data source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: PrayerPartnersTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! PrayerPartnersTableViewCell
    
    cell.groupNumberLabel.text = "Group ".appending(String(indexPath.row + 1))
    cell.partnersView.text = stringArray![indexPath.row]
    
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 120
  }
}
