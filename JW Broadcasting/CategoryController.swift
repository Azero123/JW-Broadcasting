//
//  VideoOnDemandController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/25/15.
//  Copyright © 2015 xquared. All rights reserved.
//

/*

This code is the super class for VideoOnDemandController and AudioController.
This handles the fetching of files and displaying of content for both VideoOnDemandController and AudioController.





1. -- Where the data is coming from?

After examining the JS code for tv.jw.org I have come to the understanding that all the content for Categories is fetched from URLs of this format

%BaseDomainKey% = "mediator.jw.org"
%VersionKey% = "v1"
%LanguageKey% = String (used for file name of category)

"http:// %BaseDomainKey% / %VersionKey% /categories/ %LanguageKey% / %CategoryKey% ?detailed=1"

This request drops the JSON formatted data for an indivigual category.
Some known category keys:

VideoOnDemand
Audio
LatestVideos



2. -- What are we looking for in the data?

The contents of $RESPONSE contains a %category% pattern:

%category% = {

    description = String (Displayable String for describing the category)
    key = String (%LanguageKey% For the current file)
    name = String (Displayable string for category)
    type = "container" (Unknown)

    tags = [
    "RokuCategorySelectionPosterScreen" (Unkown string for Roku???)
    ]
    media = [
        {
        files = [
        {
        progressiveDownloadURL = String (String of URL for mp4 file)
        }
        ...
        ] (files related to the video or audio file the later down the list the higher the resolution)
    }
    ...
    ]
    images = {
        %ImageRatio% {
            %ImageSize% = String (URL of images)
            ...
        }
        ...
    } (dictionary containing all available image urls)

    subcategories [
    %category%,
    %category%,
    ...
    ]

}

- keys for images

%ImageRatio% is a String correlating to an aspect ratio 
Known keys and their ratios:
pnr (3:1)
psr (21:30)
pss (21:30)
rph (204:237
rps
wsr
wss

%ImageSize% is a String referencing a general size of the image... however not all ratios have all the same sizes. Some known size keys are:
xs
sm
md
lg

category.media[i].files[x].p

- choosing image

So now we need to look for a consistant ratio and size key pair that fits our needs.

Ideally I was looking for something either square or with a heigher width than height ratio that was around 2-4 hundred pixels in size to not take a lot of bandwidth and loading time and not stretch the image.


-- How to load the content

So the content



*/

import UIKit
import AVKit

