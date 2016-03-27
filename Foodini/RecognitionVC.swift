//
//  RecognitionVC.swift
//  ClarifaiApiDemo
//
//  Created by Varun Shenoy on 3/26/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

import UIKit

class RecognitionVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recognizedLabel: UILabel!
    
    var image: UIImage!
    var foodArray: [String] = [String]()
    var index: Int = 0
    
    private lazy var client : ClarifaiClient = ClarifaiClient(appID: clarifaiClientID, appSecret: clarifaiClientSecret)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        recognizedLabel.text = "recognizing..."
        recognizeImage(image)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func recognizeImage(image: UIImage!) {
        // Scale down the image. This step is optional. However, sending large images over the
        // network is slow and does not significantly improve recognition performance.
        let size = CGSizeMake(320, 320 * image.size.height / image.size.width)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Encode as a JPEG.
        let jpeg = UIImageJPEGRepresentation(scaledImage, 0.9)!
        
        // Send the JPEG to Clarifai for standard image tagging.
        client.recognizeJpegs([jpeg]) {
            (results: [ClarifaiResult]?, error: NSError?) in
            if error != nil {
                print("Error: \(error)\n")
                self.recognizedLabel.text = "Sorry, there was an error recognizing your image."
            } else {
                let filteredArray1 = results![0].tags.filter({$0 != "no person"})
                let filteredArray = filteredArray1.filter({ $0 != "food"})
                self.recognizedLabel.text = "Is this a " + filteredArray[0] + "?"
                self.foodArray = filteredArray
                self.index += 1

            }
        }
    }

    @IBAction func notCorrect(sender: AnyObject) {
        if index < foodArray.count {
            recognizedLabel.text = "Is this a " + foodArray[index] + "?"
            index += 1
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    @IBAction func isCorrect(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let imageData = UIImagePNGRepresentation(image)
        let b64 = imageData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        if let pics = defaults.objectForKey("pictures") {
            var pictures = pics as! [String]
            pictures.append(b64)
            defaults.setObject(pictures, forKey: "pictures")
        } else {
            defaults.setObject([b64], forKey: "pictures")
        }
        if let f = defaults.objectForKey("foodNames") {
            var foods = f as! [String]
            print(foodArray)
            foods.append(foodArray[index - 1].capitalizedString)
            defaults.setObject(foods, forKey: "foodNames")
        } else {
            defaults.setObject([foodArray[index - 1].capitalizedString], forKey: "foodNames")
        }
        let nextScene = storyboard!.instantiateViewControllerWithIdentifier("tableFeed") as! FridgeVC
        presentViewController(nextScene, animated: true, completion: nil)

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
