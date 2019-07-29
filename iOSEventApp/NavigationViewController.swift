//
//  NavigationViewController.swift
//  iOSEventApp
//
//  Created by Nate Gamble on 6/21/19.
//  Copyright © 2019 LightSys. All rights reserved.
//

import UIKit


class NavigationViewController: UINavigationController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    var themes:[Theme]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let loader = DataController(newPersistentContainer: container)
        themes = loader.fetchAllObjects(onContext: container.viewContext, forName: "Theme") as? [Theme]
        
        if let _ = UserDefaults.standard.string(forKey: "currentEvent") {
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let loader = DataController(newPersistentContainer: container)
            themes = loader.fetchAllObjects(onContext: container.viewContext, forName: "Theme") as? [Theme]
            for theme in themes! {
                if theme.themeName == "themeDark" {
                    let themeRGB: String = String((theme.themeValue?.split(separator: "#")[0])!)
                    let greenStartIdx = themeRGB.index(themeRGB.startIndex, offsetBy: 2)
                    let blueStartIdx = themeRGB.index(greenStartIdx, offsetBy: 2)
                    let themeRed:Int = Int(String(themeRGB[..<greenStartIdx]), radix:16)!
                    let themeGreen:Int = Int(String(themeRGB[greenStartIdx..<blueStartIdx]), radix:16)!
                    let themeBlue:Int = Int(String(themeRGB[blueStartIdx..<themeRGB.endIndex]), radix:16)!
                    let themeColor = UIColor(red: CGFloat(themeRed)/256.0, green: CGFloat(themeGreen)/256.0, blue: CGFloat(themeBlue)/256.0, alpha: 0.15)
                    navBar.barTintColor = themeColor
                    
                }
            }
        }
        
        
    }
}