class CategoryController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var videoCategoryTable: UITableView!
    @IBOutlet weak var videoCollection: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var category:String="VideoOnDemand"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.videoCollection.clipsToBounds=false
        self.activityIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0)
        activityIndicator.hidesWhenStopped=true
        activityIndicator.startAnimating()
        
        renewContent()
        
    }
    
    
    var previousLanguageCode=languageCode
    
    override func viewWillAppear(animated: Bool) {
        if (previousLanguageCode != languageCode){
            renewContent()
        }
        previousLanguageCode=languageCode
        
        self.view.hidden=false
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.view.hidden=true
    }
    
    var videoOnDemandData:NSDictionary?
    
    func renewContent(){
        
        //http://mediator.jw.org/v1/categories/E/Audio?detailed=1
        
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        fetchDataUsingCache(categoryDataURL, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                
                self.videoOnDemandData=dictionaryOfPath(categoryDataURL, usingCache: false)
                
                self.activityIndicator.stopAnimating()
                
                if (self.view.hidden==false){
                    self.videoCategoryTable.reloadData()
                    self.videoCollection.reloadData()
                }
                self.chooseSubcategory(0)
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (videoOnDemandData != nil){//LEAVE ALONE TO NOT HURT VOD
            if (videoOnDemandData?.objectForKey("category")!.objectForKey("subcategories") != nil){
                return (videoOnDemandData?.objectForKey("category")?.objectForKey("subcategories")!.count!)!
            }
            else if (videoOnDemandData?.objectForKey("category")!.objectForKey("media") != nil){
                return (videoOnDemandData?.objectForKey("category")?.objectForKey("media")!.count!)!
            }
        }
        
        return 0
    }
    
    var parentCategory:NSArray=[]
    var videos:Array<NSDictionary>=[]
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let subcats=videoOnDemandData!.objectForKey("category")!.objectForKey("subcategories")!
        
        let category:UITableViewCell=tableView.dequeueReusableCellWithIdentifier("category", forIndexPath: indexPath)
        category.textLabel?.text=subcats.objectAtIndex(indexPath.row).objectForKey("name") as? String
        
        return category
    }
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if (tableView == self.videoCategoryTable && (context.nextFocusedView?.isKindOfClass(UITableViewCell.self) == true)){
            
            if (categoryTimer != nil){
                categoryTimer?.invalidate()
            }
            print("\(context.nextFocusedIndexPath?.row)")
            categoryTimer=NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("chooseSubcategoryTimer:"), userInfo: NSDictionary(object: Int((context.nextFocusedIndexPath?.row)!), forKey: "index"), repeats: false)
            //chooseSubcategory((context.nextFocusedIndexPath?.row)!)["index":context.nextFocusedIndexPath?.row]
        }

    }
    
    var categoryTimer:NSTimer?
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        if (categoryTimer != nil){
            categoryTimer?.invalidate()
        }
        //categoryTimer?.fire()
        //categoryTimer?.fire()
        chooseSubcategory((indexPath.row))
    }
    
    var subcategories=false
    
    func chooseSubcategoryTimer(timer:NSTimer){
        print("choosing subcategory \(timer.userInfo)")
        chooseSubcategory((timer.userInfo?.objectForKey("index"))! as! Int)
    }
    
    func chooseSubcategory(index:Int){
        print("choosing subcategory \(index)")
        
        
        let subcat=videoOnDemandData!.objectForKey("category")!.objectForKey("subcategories")!.objectAtIndex(index)
        
        let directory=base+"/"+version+"/categories/"+languageCode
        let subcategoryDirectory=directory+"/"+(subcat.objectForKey("key") as! String)+"?detailed=1"
        print("subcategory directory:\(subcategoryDirectory)")
        
        
        fetchDataUsingCache(subcategoryDirectory, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                print("new category")
                let downloadedJSON=dictionaryOfPath(subcategoryDirectory, usingCache: false)
                
                if (downloadedJSON?.objectForKey("category")!.objectForKey("media") != nil){//If no subcategories then just make itself the subcategory
                    self.parentCategory=Array(arrayLiteral: downloadedJSON?.objectForKey("category")! as! NSDictionary)
                    
                }
                else if (downloadedJSON?.objectForKey("category")!.objectForKey("subcategories") != nil){//for video on demand pretty much
                    self.parentCategory=(downloadedJSON?.objectForKey("category")!.objectForKey("subcategories"))! as! NSArray
                    self.subcategories=true
                }
                self.videoCollection.reloadData()
            }
        })
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return parentCategory.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (parentCategory.objectAtIndex(section).objectForKey("media")?.count)!
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var header:UICollectionReusableView?=nil
        
        if (kind == UICollectionElementKindSectionHeader){
            header=collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "subcategory", forIndexPath: indexPath)
            
            for subview in header!.subviews {
                subview.removeFromSuperview()
            }
            
            var textspacing:CGFloat=300
            
            let subCategoryLabel=UILabel(frame: CGRect(x: 0, y: 0, width: textspacing, height: 60))
            subCategoryLabel.font=UIFont.systemFontOfSize(30)
            
            subCategoryLabel.text=parentCategory.objectAtIndex(indexPath.section).objectForKey("name") as? String
            textspacing=subCategoryLabel.intrinsicContentSize().width+25
            subCategoryLabel.frame=CGRect(x: 0, y: 0, width: textspacing, height: 60)
            header?.addSubview(subCategoryLabel)
            
            let textHeight:CGFloat=60
            
            let line:UIView=UIView(frame: CGRect(x: textspacing, y: textHeight/2, width: header!.frame.size.width-textspacing, height: 1))
            line.backgroundColor=UIColor.darkGrayColor()
            header?.addSubview(line)
            
        }
        if (kind == UICollectionElementKindSectionFooter) {
            header=collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "footer", forIndexPath: indexPath)
            
        }
        
        return header!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("video", forIndexPath: indexPath)
        let retrievedVideo=parentCategory.objectAtIndex(indexPath.section).objectForKey("media")?.objectAtIndex(indexPath.row)
        
        let imageRatios=retrievedVideo!.objectForKey("images")!
        
        let priorityRatios=["wsr","sqr"]//wsr
        
        var imageURL:String!=""
        
        for ratio in imageRatios.allKeys {
            for priorityRatio in priorityRatios.reverse() {
                if (ratio as? String == priorityRatio){
                    if ((imageRatios.objectForKey(ratio)?.objectForKey("lg")) != nil){
                        imageURL=((imageRatios.objectForKey(ratio)?.objectForKey("lg"))! as! String)
                    }
                }
            }
        }
        
        
        fetchDataUsingCache(imageURL, downloaded: {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let image=imageUsingCache(imageURL)
                
                for subview in cell.contentView.subviews {
                    if (subview.isKindOfClass(UIImageView.self)){
                        subview.alpha=0
                        (subview as! UIImageView).image=image
                        subview.userInteractionEnabled = true
                        (subview as! UIImageView).adjustsImageWhenAncestorFocused = true
                        subview.layer.cornerRadius=5
                        UIView.animateWithDuration(0.5, animations: {
                            subview.alpha=1
                        })
                    }
                    if (subview.isKindOfClass(UILabel.self)){
                        
                        /*

                        Code for removing the repetitive JW Broadcasting - before all the names of all the monthly broadcasts.
                        */
                        
                        var title=(retrievedVideo!.objectForKey("title") as? NSString)!
                        
                        let replacementStrings=["JW Broadcasting —","JW Broadcasting—"]
                        
                        for replacement in replacementStrings {
                        
                            if (title.containsString(replacement)){
                                
                                title=title.stringByReplacingOccurrencesOfString(replacement, withString: "")
                                title=title.stringByAppendingString(" Broadcast")
                                /* replace " Broadcast" with a key from:
                                base+"/"+version+"/languages/"+languageCode+"/web"
                                so that this works with foreign languages*/
                            }
                            
                        }
                        
                        let titleLabel=(subview as! UILabel)
                        titleLabel.text=title as String
                        titleLabel.layer.shadowColor=UIColor.darkGrayColor().CGColor
                        titleLabel.layer.shadowRadius=5
                        titleLabel.numberOfLines=3
                        
                    }
                    if (subview.isKindOfClass(UIActivityIndicatorView.self)){
                        subview.transform = CGAffineTransformMakeScale(2.0, 2.0)
                    }
                }
                
                
            }
        })
        
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
        
        /*
        This method provides the blue highlighting to the cells and sets variable selectedSlideShow:Bool.
        If selectedSlideShow==true (AKA the user is interacting with the slideshow) then the slide show will not roll to next slide.
        
        */
        
        if (context.previouslyFocusedView?.superview == self.videoCollection){
            
            for subview in (context.previouslyFocusedView?.subviews.first!.subviews)! {
                if (subview.isKindOfClass(UILabel.self)){
                    (subview as! UILabel).textColor=UIColor.darkGrayColor()
                    subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y-5, width: subview.frame.size.width, height: subview.frame.size.height)
                }
            }
        }
        if (context.nextFocusedView?.superview == self.videoCollection){
            context.nextFocusedView?.subviews.first?.alpha=1
            
            for subview in (context.nextFocusedView?.subviews.first!.subviews)! {
                if (subview.isKindOfClass(UILabel.self)){
                    (subview as! UILabel).textColor=UIColor.whiteColor()
                    (subview as! UILabel).shadowColor=UIColor.blackColor()
                    subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y+5, width: subview.frame.size.width, height: subview.frame.size.height)
                }
            }
        }
        return true
    }
    
    var playerViewController:AVPlayerViewController?=nil
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //let videosData=
        let subcat=parentCategory.objectAtIndex(indexPath.section)
        let media=subcat.objectForKey("media")
        let videosection=media!.objectAtIndex(indexPath.row)
        let files=videosection.objectForKey("files")
        let file=files!.objectAtIndex((files?.count)!-1)
        let videoData=file
        
        let videoURLString=videoData.objectForKey("progressiveDownloadURL") as! String
        
        let videoURL = NSURL(string: videoURLString)
        let player = AVPlayer(URL: videoURL!)
        playerViewController = AVPlayerViewController()
        playerViewController!.player = player
        self.presentViewController(playerViewController!, animated: true) {
            self.playerViewController!.player!.play()
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        //player.currentItem!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    func playerItemDidReachEnd(notification:NSNotification){
        if (playerViewController != nil){
            //playerViewController?.player!.currentItem?.removeObserver(self, forKeyPath: "status")
            playerViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
