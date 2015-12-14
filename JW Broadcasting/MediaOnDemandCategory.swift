//
//  MediaOnDemandCategory.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/4/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit
import AVKit

var streamingCell=true

class MediaOnDemandCategory: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

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
    var _categoryIndex=0
    var categoryIndex:Int {
        set (newValue){
            _categoryIndex=newValue
        }
        get {
            return _categoryIndex
        }
    }
/*
let category="VideoOnDemand"
let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
categoryToGoTo=unfold(categoryDataURL+"|category|subcategories|\(indexPath.row)|key") as! String*/
    //pnr lg 1140,380
    //wsr lg 1280,719
    @IBOutlet weak var TopImage: UIImageView!
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewDescription: UITextView!
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var backgroundVisualEffect: UIVisualEffectView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //backgroundImage.alpha=0.5
        //backgroundVisualEffect.alpha=0.85
        
        let hMaskLayer:CAGradientLayer = CAGradientLayer()
        // defines the color of the background shadow effect
        let darkColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.75).CGColor
        let lightColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0).CGColor
        
        // define a vertical gradient (up/bottom edges)
        let colorsForDarkness = [darkColor,lightColor]
        
        // without specifying startPoint and endPoint, we get a vertical gradient
        hMaskLayer.opacity = 1.0
        hMaskLayer.colors = colorsForDarkness
        
        hMaskLayer.startPoint = CGPointMake(0.2, 0.5)
        hMaskLayer.endPoint = CGPointMake(1.0, 0.5)
        
        hMaskLayer.bounds = self.TopImage.bounds
        hMaskLayer.anchorPoint = CGPointZero
        
        self.TopImage.layer.insertSublayer(hMaskLayer, atIndex: 0)
        
        
        backgroundVisualEffect.alpha=0.99
        
        
        
        
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
        
        //self.TopImage.layer.mask=vMaskLayer
        
        renewContent()
        
        // Do any additional setup after loading the view.
    }
    
    func renewContent(){
        
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        fetchDataUsingCache(categoryDataURL, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                self.categoryTitle.text=unfold("\(categoryDataURL)|category|name") as? String
                if (textDirection == .RightToLeft){//RTL alignment
                    self.categoryTitle.textAlignment = .Right
                }
                else {
                    self.categoryTitle.textAlignment = .Left
                }
                if (textDirection == .RightToLeft){//RTL alignment
                    self.TopImage.transform = CGAffineTransformMakeScale(-1.0, 1.0)
                }
                else {
                    self.TopImage.transform = CGAffineTransformMakeScale(1.0, 1.0)
                }
                
            let imageURL=unfold("\(categoryDataURL)|category|images|pnr|lg") as? String
                if (imageURL != nil){
                    fetchDataUsingCache(imageURL!, downloaded: {
                        dispatch_async(dispatch_get_main_queue()) {
                            print("image updated")
                            
                            /*UIView.animateWithDuration(2.0, animations: {
                                self.TopImage.image=imageUsingCache(imageURL!)
                            })*/
                            UIView.transitionWithView(self.TopImage, duration: 0.25, options: .TransitionCrossDissolve, animations: {
                                self.TopImage.image=imageUsingCache(imageURL!)
                                }, completion: nil)
                            
                            self.previewImageView.userInteractionEnabled=true
                            self.previewImageView.adjustsImageWhenAncestorFocused = true
                        }
                    })
                }
                for var i=0;i<unfold("\(categoryDataURL)|category|subcategories|count") as! Int ; i++ {
                    
                    let layout=CollectionViewHorizontalFlowLayout()
                    layout.spacingPercentile=1.075
                    //layout.spacingPercentile=1.3
                    
                    var collectionView=MODSubcategoryCollectionView(frame: CGRect(x: CGFloat(0), y:CGFloat(475*(i))+620, width: self.view.frame.size.width, height: CGFloat(425)), collectionViewLayout: layout)
                    collectionView.categoryName=unfold("\(categoryDataURL)|category|subcategories|\(i)|name") as! String
                    collectionView.clipsToBounds=false
                    collectionView.contentInset=UIEdgeInsetsMake(0, 60, 0, 60)
                    collectionView.prepare()
                    
                    
                    if (self.subcategoryCollectionViews.count>i){
                        collectionView=self.subcategoryCollectionViews[i]
                    }
                    else {
                        
                        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "mediaElement")
                        collectionView.dataSource=self
                        collectionView.delegate=self
                        self.subcategoryCollectionViews.insert(collectionView, atIndex: i)
                        
                        if (i==0){
                            //continue
                        }
                        self.scrollView.addSubview(collectionView)
                        self.scrollView.scrollEnabled=true
                        self.scrollView.contentSize=CGSizeMake(self.scrollView.frame.size.width, collectionView.frame.origin.y+collectionView.frame.size.height+35)
                        
                    }
                    collectionView.reloadData()
                    
                    if (textDirection == .RightToLeft){//RTL alignment
                        collectionView.contentOffset=collectionView.centerPointFor(CGPointMake(collectionView.contentSize.width-collectionView.frame.size.width+collectionView.contentInset.right, 0))
                    }
                }
                
            }
            
        })
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    var subcategoryCollectionViews:[MODSubcategoryCollectionView]=[]
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        let subcategories=unfold("\(categoryDataURL)|category|subcategories|\(subcategoryCollectionViews.indexOf(collectionView as! MODSubcategoryCollectionView)!)|media|count") as? Int
        if (subcategories != nil){
            
            if (streamingCell){
                if (subcategoryCollectionViews.indexOf(collectionView as! MODSubcategoryCollectionView)! == 0){
                    return subcategories!+1
                }
            }
            return subcategories!
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("mediaElement", forIndexPath: indexPath)
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        cell.alpha=1
        cell.clipsToBounds=false
        cell.contentView.layoutSubviews()
        
        
        var indexPathRow=indexPath.row
        if (streamingCell){
            if (subcategoryCollectionViews.indexOf(collectionView as! MODSubcategoryCollectionView)! == 0){
                indexPathRow--
                if (indexPath.row==0){
                    
                    let streamview=StreamView(frame: cell.bounds)
                    streamview.streamID=categoryIndex
                    let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=0"
                    let streamData=unfold(streamingScheduleURL)
                    let imageURL:String?=unfold(streamData, instructions: ["category","subcategories",streamview.streamID,"media",0,"images",["lsr","wss","cvr","lss","wsr","pss","pns",""],["lg","md","sm","xs",""]]) as? String
                    if (imageURL != nil){
                        fetchDataUsingCache(imageURL!, downloaded: {
                            
                            dispatch_async(dispatch_get_main_queue()) {
                            
                                let image=imageUsingCache(imageURL!)
                                //streamview.image=imageUsingCache(imageURL!)
                                var ratio=(image?.size.width)!/(image?.size.height)!
                                streamview.frame=CGRect(x: (cell.frame.size.width-((cell.frame.size.height-60)*ratio))/2, y: 0, width: (cell.frame.size.height-60)*ratio, height: (cell.frame.size.height-60))
                                
                                if (image?.size.width>(image!.size.height)){
                                    ratio=(image?.size.height)!/(image?.size.width)!
                                    streamview.frame=CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.width*ratio)
                                }
                                
                                streamview.frame=CGRect(x: (cell.frame.size.width-streamview.frame.size.width)/2, y: (cell.frame.size.height-streamview.frame.size.height)/2, width: streamview.frame.size.width, height: streamview.frame.size.height)
                            }
                        })
                    }
                    
                    
                    cell.contentView.addSubview(streamview)
                }
            }
        }
        
        //lblNowPlaying
        
        
        
        let label=marqueeLabel(frame: CGRect(x: 0, y: cell.bounds.size.height/2+10, width: cell.bounds.size.width, height: cell.bounds.size.height))
        
        label.fadeLength=15
        label.fadePadding = 30
        label.fadePaddingWhenFull = -5
        label.textSideOffset=15
        
        label.textColor=UIColor.darkGrayColor()
        label.textAlignment = .Center
        label.font=UIFont.systemFontOfSize(29)
        let retrievedVideo=unfold("\(categoryDataURL)|category|subcategories|\(subcategoryCollectionViews.indexOf(collectionView as! MODSubcategoryCollectionView)!)|media|\(indexPathRow)")

        /*
        
        Code for removing the repetitive JW Broadcasting - before all the names of all the monthly broadcasts.
        */
        var title:String?=nil
        if (retrievedVideo != nil){
            title=(retrievedVideo!.objectForKey("title") as? String)
        }
        if (title != nil){
            let replacementStrings=["JW Broadcasting —","JW Broadcasting—","JW Broadcasting​ —","JW Broadcasting​—"]
            for replacement in replacementStrings {
                
                if (title!.containsString(replacement)){
                    
                    title=title!.stringByReplacingOccurrencesOfString(replacement, withString: "")
                    title=title!.stringByAppendingString(" Broadcast")
                    /* replace " Broadcast" with a key from:
                    base+"/"+version+"/languages/"+languageCode+"/web"
                    so that this works with foreign languages*/
                }
                
            }
            
            label.text=title
            label.layer.shadowColor=UIColor.darkGrayColor().CGColor
            label.layer.shadowRadius=5
            label.numberOfLines=3
        }
        if (subcategoryCollectionViews.indexOf(collectionView as! MODSubcategoryCollectionView)! == 0 && indexPath.row==0){
            
            label.text=unfold("\(base)/\(version)/translations/\(languageCode)|translations|\(languageCode)|lblNowPlaying") as? String
        }
        
        if (retrievedVideo == nil){
            //return cell
        }
        
        var imageURL:String?=nil
        if (retrievedVideo != nil){
            imageURL=unfold(retrievedVideo, instructions: ["images",["lsr","wss","cvr","lss","wsr","pss","pns",""],["lg","md","sm","xs",""]]) as? String
        }
        
        
        let size=CGSize(width: 1,height: 1)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        UIColor.whiteColor().setFill()
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        //var image=UIGraphicsGetImageFromCurrentImageContext()
        //UIGraphicsEndImageContext()
    
        
        let imageView=UIImageView(frame: cell.bounds)
        cell.contentView.addSubview(imageView)
        
        //imageView.image=image
        
        if (imageURL != nil){
            fetchDataUsingCache(imageURL!, downloaded: {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    print("image")
                    
                    let image=imageUsingCache(imageURL!)
                    
                    var ratio=(image?.size.width)!/(image?.size.height)!
                    imageView.frame=CGRect(x: (cell.frame.size.width-((cell.frame.size.height-60)*ratio))/2, y: 0, width: (cell.frame.size.height-60)*ratio, height: (cell.frame.size.height-60))
                    
                    if (image?.size.width>(image!.size.height)){
                        ratio=(image?.size.height)!/(image?.size.width)!
                        imageView.frame=CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.width*ratio)
                    }
                    
                    imageView.image=image
                    imageView.frame=CGRect(x: (cell.frame.size.width-imageView.frame.size.width)/2, y: (cell.frame.size.height-imageView.frame.size.height)/2, width: imageView.frame.size.width, height: imageView.frame.size.height)
                    UIView.animateWithDuration(0.5, animations: {
                        imageView.alpha=1
                    })
                    
                }
            })
        }
        
        imageView.alpha=0
        imageView.userInteractionEnabled = true
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.layer.cornerRadius=5
        
        
        cell.contentView.addSubview(label)
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        return cell

    }

    
    
    func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
        
        /*
        This method provides the blue highlighting to the cells and sets variable selectedSlideShow:Bool.
        If selectedSlideShow==true (AKA the user is interacting with the slideshow) then the slide show will not roll to next slide.
        
        */
        if (context.previouslyFocusedView?.superview?.isKindOfClass(MODSubcategoryCollectionView.self) == true && subcategoryCollectionViews.contains(context.previouslyFocusedView?.superview as! MODSubcategoryCollectionView) && context.previouslyFocusedIndexPath != nil){
            
            (context.previouslyFocusedView?.superview as! MODSubcategoryCollectionView).cellShouldLoseFocus(context.previouslyFocusedView!, indexPath: context.previouslyFocusedIndexPath!)
            
        }
        if (context.nextFocusedView?.superview?.isKindOfClass(MODSubcategoryCollectionView.self) == true && subcategoryCollectionViews.contains(context.nextFocusedView?.superview as! MODSubcategoryCollectionView) && context.nextFocusedIndexPath != nil){
            
            (context.nextFocusedView?.superview as! MODSubcategoryCollectionView).cellShouldFocus(context.nextFocusedView!, indexPath: context.nextFocusedIndexPath!)
            
            self.scrollView.scrollRectToVisible((context.nextFocusedView?.superview?.frame)!, animated: true)
        }
        
        
        
        return true
    }
    
    var playerViewController:AVPlayerViewController?=nil
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        /*
        let category="VideoOnDemand"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        categoryToGoTo=unfold(categoryDataURL+"|category|subcategories|\(indexPath.row)|key") as! String
        print("category to go to \(categoryToGoTo)")*/
        var indexPathRow=indexPath.row
        if (subcategoryCollectionViews.indexOf(collectionView as! MODSubcategoryCollectionView)! == 0){
            indexPathRow--
            if (indexPath.row==0){
                
                self.performSegueWithIdentifier("presentStreaming", sender: self)
                
            }
        }
        
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        let videoURLString=unfold("\(categoryDataURL)|category|subcategories|\(subcategoryCollectionViews.indexOf(collectionView as! MODSubcategoryCollectionView)!)|media|\(indexPathRow)|files|last|progressiveDownloadURL") as? String
        if (videoURLString != nil){
            let videoURL = NSURL(string: videoURLString!)
            let player = AVPlayer(URL: videoURL!)
            playerViewController = AVPlayerViewController()
            playerViewController!.player = player
            self.presentViewController(playerViewController!, animated: true) {
                self.playerViewController!.player!.play()
            }
        }
        return true
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: 560/1.05, height: 360/1.05)//588,378
    }
        
        
        func playerItemDidReachEnd(notification:NSNotification){
            if (playerViewController != nil){
                //playerViewController?.player!.currentItem?.removeObserver(self, forKeyPath: "status")
                playerViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        /*
        This method is used to pass data to other ViewControllers that are being presented. Currently the only data needed to be sent is the channel ID selected in ChannelSelector. This passes the information on what channel to watch.
        */
        
        if (segue.destinationViewController.isKindOfClass(StreamingViewController.self)){
            (segue.destinationViewController as! StreamingViewController).streamID=categoryIndex
        }
    }

}
