//
//  InformationPageViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

class InformationPageViewController: UIViewController, TakesArrayData, UITableViewDelegate, UITableViewDataSource {
  
  var dataArray: [Any]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "infoPageCell", for: indexPath) as! InformationPageTableViewCell
    
    let infoSectionArray = dataArray as! [InformationPageSection]
    
    cell.headerLabel.text = infoSectionArray[indexPath.row].title
    cell.textView.text = infoSectionArray[indexPath.row].information
    
    return cell
  }
  
}
