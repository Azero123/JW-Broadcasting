//
//  MediaOnDemandCategory.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/4/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit
import AVKit

class MediaOnDemandCategory: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var _category="VODBible"
    var category:String {
        set (newValue){
            _category=newValue
            renewContent()
        }
        get {
            return _category
        }
    }
    @IBOutlet weak var mediaElements: UITableView!
    //pnr lg 1140,380
    //wsr lg 1280,719
    @IBOutlet weak var TopImage: UIImageView!
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewDescription: UITextView!
    @IBOutlet weak var categoryTitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let hMaskLayer:CAGradientLayer = CAGradientLayer()
        // defines the color of the background shadow effect
        let darkColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5).CGColor
        let lightColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0).CGColor
        
        // define a vertical gradient (up/bottom edges)
        let colorsForDarkness = [darkColor,lightColor]
        
        // without specifying startPoint and endPoint, we get a vertical gradient
        hMaskLayer.opacity = 1.0
        hMaskLayer.colors = colorsForDarkness
        
        hMaskLayer.startPoint = CGPointMake(0.0, 0.5)
        hMaskLayer.endPoint = CGPointMake(1.0, 0.5)
        
        hMaskLayer.bounds = self.TopImage.bounds
        hMaskLayer.anchorPoint = CGPointZero
        
        self.TopImage.layer.insertSublayer(hMaskLayer, atIndex: 0)
        
        
        
        
        
        
        let vMaskLayer:CAGradientLayer = CAGradientLayer()
        // defines the color of the background shadow effect
        let fadeIn = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1.0).CGColor
        let fadeOut = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0).CGColor
        
        // define a vertical gradient (up/bottom edges)
        let colors = [fadeIn, fadeIn ,fadeOut]
        let locations = [0.0, 0.7,0.98]
        
        // without specifying startPoint and endPoint, we get a vertical gradient
        vMaskLayer.opacity = 1.0
        vMaskLayer.colors = colors
        vMaskLayer.locations = locations
        vMaskLayer.bounds = self.TopImage.bounds
        vMaskLayer.anchorPoint = CGPointZero
        
        self.TopImage.layer.mask=vMaskLayer
        
        renewContent()
        
        // Do any additional setup after loading the view.
    }
    
    func renewContent(){
        
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        fetchDataUsingCache(categoryDataURL, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                testLogSteps=true
                self.categoryTitle.text=unfold("\(categoryDataURL)|category|name") as? String
                testLogSteps=false
            let imageURL=unfold("\(categoryDataURL)|category|images|pnr|lg") as? String
                if (imageURL != nil){
                    fetchDataUsingCache(imageURL!, downloaded: {
                        dispatch_async(dispatch_get_main_queue()) {
                    self.TopImage.image=imageUsingCache(imageURL!)
                        }
                })
                }
            self.mediaElements.reloadData()
            }
        })
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        let subcategories=unfold("\(categoryDataURL)|category|subcategories|count") as! Int?
        if (subcategories != nil){
            return subcategories!
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        let subcategories=unfold("\(categoryDataURL)|category|subcategories|\(section)|media|count") as? Int
        if (subcategories != nil){
            return subcategories!
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        let mediaElement:UITableViewCell=tableView.dequeueReusableCellWithIdentifier("mediaElement", forIndexPath: indexPath)
        mediaElement.textLabel?.text=unfold("\(categoryDataURL)|category|subcategories|\(indexPath.section)|media|\(indexPath.row)|title") as? String
        
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            mediaElement.textLabel?.textAlignment=NSTextAlignment.Right
        }
        else {
            mediaElement.textLabel?.textAlignment=NSTextAlignment.Left
        }
        return mediaElement
    }
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if (context.nextFocusedView?.isKindOfClass(UITableViewCell.self) == true && context.nextFocusedIndexPath != nil){
            let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
            let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
            
            previewDescription.text=unfold("\(categoryDataURL)|category|subcategories|\(context.nextFocusedIndexPath!.section)|media|\(context.nextFocusedIndexPath!.row)|description") as? String
            let imageURL=(unfold("\(categoryDataURL)|category|subcategories|\(context.nextFocusedIndexPath!.section)|media|\(context.nextFocusedIndexPath!.row)|images|wsr|lg") as? String)
            if (imageURL != nil){
                fetchDataUsingCache(imageURL!, downloaded: {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                    self.previewImageView.image=imageUsingCache(imageURL!)
                
                    }
                })
            }
        }
        
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        let videoURLString=unfold("\(categoryDataURL)|category|subcategories|\(indexPath.section)|media|\(indexPath.row)|files|last|progressiveDownloadURL") as? String
        let videoURL = NSURL(string: videoURLString!)
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
