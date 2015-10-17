//
//  ViewController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/13/15.
//  Copyright © 2015 xquared. All rights reserved.
//



import UIKit
import AVKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var slideshow: UIImageView!
    @IBOutlet weak var pageIndicator: UIPageControl!
    
    @IBOutlet weak var latestVideosCollectionView: UICollectionView!
    
    @IBOutlet weak var slideShowCollectionView: UICollectionView!
    var timer:NSTimer?
    let timeToShow=5
    
    var SLSlides=[]
    var SLIndex=0
    
    var latestVideos=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UICollectionViewScrollDirectionHorizontal
        
        //latestVideosCollectionView.backgroundColor=UIColor.blueColor()
        
        activityIndicator.hidesWhenStopped=true
        activityIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0)
        pageIndicator.hidden=true
        
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.grayColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Selected)
        
        
    }
    
    var previousLanguageCode=languageCode
    
    override func viewWillAppear(animated: Bool) {
        if (previousLanguageCode != languageCode){
            renewContent()
        }
        previousLanguageCode=languageCode
    }
    
    @IBOutlet weak var latestVideosLabel: UILabel!
    func renewContent(){
        if (languageList?.count>0){
            activityIndicator.startAnimating()
            
            /*

            After double checking that the collectionview has our custom flow layout (which it should always be but I like double checking) the collectionview then applies horizontal scrolling for the slide show.
            */
            
            if (self.slideShowCollectionView.collectionViewLayout.isKindOfClass(collectionViewRightToLeftFlowLayout.self) == true){
                
                (self.slideShowCollectionView.collectionViewLayout as! collectionViewRightToLeftFlowLayout).scrollDirection=UICollectionViewScrollDirection.Horizontal
                
            }
            
            
            /*Some extra translation stuff I found*/
            let categories=dictionaryOfPath(base+"/"+version+"/categories/"+languageCode)
            if (categories != nil){
                print(categories)
                for category in (categories?.objectForKey("categories") as? NSArray)! {
                    if ((category.objectForKey("key") as? String)! == "LatestVideos"){
                        latestVideosLabel.text=category.objectForKey("name") as? String
                    }
                }
            }
            
            /*setup the slideshow on the top and begin the timer*/
            buildSlideshow()
            
            
            /*[self.collectionView performBatchUpdates:^{
                [self.collectionView reloadData];
                } completion:^(BOOL finished) {
                // notify that completed and do the configuration now
                }];*/
            
            /*fetch information on latest videos then reload the views*/
            self.latestVideos=(dictionaryOfPath(base+"/"+version+"/categories/"+languageCode+"/LatestVideos?detailed=1")?.objectForKey("category")?.objectForKey("media"))! as! NSArray
            
            self.latestVideosCollectionView.performSelector("reloadData", withObject: nil, afterDelay: 0.25)
            //self.slideShowCollectionView.performSelector("reloadData", withObject: nil, afterDelay: 0.25)
            //self.slideShowCollectionView.reloadData()
            
            
            /*well everything is downloaded now so lets hide the spinning wheel and start rendering the views*/
            activityIndicator.stopAnimating()
            pageIndicator.hidden=true

            
            
        }
        else {
            
            activityIndicator.startAnimating()
        }
        
        
    }
    
    func buildSlideshow(){
        let sliders=dictionaryOfPath(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider")
        let SLSettings=sliders?.objectForKey("settings")
        let SLWebHome=SLSettings?.objectForKey("WebHomeSlider")
        SLSlides=(SLWebHome?.objectForKey("slides")) as! NSArray
        pageIndicator.numberOfPages=SLSlides.count
        self.slideShowCollectionView.reloadData()
        self.performSelector("timesUp", withObject: nil, afterDelay: 0.25)

    }
    
    
    func timesUp(){
        pageIndicator.currentPage=SLIndex
        /*let SLSlide=SLSlides.objectAtIndex(SLIndex)//SLSlides?.count
        let images=SLSlide.objectForKey("item")!.objectForKey("images")
        let imageURL=images?.objectForKey("pnr")?.objectForKey("lg") as! String
        //print(images)
        */
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            //let image=self.imageUsingCache(imageURL)
            dispatch_async(dispatch_get_main_queue()) {
                //self.slideshow.image=image
            }
        }
        
        if (selectedSlideShow == false){
        
            moveToSlide(SLIndex)
            
        }
        
        timer=NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(timeToShow), target: self, selector: "timesUp", userInfo: nil, repeats: false)
        
        if (selectedSlideShow == false){
            
            SLIndex++;
            
            if (SLIndex>=SLSlides.count){
                SLIndex=0
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == latestVideosCollectionView){
            return latestVideos.count
        }
        else if (collectionView == slideShowCollectionView){
            return SLSlides.count
        }
        print("not enough")
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        
        
        if (collectionView == latestVideosCollectionView){

            let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
            /*for subview in cell.contentView.subviews {
                subview.removeFromSuperview()
            }*/
            
            let videoData=latestVideos.objectAtIndex(indexPath.row)
            let imageURL=videoData.objectForKey("images")?.objectForKey("lsr")?.objectForKey("md") as! String
            let image=imageUsingCache(imageURL)
            
            for subview in cell.contentView.subviews {
                if (subview.isKindOfClass(UIImageView.self)){
                    (subview as! UIImageView).image=image
                }
                if (subview.isKindOfClass(UIButton.self)){
                    
                    /* apparently the OS will never select UIButton inside of a UICollectionViewCell so this needs to be changed to a UILabel */
                    
                    let button=(subview as! UIButton)
                    button.setTitle(videoData.objectForKey("title") as? String, forState: UIControlState.Normal)
                    button.tag=indexPath.row
                    
                    button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
                    button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Focused)
                }
            }
            return cell
        }
        else if (collectionView == slideShowCollectionView){
            let slide: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("slide", forIndexPath: indexPath)
            for subview in slide.contentView.subviews {
                subview.removeFromSuperview()
            }
            
            
            //let videoData=latestVideos.objectAtIndex(indexPath.row)
            
            let SLSlide=SLSlides.objectAtIndex(indexPath.row)//SLSlides?.count
            let images=SLSlide.objectForKey("item")!.objectForKey("images")
            let imageURL=images?.objectForKey("pnr")?.objectForKey("lg") as! String
            let image=imageUsingCache(imageURL)
            
            let imageView=UIImageView(image: image)
            imageView.frame=CGRectMake(0, 0, slide.frame.size.width, slide.frame.size.height)
            
            slide.contentView.addSubview(imageView)
            return slide
        }
        print("THIS SHOULD NEVER HAPPEN! \(collectionView)")
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
        if (collectionView == latestVideosCollectionView){
        
            let videosData=latestVideos.objectAtIndex(indexPath.row).objectForKey("files")
            
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
    
    /*
    Makes all cells selectable.
    */
    
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    /*
    Sets size of top items and latest items
    */
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if (collectionView == latestVideosCollectionView){
            return CGSizeMake(560, 360)
        }
        if (collectionView == slideShowCollectionView){
            return CGSizeMake(1140/1.2, 380/1.2)
        }
        return CGSizeMake(0, 0)
    }
    
    var selectedSlideShow=false
    
    func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
        
        /*
        This method provides the blue highlighting to the cells and sets variable selectedSlideShow:Bool.
        If selectedSlideShow==true (AKA the user is interacting with the slideshow) then the slide show will not roll to next slide.

        */
        
        
        if (collectionView==slideShowCollectionView){
            selectedSlideShow=true
        }
        else {
            selectedSlideShow=false
        }
        
        
        
        if (collectionView == self.latestVideosCollectionView || collectionView == slideShowCollectionView ){
            
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
        }
        return true
    }
    
    func moveToSlide(atIndex:Int){
        //[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        self.slideShowCollectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: atIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        let cellToBlowUp=self.slideShowCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: atIndex, inSection: 0))
        
        for cell in self.slideShowCollectionView.visibleCells() {
            UIView.animateWithDuration(1, animations: {
                cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                cell.layer.shadowColor=UIColor.blackColor().CGColor
                cell.layer.shadowRadius=20
                cell.layer.shadowOpacity=0
                cell.layer.zPosition=0
            })
        }
        
        UIView.animateWithDuration(1, animations: {
            cellToBlowUp?.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
            cellToBlowUp?.layer.shadowColor=UIColor.blackColor().CGColor
            cellToBlowUp?.layer.shadowRadius=20
            cellToBlowUp?.layer.shadowOpacity=1
            cellToBlowUp?.layer.zPosition=1000
        })
        
    }
}

