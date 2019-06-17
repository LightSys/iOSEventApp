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
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var copyright: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = "https://github.com/LightSys/iOSEventApp"
        let text = "LightSysEvents (iOS App) 1.0\nCopyright © 2018-2019 LightSys Technology Services, Inc. this app was created for the use of distributing event information for ministry events.\n\nThisApp\'s source code is also available under the GPLv3 open-source license at: " + url
        
        headerLabel.text = "About"
        setEndHyperLinkText(url: url, textView: copyright, contents: text)
    }
    
    /**
     allows for hyperlink text.
     thanks to "Code Different" help. -LS88
     inspiration: https://stackoverflow.com/questions/39238366/uitextview-with-hyperlink-text
     */
    func setEndHyperLinkText(url: String, textView: UITextView, contents: String) {
        // Set the url to be the link
        if (url.count + 1 < contents.count) {
            let range = NSRange(location: contents.count - url.count, length: url.count)
            let link = NSMutableAttributedString(string: contents)
            link.setAttributes([.foregroundColor: UIColor.white, .underlineStyle: NSUnderlineStyle.single.rawValue], range: range)
            link.addAttribute(NSAttributedString.Key.link, value: url, range: range)
            
            //set the link inside the text view
            textView.attributedText = link
            textView.isUserInteractionEnabled = true
            textView.isEditable = false
            
        }
    }
}
