//
//  HomeController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/13/15.
//  Copyright © 2015 Austin Zelenka. All rights reserved.
//


/*

This controller is code backing the Home tab.
There are 3 Major UICollectionView objects inside of HomeController:
slideShowCollectionView, streamingCollectionView, latestVideosCollectionView
Each UICollectionView is also a subclass of SuperCollectionView which primarily manages its own content however HomeController remains their delegate.

HomeController mostly acts as a method handler, forwarder and layout manager for it's collection views and most of the deep code is not contained here. To change how any of the UICollectionViews behave and respond refer to their classes:

UICollectionView - {

    SuperCollectionView - {
        
        SlideShow

        LatestVideos

        ChannelSelector

    }
}


*/


import UIKit
import AVKit

class HomeController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var streamingCollectionView: ChannelSelector!
    @IBOutlet weak var slideShowCollectionView: SlideShow!
    @IBOutlet weak var latestVideosCollectionView: LatestVideos!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    var latestVideos=[]
    
    @IBOutlet weak var BackgroundEffectView: UIVisualEffectView!
    @IBOutlet weak var JWBroadcastingLogo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.userInteractionEnabled=true
        
        backgroundImageView.alpha=0.75
        BackgroundEffectView.alpha=0.99
        
        /*
        
        Set colors of tab bar. Selected is white not is gray.
        
        */
        
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.grayColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Selected)
        
        /* Activity variables */
        
        /*
        We don't need to see the activity indicator when it is not active.
        Expand activity indicator to make it TV sized and set other variables.
        */
        
        activityIndicator.hidesWhenStopped=true
        activityIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0)
        
        /*Hide all of the previews until they are done loading*/
        
        self.slideShowCollectionView.alpha=0
        
        self.streamingCollectionView.alpha=0
        self.streamingCollectionView.label.superview!.alpha=0
        
        self.latestVideosCollectionView.alpha=0
        self.latestVideosCollectionView.label.alpha=0
        
        /*Listens for language changes and updates*/
        addBranchListener("language", serverBonded: {
            dispatch_async(dispatch_get_main_queue()) {
                if (self.view.hidden == false){
                    print("[Home] update language")
                    self.renewContent()
                    self.previousLanguageCode=languageCode
                }
            }
        })
        /*Call initial update because local variables and files are not yet implmented*/
        checkBranchesFor("language")
        
    }
    
    var activity=0
    
    func addActivity(){
        
        /*When the page is loading we want interaction to be disabled and to show that cleanly*/
        
        /*Hide all of the previews until they are done loading*/
        
        self.slideShowCollectionView.alpha=0
        self.streamingCollectionView.alpha=0
        self.streamingCollectionView.label.superview!.alpha=0
        self.latestVideosCollectionView.alpha=0
        self.latestVideosCollectionView.label.alpha=0
        UIView.animateWithDuration(0.5, animations: {
        })
        
        /*Let logs know we are loading*/
        
        if (activity==0){
            print("[HOME] Start loading... \(activity)")
        }
        
        /*Show the spinning wheel and add a tick to the counter*/
        
        activity++
        self.activityIndicator.startAnimating()
    }
    
    func removeActivity(){
        
        /*
        Remove an activity tick and if we reach 0 then allow the user to interact.
        
        
        */
        
        activity--
        
        if (activity<=0){
            
            /*Bring back the previews*/
            
            UIView.animateWithDuration(0.5, animations: {
                self.slideShowCollectionView.alpha=1
                self.streamingCollectionView.alpha=1
                self.streamingCollectionView.label.superview!.alpha=1
                self.latestVideosCollectionView.alpha=1
                self.latestVideosCollectionView.label.alpha=1
            })
            
            /*Turn off the spinning wheel*/
            
            self.activityIndicator.stopAnimating()
            print("[Home] Finished loading")
        }
    }
    
    var previousLanguageCode=languageCode
    
    override func viewWillAppear(animated: Bool) {
        
        (self.tabBarController as! rootController).disableNavBarTimeOut=true
        /*
        Every time the view goes to reappear this code runs to check if the language was changed by the Language tab. If it was then everything gets refreshed.
        */
        
        if (previousLanguageCode != languageCode){
            renewContent()
            previousLanguageCode=languageCode
        }
        
        /*
        self.view.hidden=true makes sure the view is visible after hding in viewWillDisappear(...)
        */
        self.view.hidden=false
    }
    
    /*func viewDidAppear(animated: Bool) {
        <#code#>
    }*/
    
    override var preferredFocusedView:UIView? {
        get {
            if (self.slideShowCollectionView.preferredFocusedView != nil){
                return self.slideShowCollectionView
            }
            return super.preferredFocusedView
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        /*
        self.view.hidden=false is used because TV OS is not reliable with changing view controllers. Sometimes subviews of one controller can jump to another if you rapidely switch between and/or if their is brackground threads/timers updating content.
        */
        self.view.hidden=true
    }
    
    var latestVideosTranslatedTitle:String="Latest Videos"
    
    func renewContent(){
        /*
        If the language file is downloaded then update.
        */
        
        
        /*
        Calls prepare methods in SuperCollectionViews so that they can downloaded any files necissary to display content.
        */
        activity=0
        if (HomeFeatured){
            self.slideShowCollectionView.prepare()
        }
        else {
            //self.slideShowTopConstraint.constant = -self.slideShowCollectionView.frame.size.height
            self.JWBroadcastingLogoTopConstraint.constant = 40
            self.view.layoutIfNeeded()
        }
        self.streamingCollectionView.prepare()
        self.latestVideosCollectionView.prepare()
        
        fetchDataUsingCache(base+"/"+version+"/translations/"+languageCode, downloaded: {
            /*
            
            After double checking that the collectionview has our custom flow layout (which it should always be but I like double checking) the collectionview then applies horizontal scrolling for the slide show and adjusts the margins between cells.
            */
            
            if (self.slideShowCollectionView.collectionViewLayout.isKindOfClass(CollectionViewHorizontalFlowLayout.self) == true){
                
                (self.slideShowCollectionView.collectionViewLayout as! CollectionViewHorizontalFlowLayout).scrollDirection=UICollectionViewScrollDirection.Horizontal
                (self.slideShowCollectionView.collectionViewLayout as! CollectionViewHorizontalFlowLayout).spacingPercentile=1.05
            }
            
            if (self.latestVideosCollectionView.collectionViewLayout.isKindOfClass(CollectionViewHorizontalFlowLayout.self) == true){
                (self.latestVideosCollectionView.collectionViewLayout as! CollectionViewHorizontalFlowLayout).scrollDirection=UICollectionViewScrollDirection.Horizontal
                (self.latestVideosCollectionView.collectionViewLayout as! CollectionViewHorizontalFlowLayout).spacingPercentile=1.075
            }
            if (self.streamingCollectionView.collectionViewLayout.isKindOfClass(CollectionViewHorizontalFlowLayout.self) == true){
                (self.streamingCollectionView.collectionViewLayout as! CollectionViewHorizontalFlowLayout).scrollDirection=UICollectionViewScrollDirection.Horizontal
                UICollectionViewScrollDirection.Horizontal
                (self.streamingCollectionView.collectionViewLayout as! CollectionViewHorizontalFlowLayout).spacingPercentile=1.1
                
            }
            
            
            
            
            
        })
        
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        /*
        States that all the collectionViews only have 1 section.
        */
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        /*
        Headers, footers and decoorative items are processed in this method. SuperCollectionViews manage their own supplementary items so if UICollectionView is a SuperCollectionView let it handle itself.
        */
        
        let supplementaryItem:UICollectionReusableView?=nil
        
        if (collectionView.isKindOfClass(SuperCollectionView.self)){
            return (collectionView as! SuperCollectionView).supplementaryElement(kind, forIndexPath: indexPath)
        }
        
        return supplementaryItem!
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        /*
        This method delegates how many videos or media types are in a UICollectionView. SuperCollectionViews manage their own cell count so if UICollectionView is a SuperCollectionView let it handle itself.
        */
        
        if (collectionView.isKindOfClass(SuperCollectionView.self)){
            return (collectionView as! SuperCollectionView).totalItemsInSection(section)
        }
        print("[ERROR] not enough")
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        /*
        This method processes and delegates UICollectionViewCells. UICollectionView that are SuperCollectionViews manage their own cells so if UICollectionView is a SuperCollectionView let it handle itself.
        */
        
        if (collectionView.isKindOfClass(SuperCollectionView.self)){
            return (collectionView as! SuperCollectionView).cellAtIndex(indexPath)
        }
        print("[ERROR] THIS SHOULD NEVER HAPPEN! \(collectionView)")
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        /*
        This method handles actions performed when a cell is selected, clicked, pressed or chosen on UICollectionViewCells. UICollectionView that are SuperCollectionViews manage their own selection events so if UICollectionView is a SuperCollectionView let it handle itself.
        */
        
        if (collectionView.isKindOfClass(SuperCollectionView.self)){
            (collectionView as! SuperCollectionView).cellSelect(indexPath)
            return true
        }
        
        return true
    }
    
    var goToStreamID:Int = -1
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        /*
        This method is used to pass data to other ViewControllers that are being presented. Currently the only data needed to be sent is the channel ID selected in ChannelSelector. This passes the information on what channel to watch.
        */
        
        if (segue.destinationViewController.isKindOfClass(StreamingViewController.self)){
            if (goToStreamID > -1){
                (segue.destinationViewController as! StreamingViewController).streamID=goToStreamID
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        /*
        Makes all cells selectable.
        */
        
        return true
    }
    
    @IBOutlet weak var slideShowTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var JWBroadcastingLogoTopConstraint: NSLayoutConstraint!
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        /*
        This method defines the size of UICollectionViewCells. UICollectionView that are SuperCollectionViews manage their own cell sizes so if UICollectionView is a SuperCollectionView let it handle itself.
        */
        
        if (collectionView.isKindOfClass(SuperCollectionView.self)){
            return (collectionView as! SuperCollectionView).sizeOfItemAtIndex(indexPath)
        }
        /*
        Unknown collectionView so default.
        */
        return CGSizeMake(0, 0)
    }
    var selectedSlideShow=false
    
    func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
        
        /*
        
        This method handles when the user moves focus over a UICollectionViewCell and/or UICollectionView.
        
        UICollectionView that are SuperCollectionViews manage their own focus events so if UICollectionView is a SuperCollectionView let it handle itself.
        
        Lastly if he LatestVideos or SlideShow collection view are focused move everything up so you can see them.
        */
        
        if (context.previouslyFocusedView?.superview!.isKindOfClass(SuperCollectionView.self) == true && context.previouslyFocusedIndexPath != nil){
            (context.previouslyFocusedView?.superview as! SuperCollectionView).cellShouldLoseFocus(context.previouslyFocusedView!, indexPath: context.previouslyFocusedIndexPath!)
        }
        if (context.nextFocusedView?.superview!.isKindOfClass(SuperCollectionView.self) == true && context.nextFocusedIndexPath != nil){
            (context.nextFocusedView?.superview as! SuperCollectionView).cellShouldFocus(context.nextFocusedView!, indexPath: context.nextFocusedIndexPath!)
            (context.nextFocusedView?.superview as! SuperCollectionView).cellShouldFocus(context.nextFocusedView!, indexPath: context.nextFocusedIndexPath!, previousIndexPath: context.previouslyFocusedIndexPath)
        }
        
        
        if (collectionView == self.latestVideosCollectionView || collectionView == slideShowCollectionView ){
            
            if (context.nextFocusedView?.superview == self.latestVideosCollectionView || context.nextFocusedView?.superview == self.streamingCollectionView){
                
                UIView.animateWithDuration(0.5, animations: {
                    
                    //self.slideShowTopConstraint.constant = -self.slideShowCollectionView.frame.size.height+150//880 1080
                    self.JWBroadcastingLogoTopConstraint.constant = -self.slideShowCollectionView.frame.size.height+30
                    self.slideShowCollectionView.alpha=0.001
                    self.view.layoutIfNeeded()
                })
            }
            else {
                
                UIView.animateWithDuration(0.5, animations: {
                    
                    //self.slideShowTopConstraint.constant = -30
                    self.JWBroadcastingLogoTopConstraint.constant = 40
                    self.slideShowCollectionView.alpha=1
                    self.view.layoutIfNeeded()
                })
            }
        }
        return true
    }
}

