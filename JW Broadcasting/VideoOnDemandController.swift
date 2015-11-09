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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let category:String="VideoOnDemand"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //http://mediator.jw.org/v1/categories/ASL/VideoOnDemand?detailed=1
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
        
        let categoryDataURL=base+"/"+version+"/categories/"+languageCode+"/"+category+"?detailed=1"
        
        fetchDataUsingCache(categoryDataURL, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                
                self.videoOnDemandData=dictionaryOfPath(categoryDataURL, usingCache: false)
        
                self.videoOnDemandData=dictionaryOfPath(base+"/"+version+"/categories/"+languageCode+"/"+self.category+"?detailed=1", usingCache: false)
        
                let subcat=self.videoOnDemandData!.objectForKey("category")!.objectForKey("subcategories")!.firstObject
                let directory=base+"/"+version+"/categories/"+languageCode
                let downloadedJSON=dictionaryOfPath(directory+"/"+(subcat!!.objectForKey("key") as! String)+"?detailed=1", usingCache: false)
        
                self.parentCategory=(downloadedJSON?.objectForKey("category")!.objectForKey("subcategories"))! as! NSArray
                
                self.activityIndicator.stopAnimating()
                
                if (self.view.hidden==false){
                    self.videoCategoryTable.reloadData()
                    self.videoCollection.reloadData()
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (videoOnDemandData != nil){
            return (videoOnDemandData?.objectForKey("category")?.objectForKey("subcategories")!.count!)!
        }
        return 0
    }
    
    var parentCategory:NSArray=[]
    var videos:Array<NSDictionary>=[]
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let subcats=videoOnDemandData!.objectForKey("category")!.objectForKey("subcategories")!
        
        let category:UITableViewCell=tableView.dequeueReusableCellWithIdentifier("category", forIndexPath: indexPath)
        category.textLabel?.text=subcats.objectAtIndex(indexPath.row).objectForKey("name") as? String
        //category.textLabel?.textColor=UIColor.whiteColor()
        
        return category
    }
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        /*
        if (context.previouslyFocusedView != nil && (context.previouslyFocusedView?.isKindOfClass(UITableViewCell.self) == true) ){
        
            (context.previouslyFocusedView as! UITableViewCell).textLabel?.textColor=UIColor.whiteColor()
            
        }
        if (context.nextFocusedView != nil && (context.nextFocusedView?.isKindOfClass(UITableViewCell.self) == true) ){
            
            (context.nextFocusedView as! UITableViewCell).textLabel?.textColor=UIColor.blackColor()
            
        }*/
        print("attempt focus")
        if (tableView == self.videoCategoryTable){
            print("it is focusing")
                if ((context.nextFocusedView?.isKindOfClass(UITableViewCell.self)) == true){
                    let subcat=videoOnDemandData!.objectForKey("category")!.objectForKey("subcategories")!.objectAtIndex(context.nextFocusedIndexPath!.row)
                    
                let directory=base+"/"+version+"/categories/"+languageCode
                let downloadedJSON=dictionaryOfPath(directory+"/"+(subcat.objectForKey("key") as! String)+"?detailed=1", usingCache: false)
                parentCategory=(downloadedJSON?.objectForKey("category")!.objectForKey("subcategories"))! as! NSArray
                self.videoCollection.reloadData()
            }
        }
        
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        let subcat=videoOnDemandData!.objectForKey("category")!.objectForKey("subcategories")!.objectAtIndex(indexPath.row)
        
        let directory=base+"/"+version+"/categories/"+languageCode
        let downloadedJSON=dictionaryOfPath(directory+"/"+(subcat.objectForKey("key") as! String)+"?detailed=1", usingCache: false)
        parentCategory=(downloadedJSON?.objectForKey("category")!.objectForKey("subcategories"))! as! NSArray
        self.videoCollection.reloadData()
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(350, 300)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("video", forIndexPath: indexPath)
        let retrievedVideo=parentCategory.objectAtIndex(indexPath.section).objectForKey("media")?.objectAtIndex(indexPath.row)
        
        let imageURL=((retrievedVideo!.objectForKey("images")!.objectForKey("wsr")?.objectForKey("sm"))! as! String)
        
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
                    
                    
                    let titleLabel=(subview as! UILabel)
                    titleLabel.text=retrievedVideo!.objectForKey("title") as? String
                    titleLabel.layer.shadowColor=UIColor.blackColor().CGColor
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
        /*
        UIView.animateWithDuration(0.5, animations: {
        
            if (context.previouslyFocusedView != nil && (context.previouslyFocusedView?.isKindOfClass(UICollectionViewCell.self) == true) ){
                
                //Clear shadow on any possible previous selection.
                
                context.previouslyFocusedView?.layer.shadowColor=UIColor.clearColor().CGColor
                context.previouslyFocusedView?.layer.shadowOpacity=0
                context.previouslyFocusedView?.layer.shadowRadius=0
                context.previouslyFocusedView?.layer.shadowOffset=CGSize(width: 0, height: 0)
                context.previouslyFocusedView?.transform=CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)
                //context.previouslyFocusedView?.frame=CGRect(x: (context.previouslyFocusedView?.frame.origin.x)!, y: (context.previouslyFocusedView?.frame.origin.y)!+40, width: (context.previouslyFocusedView?.frame.size.width)!, height: (context.previouslyFocusedView?.frame.size.height)!)
            }
            
            if ((context.nextFocusedView != nil) && (context.nextFocusedView?.isKindOfClass(UICollectionViewCell.self) == true) ){
                
                //Create shadow on newly selected item.
                
                context.nextFocusedView?.layer.shadowColor=UIColor.blackColor().CGColor
                context.nextFocusedView?.layer.shadowOpacity=0.5
                context.nextFocusedView?.layer.shadowOffset=CGSize(width: 0, height: 20)
                context.nextFocusedView?.transform=CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1)
                context.nextFocusedView?.layer.shadowRadius=15
                //context.nextFocusedView?.frame=CGRect(x: (context.nextFocusedView?.frame.origin.x)!, y: (context.nextFocusedView?.frame.origin.y)!-40, width: (context.nextFocusedView?.frame.size.width)!, height: (context.nextFocusedView?.frame.size.height)!)
            }
            })*/
        return true
    }
    
    var playerViewController:AVPlayerViewController?=nil
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //let videosData=
        let subcat=parentCategory.objectAtIndex(indexPath.section)
        
        //videos[indexPath.row].objectForKey("files")
            let media=subcat.objectForKey("media")
            //print(media?.count)
            let videosection=media!.objectAtIndex(indexPath.row)
            //print(videosection)
            let files=videosection.objectForKey("files")
            let videoData=files!.objectAtIndex(3)
        //.objectForKey("files")!
            
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
    
}
