//
//  VideoOnDemandController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/25/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit
import AVKit

class categoryController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var videoCategoryTable: UITableView!
    @IBOutlet weak var videoCollection: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var category:String="VideoOnDemand"
    
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
        
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        fetchDataUsingCache(categoryDataURL, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                
                self.videoOnDemandData=dictionaryOfPath(categoryDataURL, usingCache: false)
                
                self.videoOnDemandData=dictionaryOfPath(categoryDataURL, usingCache: false)
                
                let subcat=self.videoOnDemandData!.objectForKey("category")!.objectForKey("subcategories")!.firstObject
                let downloadedJSON=dictionaryOfPath(categoriesDirectory+"/"+(subcat!!.objectForKey("key") as! String)+"?detailed=1", usingCache: false)
                
                //self.parentCategory=(downloadedJSON?.objectForKey("category")!.objectForKey("subcategories"))! as! NSArray
                
                self.activityIndicator.stopAnimating()
                
                if (self.view.hidden==false){
                    self.videoCategoryTable.reloadData()
                    self.videoCollection.reloadData()
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
        
        return category
    }
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if (tableView == self.videoCategoryTable && (context.nextFocusedView?.isKindOfClass(UITableViewCell.self) == true)){
            chooseSubcategory((context.nextFocusedIndexPath?.row)!)
        }

    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        
        chooseSubcategory((indexPath.row))
    }
    
    var subcategories=false
    
    func chooseSubcategory(index:Int){
        
        
        let subcat=videoOnDemandData!.objectForKey("category")!.objectForKey("subcategories")!.objectAtIndex(index)
        
        let directory=base+"/"+version+"/categories/"+languageCode
        let subcategoryDirectory=directory+"/"+(subcat.objectForKey("key") as! String)+"?detailed=1"
        
        
        
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
                    if ((imageRatios.objectForKey(ratio)?.objectForKey("sm")) != nil){
                        imageURL=((imageRatios.objectForKey(ratio)?.objectForKey("sm"))! as! String)
                    }
                }
            }
        }
        
        
        print(imageURL)
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
