//
//  ViewController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/13/15.
//  Copyright © 2015 Austin Zelenka. All rights reserved.
//



import UIKit
import AVKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var slideshow: UIImageView!
    @IBOutlet weak var pageIndicator: UIPageControl!
    
    @IBOutlet weak var latestVideosCollectionView: LatestVideos!
    @IBOutlet weak var customLayout: collectionViewRightToLeftFlowLayout!
    
    @IBOutlet weak var streamingCollectionView: ChannelSelector!
    @IBOutlet weak var slideShowCollectionView: SlideShow!
    
    var latestVideos=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.userInteractionEnabled=true
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.grayColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Selected)
        activityIndicator.hidesWhenStopped=true
        activityIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0)
        pageIndicator.hidden=true
        
        self.slideShowCollectionView.prepare()
        self.streamingCollectionView.prepare()
        self.latestVideosCollectionView.prepare()
        
        
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
    
    override func viewWillDisappear(animated: Bool) {
        self.view.hidden=true
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
                (self.slideShowCollectionView.collectionViewLayout as! collectionViewRightToLeftFlowLayout).spacingPercentile=1.05
            }
            
            if (self.latestVideosCollectionView.collectionViewLayout.isKindOfClass(collectionViewRightToLeftFlowLayout.self) == true){
                (self.latestVideosCollectionView.collectionViewLayout as! collectionViewRightToLeftFlowLayout).scrollDirection=UICollectionViewScrollDirection.Horizontal
                (self.latestVideosCollectionView.collectionViewLayout as! collectionViewRightToLeftFlowLayout).spacingPercentile=1.075
            }
            if (self.streamingCollectionView.collectionViewLayout.isKindOfClass(collectionViewRightToLeftFlowLayout.self) == true){
                (self.streamingCollectionView.collectionViewLayout as! collectionViewRightToLeftFlowLayout).scrollDirection=UICollectionViewScrollDirection.Horizontal
                UICollectionViewScrollDirection.Horizontal
                (self.streamingCollectionView.collectionViewLayout as! collectionViewRightToLeftFlowLayout).spacingPercentile=1.1
                
            }
            
            self.activityIndicator.stopAnimating()
            self.pageIndicator.hidden=true
        }
        else {
            
            activityIndicator.startAnimating()
        }
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let header:UICollectionReusableView?=nil
        
        if (collectionView.isKindOfClass(SuperCollectionView.self)){
            return (collectionView as! SuperCollectionView).supplementaryElement(kind, forIndexPath: indexPath)
        }
        
        return header!
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView.isKindOfClass(SuperCollectionView.self)){
            return (collectionView as! SuperCollectionView).totalItemsInSection(section)
        }
        print("[ERROR] not enough")
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        if (collectionView.isKindOfClass(SuperCollectionView.self)){
            return (collectionView as! SuperCollectionView).cellAtIndex(indexPath)
        }
        print("[ERROR] THIS SHOULD NEVER HAPPEN! \(collectionView)")
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if (collectionView.isKindOfClass(SuperCollectionView.self)){
            (collectionView as! SuperCollectionView).cellSelect(indexPath)
            return true
        }
        else if (collectionView == streamingCollectionView){
            
            /*let streamingViewController=StreamingViewController()
            streamingViewController.streamID=indexPath.row
            self.presentViewController(streamingViewController, animated: true, completion: {})
            */
            goToStreamID=indexPath.row
            self.performSegueWithIdentifier("presentStreaming", sender: self)
        }
        return true
    }
    
    var goToStreamID:Int = -1
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.destinationViewController.isKindOfClass(StreamingViewController.self)){
            if (goToStreamID > -1){
                (segue.destinationViewController as! StreamingViewController).streamID=goToStreamID
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
        
        
        if (collectionView.isKindOfClass(SuperCollectionView.self)){
            return (collectionView as! SuperCollectionView).sizeOfItemAtIndex(indexPath)
        }
        return CGSizeMake(0, 0)
    }
    
    var selectedSlideShow=false
    
    func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
        
        /*
        This method provides the blue highlighting to the cells and sets variable selectedSlideShow:Bool.
        If selectedSlideShow==true (AKA the user is interacting with the slideshow) then the slide show will not roll to next slide.

        */
        
        if (context.previouslyFocusedView?.superview!.isKindOfClass(SuperCollectionView.self) == true && context.previouslyFocusedIndexPath != nil){
            (context.previouslyFocusedView?.superview as! SuperCollectionView).cellShouldLoseFocus(context.previouslyFocusedView!, indexPath: context.previouslyFocusedIndexPath!)
        }
        if (context.nextFocusedView?.superview!.isKindOfClass(SuperCollectionView.self) == true && context.nextFocusedIndexPath != nil){
            (context.nextFocusedView?.superview as! SuperCollectionView).cellShouldFocus(context.nextFocusedView!, indexPath: context.nextFocusedIndexPath!)
        }
        
        
        if (collectionView == self.latestVideosCollectionView || collectionView == slideShowCollectionView ){
            
            if (context.nextFocusedView?.superview == self.latestVideosCollectionView || context.nextFocusedView?.superview == self.streamingCollectionView){
                
                UIView.animateWithDuration(0.5, animations: {
                    
                    self.slideShowTopConstraint.constant = -self.slideShowCollectionView.frame.size.height+100//880 1080
                    self.slideShowCollectionView.alpha=0.001
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
}

