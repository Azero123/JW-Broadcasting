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
        
        renewContent()
        
        /*setup the slideshow on the top and begin the timer*/
        buildSlideshow()
    }
    
    var previousLanguageCode=languageCode
    
    override func viewWillAppear(animated: Bool) {
        if (previousLanguageCode != languageCode){
            renewContent()
        }
        previousLanguageCode=languageCode
    }
    
    var latestVideosTranslatedTitle:String="Latest Videos"
    
    func renewContent(){
        if (languageList?.count>0){
            activityIndicator.startAnimating()
            
            /*

            After double checking that the collectionview has our custom flow layout (which it should always be but I like double checking) the collectionview then applies horizontal scrolling for the slide show.
            */
            
            if (self.slideShowCollectionView.collectionViewLayout.isKindOfClass(collectionViewRightToLeftFlowLayout.self) == true){
                
                (self.slideShowCollectionView.collectionViewLayout as! collectionViewRightToLeftFlowLayout).scrollDirection=UICollectionViewScrollDirection.Horizontal
                
            }
            
            /*fetch information on latest videos then reload the views*/
            
            let latestVideosPath=base+"/"+version+"/categories/"+languageCode+"/LatestVideos?detailed=1"
                fetchDataUsingCache(latestVideosPath, downloaded: {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                    //"name":"Latest Videos"
                    let latestVideosData=dictionaryOfPath(latestVideosPath)!
                    self.latestVideosTranslatedTitle=(latestVideosData.objectForKey("category")?.objectForKey("name") as? String)!
                    self.latestVideos=(latestVideosData.objectForKey("category")?.objectForKey("media"))! as! NSArray
            
                    self.latestVideosCollectionView.performSelector("reloadData", withObject: nil, afterDelay: 0.25)
                    /*well everything is downloaded now so lets hide the spinning wheel and start rendering the views*/
                    self.activityIndicator.stopAnimating()
                    self.pageIndicator.hidden=true
                    }
                })

            
            
        }
        else {
            
            activityIndicator.startAnimating()
        }
        
        
    }
    
    func buildSlideshow(){
        
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        
        fetchDataUsingCache(pathForSliderData, downloaded: {
            
            dispatch_async(dispatch_get_main_queue()) {
                let sliders=dictionaryOfPath(pathForSliderData)
                let SLSettings=sliders?.objectForKey("settings")
                let SLWebHome=SLSettings?.objectForKey("WebHomeSlider")
                self.SLSlides=(SLWebHome?.objectForKey("slides")) as! NSArray
                self.pageIndicator.numberOfPages=self.SLSlides.count
                self.slideShowCollectionView.reloadData()
                self.performSelector("timesUp", withObject: nil, afterDelay: 0.25)
            }
        })

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
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var header:UICollectionReusableView?=nil
        
        if (kind == UICollectionElementKindSectionHeader){
            header=collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "title", forIndexPath: indexPath)
            
            for subview in header!.subviews {
                subview.removeFromSuperview()
            }
            
            var textspacing:CGFloat=300
            
            let categoryLabel=UILabel(frame: CGRect(x: 0, y: 0, width: textspacing, height: 60))
            categoryLabel.font=UIFont.systemFontOfSize(30)
            
            categoryLabel.text=latestVideosTranslatedTitle
            textspacing=categoryLabel.intrinsicContentSize().width+25
            categoryLabel.frame=CGRect(x: 0, y: 0, width: textspacing, height: 60)
            header?.addSubview(categoryLabel)
            
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == latestVideosCollectionView){
            return latestVideos.count
        }
        else if (collectionView == slideShowCollectionView){
            return SLSlides.count
        }
        print("[ERROR] not enough")
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
            
            fetchDataUsingCache(imageURL, downloaded: {
                
                
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
                
            })

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
            
            
            
            fetchDataUsingCache(imageURL, downloaded: {
                
                
                let image=imageUsingCache(imageURL)
                
                let imageView=UIImageView(image: image)
                imageView.frame=CGRectMake(0, 0, slide.frame.size.width, slide.frame.size.height)
                slide.contentView.addSubview(imageView)
                
                let dissipatingView=UIView(frame: CGRect(x: 0, y: 0, width: slide.frame.size.width, height: slide.frame.size.height))
                
                let playIcon=UILabel()
                playIcon.frame=CGRectMake(50, 100, 100, 100)
                playIcon.text=""
                playIcon.font=UIFont(name: "jwtv", size: 75)!
                playIcon.textColor=UIColor.whiteColor()
                dissipatingView.addSubview(playIcon)
                
                
                let titleLabel=UILabel()
                titleLabel.frame=CGRectMake(50, 150, 600, 100)
                titleLabel.text=SLSlide.objectForKey("item")!.objectForKey("title")! as? String
                titleLabel.layer.shadowColor=UIColor.blackColor().CGColor
                titleLabel.layer.shadowRadius=5
                titleLabel.layer.opacity=1
                titleLabel.numberOfLines=3
                //titleLabel.font=UIFont(name: "jwtv", size: 75)!
                titleLabel.font=UIFont.systemFontOfSize(24)
                titleLabel.textColor=UIColor.whiteColor()
                dissipatingView.addSubview(titleLabel)
                
                
                slide.contentView.addSubview(dissipatingView)
                
                })
            
            return slide
        }
        print("[ERROR] THIS SHOULD NEVER HAPPEN! \(collectionView)")
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
        else if (collectionView == slideShowCollectionView){
            
            let videosData=SLSlides.objectAtIndex(indexPath.row).objectForKey("item")!.objectForKey("files")
            
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
    @IBOutlet weak var slideShowTopConstraint: NSLayoutConstraint!
    
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
        
        if (context.nextFocusedView != nil&&(context.nextFocusedIndexPath != nil)&&context.nextFocusedView?.superview == slideShowCollectionView){
            selectedSlideShow=true
            moveToSlide((context.nextFocusedIndexPath?.row)!)
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
                
                context.nextFocusedView?.layer.shadowColor=UIColor.blackColor().CGColor
                context.nextFocusedView?.layer.shadowOpacity=1
                context.nextFocusedView?.layer.shadowRadius=20
            }
            if (context.nextFocusedView?.superview == self.latestVideosCollectionView){
                
                UIView.animateWithDuration(0.5, animations: {
                    
                    self.slideShowTopConstraint.constant = -self.slideShowCollectionView.frame.size.height+90
                    self.slideShowCollectionView.alpha=0.1
                    self.view.layoutIfNeeded()
                })
            }
            else {
                
                UIView.animateWithDuration(0.5, animations: {
                    
                    self.slideShowTopConstraint.constant = 0
                    self.slideShowCollectionView.alpha=1
                    self.view.layoutIfNeeded()
                })
            }
        }
        return true
    }
    
    func moveToSlide(atIndex:Int){
        //[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        self.slideShowCollectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: atIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        let cellToBlowUp=self.slideShowCollectionView.cellForItemAtIndexPath(NSIndexPath(forRow: atIndex, inSection: 0))
        
        for cell in self.slideShowCollectionView.visibleCells() {
            if (cell != cellToBlowUp){
                UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                    cell.layer.shadowColor=UIColor.blackColor().CGColor
                    cell.layer.shadowRadius=20
                    cell.layer.shadowOpacity=0
                    cell.layer.zPosition=0
                    cell.contentView.subviews[1].alpha=0
                    }, completion: nil)
            }
            
        }
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            
            cellToBlowUp?.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
            cellToBlowUp?.layer.shadowColor=UIColor.blackColor().CGColor
            cellToBlowUp?.layer.shadowRadius=20
            cellToBlowUp?.layer.shadowOpacity=1
            cellToBlowUp?.layer.zPosition=1000
            cellToBlowUp?.contentView.subviews[1].alpha=1
            }, completion: nil)
        
        
    }
}

