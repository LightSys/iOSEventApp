//
//  AboutPageViewController.swift
//  iOSEventApp
//
//  Created by Littlesnowman88 on 3/21/2019.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

/**
 Displays copyright information about the iOSEventApp
 Changes here will affect the UI in Main Storyboard.
 */
class AboutPageViewController: UIViewController {
    
    //MARK: About Page
//    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var copyright: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = "https://github.com/LightSys/iOSEventApp"
        let privacy = "https://lightsys.org/?page=LightSys-Events-Privacy"
        var text = "\nLightSysEvents (iOS App) 1.0\nCopyright © 2018-2019 LightSys Technology Services, Inc.\nThis app was created for the use of distributing event information for ministry events.\n\nThis app\'s source code is also available under the GPLv3 open-source license at: \(url)"
        let part1 = setEndHyperLinkText(url: url, contents: text)
        text = "\nRead about our Privacy Policy at: \(privacy)"
        let part2 = setEndHyperLinkText(url: privacy, contents: text)
        let combined = NSMutableAttributedString()
        combined.append(part1)
        combined.append(part2)
        
        
        copyright.attributedText = combined
        copyright.isUserInteractionEnabled = true
        copyright.isEditable = false
    }
    
    /**
     allows for hyperlink text.
     thanks to "Code Different" help. -LS88
     inspiration: https://stackoverflow.com/questions/39238366/uitextview-with-hyperlink-text
     */
    func setEndHyperLinkText(url: String, contents: String) -> NSAttributedString {
        // Set the url to be the link
        if (url.count + 1 < contents.count) {
            let range = NSRange(location: contents.count - url.count, length: url.count)
            let link = NSMutableAttributedString(string: contents)
            link.setAttributes([.foregroundColor: UIColor.white, .underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
            link.addAttribute(NSAttributedString.Key.link, value: url, range: range)
            
            return link
        }
        return NSAttributedString()
    }
}
