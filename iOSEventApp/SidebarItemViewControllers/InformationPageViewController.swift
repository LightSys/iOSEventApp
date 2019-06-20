//
//  InformationPageViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

extension InformationPageSection: IsComparable {
    var compareString: String? {
        return String(order)
    }
}

/**
 Displays each section in the data array as one cell. There may need to be multiple
 instances of InformationPageViewController in the sidebar, as it is the generic
 "information page" for the event app.
 */
class InformationPageViewController: UIViewController, TakesArrayData, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    var headerText: String?
    var dataArray: [Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = headerText
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
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
        var infoArray = infoSectionArray[indexPath.row].information?.components(separatedBy: "~")
        cell.textView.text = infoArray![0]
        for index in 1..<infoArray!.count {
            cell.textView.text += "•\(infoArray![index])"
        }
        
        return cell
    }
    
}
