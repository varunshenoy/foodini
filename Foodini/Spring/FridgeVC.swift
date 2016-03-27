//
//  FridgeVC.swift
//  ClarifaiApiDemo
//
//  Created by Varun Shenoy on 3/26/16.
//  Copyright © 2016 Clarifai, Inc. All rights reserved.
//

import UIKit
import Kanna
import SafariServices

class FridgeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let imagePicker = UIImagePickerController()
    
    var foods: [Food] = [Food]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        getFood()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("foodItem")!
        
        let image = cell.viewWithTag(1) as! UIImageView
        image.image = foods[indexPath.row].image.imageRotatedByDegrees(90, flip: false)
        
        let foodName = cell.viewWithTag(2) as! UILabel
        foodName.text = foods[indexPath.row].name
        
        let tag = cell.viewWithTag(3) as! UIButton
        if foods[indexPath.row].name == "Tomato" || foods[indexPath.row].name == "Zucchini" || foods[indexPath.row].name == "Corn" || foods[indexPath.row].name == "Spinach"{
            tag.setTitle("VEGETABLE", forState: .Normal)
            tag.backgroundColor = UIColor(red:0.20, green:0.76, blue:0.30, alpha:1.00)
        } else if foods[indexPath.row].name == "Banana" || foods[indexPath.row].name == "Orange" || foods[indexPath.row].name == "Apple" || foods[indexPath.row].name == "Grapes" {
            tag.setTitle("FRUIT", forState: .Normal)
            tag.backgroundColor = UIColor(red:0.80, green:0.00, blue:0.00, alpha:1.00)
        } else if foods[indexPath.row].name == "Bread" || foods[indexPath.row].name == "Cookie" || foods[indexPath.row].name == "Flour" || foods[indexPath.row].name == "Cereal" {
            tag.setTitle("GRAINS", forState: .Normal)
            tag.backgroundColor = UIColor(red:0.79, green:0.37, blue:0.00, alpha:1.00)
        } else if foods[indexPath.row].name == "Meat" || foods[indexPath.row].name == "Chicken" || foods[indexPath.row].name == "Egg" || foods[indexPath.row].name == "Steak" {
            tag.setTitle("PROTEIN", forState: .Normal)
            tag.backgroundColor = UIColor(red:0.52, green:0.29, blue:1.00, alpha:1.00)
        } else if foods[indexPath.row].name == "Candy" || foods[indexPath.row].name == "Oil" || foods[indexPath.row].name == "Cake" || foods[indexPath.row].name == "Sugar"{
            tag.setTitle("FATS", forState: .Normal)
            tag.backgroundColor = UIColor(red:0.00, green:0.62, blue:0.51, alpha:1.00)
        } else {
            tag.alpha = 0
        }
        
        return cell

    }
    
    func getFood() {
        let defaults = NSUserDefaults.standardUserDefaults()
        var images:[UIImage] = [UIImage]()
        var foodNames:[String] = [String]()
        if let pics = defaults.objectForKey("pictures") {
            let pictures = pics as! [String]
            for i in pictures {
                let decodedData = NSData(base64EncodedString: i, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                let decodedimage = UIImage(data: decodedData!)
                images.append(decodedimage!)
            }
        } else {
            images = []
        }
        
        if let f = defaults.objectForKey("foodNames") {
            let food = f as! [String]
            foodNames = food
        } else {
            foodNames = []
        }
        
        for (index, n) in images.enumerate() {
            let food = Food()
            print(index)
            print(n)
            food.image = n
            food.name = foodNames[index]
            foods.append(food)
        }

    }
    
    @IBAction func takePicture(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        let nextScene = storyboard!.instantiateViewControllerWithIdentifier("recogFeed") as! RecognitionVC
        let img = info[UIImagePickerControllerOriginalImage] as? UIImage
        nextScene.image = img
        presentViewController(nextScene, animated: true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let saveAction = UITableViewRowAction(style: .Normal, title: "Delete Item") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            self.foods.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
        let calorieAction = UITableViewRowAction(style: .Normal, title: "Calorie\nLookup") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            let svc = SFSafariViewController(URL: NSURL(string: "http://www.calorieking.com/foods/search.php?keywords=\(self.foods[indexPath.row].name)")!)
            svc.delegate = self
            svc.view.tintColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.00)
            self.presentViewController(svc, animated: true, completion: nil)
        }

        calorieAction.backgroundColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.00)
        saveAction.backgroundColor = UIColor(red:0.83, green:0.06, blue:0.15, alpha:1.00)
        //saveAction.backgroundColor = UIColor(patternImage: UIImage(named:"sample")!)
        return [saveAction, calorieAction]
        
    }
    
    @IBAction func createMeal(sender: AnyObject) {
        var query = "http://allrecipes.com/search/results/?wt=&ingIncl="
        for i in foods {
            query = query + "," + i.name
        }
        query = query + "&sort=re"
        let url = NSURL(string: query)
        print(url)
        let svc = SFSafariViewController(URL: url!)
        svc.delegate = self
        svc.view.tintColor = UIColor(red:0.99, green:0.71, blue:0.33, alpha:1.00)
        self.presentViewController(svc, animated: true, completion: nil)
        /*if let doc = Kanna.HTML(url: url!, encoding: NSUTF8StringEncoding) {
            for link in doc.css("a, link") {
                let svc = SFSafariViewController(URL: NSURL(string: link["href"]!)!)
                svc.delegate = self
                svc.view.tintColor = UIColor(red:0.99, green:0.71, blue:0.33, alpha:1.00)
                self.presentViewController(svc, animated: true, completion: nil)
            }
        }*/
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

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        // calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        CGContextScaleCTM(bitmap, yFlip, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
