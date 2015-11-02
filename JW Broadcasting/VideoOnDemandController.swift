//
//  VideoOnDemandController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/25/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit
import AVKit

class VideoOnDemandController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var videoCategoryTable: UITableView!
    @IBOutlet weak var videoCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //http://mediator.jw.org/v1/categories/ASL/VideoOnDemand?detailed=1
        
        renewContent()
    
    }
    
    
    var previousLanguageCode=languageCode
    
    override func viewWillAppear(animated: Bool) {
        if (previousLanguageCode != languageCode){
            renewContent()
        }
        previousLanguageCode=languageCode
    }
    
    var videoOnDemandData:NSDictionary?
    
    func renewContent(){
        
        videoOnDemandData=dictionaryOfPath(base+"/"+version+"/categories/"+languageCode+"/VideoOnDemand?detailed=1", usingCache: false)
        
        videoCategoryTable.reloadData()
        videoCollection.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (videoOnDemandData?.objectForKey("category")?.objectForKey("subcategories")!.count!)!
    }
    
    var parentCategory:NSArray=[]
    var videos:Array<NSDictionary>=[]
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let subcats=videoOnDemandData!.objectForKey("category")!.objectForKey("subcategories")!
        
        let category:UITableViewCell=tableView.dequeueReusableCellWithIdentifier("category", forIndexPath: indexPath)
        category.textLabel?.text=subcats.objectAtIndex(indexPath.row).objectForKey("name") as? String
        category.textLabel?.textColor=UIColor.whiteColor()
        return category
    }
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        if (context.previouslyFocusedView != nil && (context.previouslyFocusedView?.isKindOfClass(UITableViewCell.self) == true) ){
        
            (context.previouslyFocusedView as! UITableViewCell).textLabel?.textColor=UIColor.whiteColor()
            
        }
        if (context.nextFocusedView != nil && (context.nextFocusedView?.isKindOfClass(UITableViewCell.self) == true) ){
            
            (context.nextFocusedView as! UITableViewCell).textLabel?.textColor=UIColor.blackColor()
            
        }
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        print("row:\(indexPath.row)")
        let subcat=videoOnDemandData!.objectForKey("category")!.objectForKey("subcategories")!.objectAtIndex(indexPath.row)
        
        let directory=base+"/"+version+"/categories/"+languageCode
        let downloadedJSON=dictionaryOfPath(directory+"/"+(subcat.objectForKey("key") as! String)+"?detailed=1")
        parentCategory=(downloadedJSON?.objectForKey("category")!.objectForKey("subcategories"))! as! NSArray
        self.videoCollection.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return parentCategory.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (parentCategory.objectAtIndex(section).objectForKey("media")?.count)!
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(270, 270)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("video", forIndexPath: indexPath)
        
        let retrievedVideo=parentCategory.objectAtIndex(indexPath.section).objectForKey("media")?.objectAtIndex(indexPath.row)
        
        let image=UIImageView(image: imageUsingCache((retrievedVideo!.objectForKey("images")!.objectForKey("sqr")?.objectForKey("lg"))! as! String))
        
        cell.contentView.addSubview(image)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
        
        /*
        This method provides the blue highlighting to the cells and sets variable selectedSlideShow:Bool.
        If selectedSlideShow==true (AKA the user is interacting with the slideshow) then the slide show will not roll to next slide.
        
        */
        
            if (context.previouslyFocusedView != nil && (context.previouslyFocusedView?.isKindOfClass(UICollectionViewCell.self) == true) ){
                
                //Clear shadow on any possible previous selection.
                
                context.previouslyFocusedView?.layer.shadowColor=UIColor.clearColor().CGColor
                context.previouslyFocusedView?.layer.shadowOpacity=0
                context.previouslyFocusedView?.layer.shadowRadius=0
            }
            
            if ((context.nextFocusedView != nil) && (context.nextFocusedView?.isKindOfClass(UICollectionViewCell.self) == true) ){
                
                //Create shadow on newly selected item.
                
                context.nextFocusedView?.layer.shadowColor=UIColor.blueColor().CGColor
                context.nextFocusedView?.layer.shadowOpacity=1
                context.nextFocusedView?.layer.shadowRadius=20
            }
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            let videosData=videos[indexPath.row].objectForKey("files")
            
            let videoData=videosData?.objectAtIndex((videosData?.count)!-1)
            
            let videoURLString=videoData?.objectForKey("progressiveDownloadURL") as! String
            
            
            let videoURL = NSURL(string: videoURLString)
            let player = AVPlayer(URL: videoURL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.presentViewController(playerViewController, animated: true) {
                playerViewController.player!.play()
        }
    }
}
