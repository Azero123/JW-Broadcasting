//
//  MediaOnDemandCategory.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/4/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit
import AVKit

class MediaOnDemandCategory: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

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
    @IBOutlet weak var featuredVideoA: UIImageView!
    @IBOutlet weak var featuredVideoB: UIImageView!
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
                self.categoryTitle.text=unfold("\(categoryDataURL)|category|name") as? String
            let imageURL=unfold("\(categoryDataURL)|category|images|pnr|lg") as? String
                if (imageURL != nil){
                    fetchDataUsingCache(imageURL!, downloaded: {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.TopImage.image=imageUsingCache(imageURL!)
                            self.previewImageView.userInteractionEnabled=true
                            self.previewImageView.adjustsImageWhenAncestorFocused = true
                        }
                    })
                }
            self.mediaElements.reloadData()
            }
            
            
            
            for var i=0;i<unfold("\(categoryDataURL)|category|subcategories|count") as! Int ; i++ {
                
                let layout=CollectionViewHorizontalFlowLayout()
                layout.spacingPercentile=1.075
                //layout.spacingPercentile=1.3
                
                var collectionView=MODSubcategoryCollectionView(frame: CGRect(x: CGFloat(0), y:CGFloat(430*i)+200, width: self.view.frame.size.width, height: CGFloat(430)), collectionViewLayout: layout)
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
                        continue
                    }
                    self.scrollView.addSubview(collectionView)
                    self.scrollView.scrollEnabled=true
                    self.scrollView.contentSize=CGSizeMake(self.scrollView.frame.size.width, collectionView.frame.origin.y+collectionView.frame.size.height)
                    
                }
                collectionView.reloadData()
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
        mediaElement.textLabel?.textColor=UIColor.whiteColor()
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
                    //self.backgroundImage.image=imageUsingCache(imageURL!)
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
    
    
    var subcategoryCollectionViews:[MODSubcategoryCollectionView]=[]
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        let subcategories=unfold("\(categoryDataURL)|category|subcategories|\(subcategoryCollectionViews.indexOf(collectionView as! MODSubcategoryCollectionView)!)|media|count") as? Int
        if (subcategories != nil){
            return subcategories!
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("mediaElement", forIndexPath: indexPath)
        cell.alpha=1
        cell.clipsToBounds=false
        cell.contentView.layoutSubviews()
        let retrievedVideo=unfold("\(categoryDataURL)|category|subcategories|\(subcategoryCollectionViews.indexOf(collectionView as! MODSubcategoryCollectionView)!)|media|\(indexPath.row)")
        
        let imageRatios=retrievedVideo!.objectForKey("images")!
        
        let priorityRatios=["pns","pss","wsr","lss","cvr","wss","lsr"].reverse()//wsr
        
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
        var image=UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        var hasImageView=false
        var hasLabelView=false
        
        for subview in cell.contentView.subviews {
            if (subview.isKindOfClass(UIImageView.self)){
                hasImageView=true
            }
            if (subview.isKindOfClass(UILabel.self)){
                hasLabelView=true
            }
        }
        if (hasImageView == false){
            cell.contentView.addSubview(UIImageView(frame: cell.bounds))
        }
        
        if (hasLabelView == false){
            let label=marqueeLabel(frame: CGRect(x: 0, y: cell.bounds.size.height/2+10, width: cell.bounds.size.width, height: cell.bounds.size.height))
            
            label.fadeLength=15
            label.fadePadding = 30
            label.fadePaddingWhenFull = -5
            label.textSideOffset=15
            
            label.textColor=UIColor.darkGrayColor()
            label.textAlignment = .Center
            label.font=UIFont.systemFontOfSize(29)
            //label.text="asdfasdfasdfasdfasdfasfdsdf"
            cell.contentView.addSubview(label)
        }
        
        for subview in cell.contentView.subviews {
            if (subview.isKindOfClass(UIImageView.self)){
                
                (subview as! UIImageView).image=image
                
                fetchDataUsingCache(imageURL!, downloaded: {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        image=imageUsingCache(imageURL!)
                        
                        var ratio=(image?.size.width)!/(image?.size.height)!
                        (subview as! UIImageView).frame=CGRect(x: (cell.frame.size.width-((cell.frame.size.height-60)*ratio))/2, y: 0, width: (cell.frame.size.height-60)*ratio, height: (cell.frame.size.height-60))
                        
                        if (image?.size.width>(image!.size.height)){
                            ratio=(image?.size.height)!/(image?.size.width)!
                            (subview as! UIImageView).frame=CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.width*ratio)
                        }
                        
                        (subview as! UIImageView).image=image
                        (subview as! UIImageView).frame=CGRect(x: (cell.frame.size.width-subview.frame.size.width)/2, y: (cell.frame.size.height-subview.frame.size.height)/2, width: subview.frame.size.width, height: subview.frame.size.height)
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
        if (subcategoryCollectionViews.contains(context.previouslyFocusedView?.superview as! MODSubcategoryCollectionView)){
            
            for subview in (context.previouslyFocusedView?.subviews.first!.subviews)! {
                if (subview.isKindOfClass(UILabel.self)){
                    (subview as! UILabel).textColor=UIColor.darkGrayColor()
                    subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y-5, width: subview.frame.size.width, height: subview.frame.size.height)
                }
                if (subview.isKindOfClass(marqueeLabel.self)){
                    (subview as! marqueeLabel).endFocus()
                }
            }
        }
        if (subcategoryCollectionViews.contains(context.nextFocusedView?.superview as! MODSubcategoryCollectionView)){
            context.nextFocusedView?.subviews.first?.alpha=1
            
            for subview in (context.nextFocusedView?.subviews.first!.subviews)! {
                if (subview.isKindOfClass(UILabel.self)){
                    (subview as! UILabel).textColor=UIColor.whiteColor()
                    //(subview as! UILabel).shadowColor=UIColor.blackColor()
                    subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y+5, width: subview.frame.size.width, height: subview.frame.size.height)
                }
                if (subview.isKindOfClass(marqueeLabel.self)){
                    (subview as! marqueeLabel).beginFocus()
                }
            }
            self.scrollView.scrollRectToVisible((context.nextFocusedView?.superview?.frame)!, animated: true)
        }
        
        
        
        return true
    }
    
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        /*
        let category="VideoOnDemand"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        categoryToGoTo=unfold(categoryDataURL+"|category|subcategories|\(indexPath.row)|key") as! String
        print("category to go to \(categoryToGoTo)")*/
        return true
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: 560/1.05, height: 360/1.05)//588,378
    }
    
}
