//
//  HousingViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

class HousingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TakesArrayData {
  var dataArray: [Any]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    print("appeared!")
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "housingCell", for: indexPath) as! HousingTableViewCell
    
    let housingUnitArray = dataArray as! [HousingUnit]
    
    cell.titleLabel.text = housingUnitArray[indexPath.row].driver
    cell.leftTextView.text = housingUnitArray[indexPath.row].hostName // TODO: add host address?
    cell.rightTextView.text = housingUnitArray[indexPath.row].students
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 204
  }

}
