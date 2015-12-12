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

    subcategories = [
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
cvr (only on Dramas and DBR?)
prd (only on Dramas and DBR?)

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
        (self.tabBarController as! rootController).disableNavBarTimeOut=false
        self.videoCollection.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "subcategory")
        
        self.videoCollection.clipsToBounds=false
        //self.activityIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0)
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
    
    @IBOutlet weak var tableSideConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionSideConstraint: NSLayoutConstraint!
    func renewContent(){
        
        UIView.animateWithDuration(0.25, animations: {
            self.videoCategoryTable.alpha=0
            self.videoCollection.alpha=0
        })
        
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            let newTableConstraint =
            NSLayoutConstraint(item: tableSideConstraint.firstItem, attribute: .Right, relatedBy: tableSideConstraint.relation, toItem: tableSideConstraint.secondItem, attribute: .Right, multiplier: tableSideConstraint.multiplier, constant: -abs(tableSideConstraint.constant))
            self.view.removeConstraint(tableSideConstraint)
            self.view.addConstraint(newTableConstraint)
            tableSideConstraint=newTableConstraint
            
            
            let newCollectionConstraint =
            NSLayoutConstraint(item: collectionSideConstraint.firstItem, attribute: .Left, relatedBy: collectionSideConstraint.relation, toItem: collectionSideConstraint.secondItem, attribute: .Left, multiplier: collectionSideConstraint.multiplier, constant: -abs(collectionSideConstraint.constant))
            self.view.removeConstraint(collectionSideConstraint)
            self.view.addConstraint(newCollectionConstraint)
            collectionSideConstraint=newCollectionConstraint
            
            self.view.layoutIfNeeded()
        }
        else {
            let newTableConstraint =
            NSLayoutConstraint(item: tableSideConstraint.firstItem, attribute: .Left, relatedBy: tableSideConstraint.relation, toItem: tableSideConstraint.secondItem, attribute: .Left, multiplier: tableSideConstraint.multiplier, constant: abs(tableSideConstraint.constant))
            self.view.removeConstraint(tableSideConstraint)
            self.view.addConstraint(newTableConstraint)
            tableSideConstraint=newTableConstraint
            
            
            let newCollectionConstraint =
            NSLayoutConstraint(item: collectionSideConstraint.firstItem, attribute: .Right, relatedBy: collectionSideConstraint.relation, toItem: collectionSideConstraint.secondItem, attribute: .Right, multiplier: collectionSideConstraint.multiplier, constant: abs(collectionSideConstraint.constant))
            self.view.removeConstraint(collectionSideConstraint)
            self.view.addConstraint(newCollectionConstraint)
            collectionSideConstraint=newCollectionConstraint
            
            self.view.layoutIfNeeded()
        }
        
        //http://mediator.jw.org/v1/categories/E/Audio?detailed=1
        
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        fetchDataUsingCache(categoryDataURL, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                
                self.videoOnDemandData=dictionaryOfPath(categoryDataURL, usingCache: false)
                
                self.activityIndicator.stopAnimating()
                
                if (self.view.hidden==false){
                    
                    self.videoCategoryTable.reloadData()
                    self.videoCollection.performBatchUpdates({
                        self.chooseSubcategory(0)
                        }, completion: { (finished:Bool) in
                            if (finished){
                                UIView.animateWithDuration(0.25, animations: {
                                    self.videoCategoryTable.alpha=1
                                    self.videoCollection.alpha=1
                                })
                            }
                    })
                    /*
                    
                    
                    UIView.animateWithDuration(0.25, animations: {
                    self.videoCategoryTable.alpha=0
                    self.videoCollection.alpha=0
                    })
                    */
                    //self.videoCategoryTable.reloadData()
                    //self.videoCollection.reloadData()
                }
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
        
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            category.textLabel?.textAlignment=NSTextAlignment.Right
        }
        else {
            category.textLabel?.textAlignment=NSTextAlignment.Left
        }
        
        return category
    }
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if (tableView == self.videoCategoryTable && (context.nextFocusedView?.isKindOfClass(UITableViewCell.self) == true)){
            
            if (categoryTimer != nil){
                categoryTimer?.invalidate()
            }
            categoryTimer=NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("chooseSubcategoryTimer:"), userInfo: NSDictionary(object: Int((context.nextFocusedIndexPath?.row)!), forKey: "index"), repeats: false)
            //chooseSubcategory((context.nextFocusedIndexPath?.row)!)["index":context.nextFocusedIndexPath?.row]
        }

    }
    
    var categoryTimer:NSTimer?
    var previouslyLoaded=false
    
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
        chooseSubcategory((timer.userInfo?.objectForKey("index"))! as! Int)
    }
    
    func chooseSubcategory(index:Int){
        self.videoCollection.contentOffset=CGPoint(x: 0, y: 0)
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        let subcat=unfold(categoryDataURL+"|category|subcategories|\(index)")//videoOnDemandData["category"]["subcategories"][index]
        
        if (subcat != nil){
            
            let directory=base+"/"+version+"/categories/"+languageCode
            let subcategoryDirectory=directory+"/"+(subcat!.objectForKey("key") as! String)+"?detailed=1"
            
            UIView.animateWithDuration(0.15, animations: {
                self.videoCollection.alpha=0
            })
            
            fetchDataUsingCache(subcategoryDirectory, downloaded: {
                dispatch_async(dispatch_get_main_queue()) {
                    
                    
                    let downloadedJSON=dictionaryOfPath(subcategoryDirectory, usingCache: false)
                    
                    if (downloadedJSON?.objectForKey("category")!.objectForKey("media") != nil){//If no subcategories then just make itself the subcategory
                        self.parentCategory=Array(arrayLiteral: downloadedJSON?.objectForKey("category")! as! NSDictionary)
                        
                    }
                    else if (downloadedJSON?.objectForKey("category")!.objectForKey("subcategories") != nil){//for video on demand pretty much
                        self.parentCategory=(downloadedJSON?.objectForKey("category")!.objectForKey("subcategories"))! as! NSArray
                        self.subcategories=true
                    }
                    
                    
                    self.videoCollection.reloadData()
                    self.videoCollection.performBatchUpdates({
                        //self.videoCollection.reloadData()
                        }, completion: { (finished:Bool) in
                            if (finished){
                                UIView.animateWithDuration(0.15, animations: {
                                    self.videoCollection.alpha=1
                                })
                                
                            }
                        }
                    )
                    
                    
                }
            })

        }
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
            
            let textHeight:CGFloat=60
            
            let line:UIView=UIView(frame: CGRect(x: textspacing, y: textHeight/2, width: header!.frame.size.width-textspacing, height: 1))
            line.backgroundColor=UIColor.darkGrayColor()
            
            
            if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
                subCategoryLabel.textAlignment=NSTextAlignment.Right
                subCategoryLabel.frame=CGRect(x: (header?.frame.size.width)!-textspacing, y: 0, width: textspacing, height: 60)
                line.frame=CGRect(x: 0, y: textHeight/2, width: header!.frame.size.width-textspacing, height: 1)
            }
            header?.addSubview(subCategoryLabel)
            header?.addSubview(line)
            
        }
        if (kind == UICollectionElementKindSectionFooter) {
            header=collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "footer", forIndexPath: indexPath)
            
        }
        
        return header!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("video", forIndexPath: indexPath)
        cell.alpha=1
        cell.contentView.layoutSubviews()
        
        
        for subview in cell.contentView.subviews {
            if (subview.isKindOfClass(UIImageView.self)){
                
                (subview as! UIImageView).image=nil
            }
        }
        
        
        let retrievedVideo=parentCategory.objectAtIndex(indexPath.section).objectForKey("media")?.objectAtIndex(indexPath.row)
        
        let imageRatios=retrievedVideo!.objectForKey("images")!
        
        let priorityRatios=["pns","pss","wsr","lss","cvr","wss"].reverse()//wsr
        
        var usingRatio=""
        
        var imageURL:String?=""
        
        for ratio in imageRatios.allKeys {
            for priorityRatio in priorityRatios {
                if (ratio as? String == priorityRatio){
                    
                    if ((priorityRatios.indexOf(ratio as! String)) < (priorityRatios.indexOf(usingRatio)) || usingRatio == ""){
                        
                        if (unfold(imageRatios, instructions: ["\(ratio)","lg"]) != nil){
                            imageURL = unfold(imageRatios, instructions: ["\(ratio)","lg"]) as? String
                        }
                        else if (unfold(imageRatios, instructions: ["\(ratio)","md"]) != nil){
                            imageURL = unfold(imageRatios, instructions: ["\(ratio)","md"]) as? String
                        }
                        else if (unfold(imageRatios, instructions: ["\(ratio)","sm"]) != nil){
                            imageURL = unfold(imageRatios, instructions: ["\(ratio)","sm"]) as? String
                        }
                        if (imageURL != nil){
                            usingRatio=ratio as! String
                        }
                    }
                    
                }
            }
        }

        if (imageURL == ""){
            let sizes=unfold(imageRatios, instructions: [imageRatios.allKeys.first!]) as? NSDictionary
            imageURL=unfold(sizes, instructions: [sizes!.allKeys.last!]) as? String
        }
        
        let size=CGSize(width: 1,height: 1)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        UIColor.whiteColor().setFill()
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        let image=UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        for subview in cell.contentView.subviews {
            if (subview.isKindOfClass(UIImageView.self)){
                
                (subview as! UIImageView).image=image
                
                fetchDataUsingCache(imageURL!, downloaded: {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let image=imageUsingCache(imageURL!)
                        
                        var ratio=(image?.size.width)!/(image?.size.height)!
                        (subview as! UIImageView).frame=CGRect(x: (cell.frame.size.width-((cell.frame.size.height-60)*ratio))/2, y: 0, width: (cell.frame.size.height-60)*ratio, height: (cell.frame.size.height-60))
                        
                        if (image?.size.width>(image!.size.height)){
                            ratio=(image?.size.height)!/(image?.size.width)!
                            (subview as! UIImageView).frame=CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.width*ratio)
                        }
                        
                        (subview as! UIImageView).image=image
                        (subview as! UIImageView).frame=CGRect(x: (cell.frame.size.width-subview.frame.size.width)/2, y: (cell.frame.size.height-subview.frame.size.height)/2, width: subview.frame.size.width, height: subview.frame.size.height)
                        //(subview as! UIImageView).contentMode = .ScaleToFill
                        UIView.animateWithDuration(0.5, animations: {
                            subview.alpha=1
                        })
                        
                    }
                })
                
                subview.alpha=0
                subview.userInteractionEnabled = true
                (subview as! UIImageView).adjustsImageWhenAncestorFocused = true
                subview.layer.cornerRadius=5
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
                (subview as! UIActivityIndicatorView).startAnimating()
                subview.transform = CGAffineTransformMakeScale(2.0, 2.0)
            }
        }

        
        
        
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
                    //(subview as! UILabel).shadowColor=UIColor.blackColor()
                    subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y+5, width: subview.frame.size.width, height: subview.frame.size.height)
                }
            }
        }
        return true
    }
    
    var playerViewController:AVPlayerViewController?=nil
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        
        //let videosData=
        let videoURLString=(unfold(parentCategory, instructions: ["\(indexPath.section)","media","\(indexPath.row)","files","last","progressiveDownloadURL"]) as! String)
        
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(300, 300)
    }
}
