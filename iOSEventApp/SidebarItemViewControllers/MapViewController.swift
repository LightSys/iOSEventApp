//
//  MapViewController.swift
//  iOSEventApp
//
//  Created by Aidan Perez on 3/9/20.
//  Copyright © 2020 LightSys. All rights reserved.
//

import UIKit

/*Displays Map of Events */
class MapViewController: UIViewController {
    //loads view to controller
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var lowerImageView: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    /*lets the lower floor stepper zoom in and out
     sender: lower floor stepper*/
    @IBAction func resizeLowerFloor(_ sender: UIStepper) {
        let mapImage = lowerImageView.image!
        var i: Double = 50
        if sender.value > 50 {
            i += 50
        } else if sender.value < 50 {
            i -= 1
        }

        let size = CGSize(width: i, height: i)
        print(i)
        lowerImageView.image = resizeImage(image: mapImage, targetSize: size)
    }
    
    /*Lets the main floor stepper zoom in and out
     sender: main floor stepper*/
    @IBAction func resizeMainFloor(_ sender: UIStepper) {
        let mapImage = mainImageView.image!
        var i: Double = 50
        if sender.value > 50 {
            i += 1
        } else if sender.value < 50 {
            i -= 1
        }
        let size = CGSize(width: i, height: i)
        print(i)
        mainImageView.image = resizeImage(image: mapImage, targetSize: size)
    }

    /*Resizes an image
     image: image you want to resize
     targetSize: size you want to make this image
     returns new image with new size*/
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let heightIncrease : CGFloat = 1.0
        print(image.size)
        print("Height increase set")
        let widthIncrease : CGFloat = 1.0
        print("Width increase set")
        
        var newSize : CGSize
        print("New size")
        newSize = CGSize(width: image.size.width + widthIncrease, height: image.size.height + heightIncrease)
        print("New size initialized with width and height increase")
        
        //rest of function received from https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height)
        print("rect created")
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print(newImage!.size)
        return newImage!
    }
}
