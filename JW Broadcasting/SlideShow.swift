//
//  SlideShow.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/13/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class SlideShow: SuperCollectionView {
    
    var timer:NSTimer?
    var SLIndex=0
    let timeToShow=10
    
    override func prepare(){
        
        self.contentInset=UIEdgeInsetsMake(0, 60, 0, 60)
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        
        print("[SlideShow] loading...")
        fetchDataUsingCache(pathForSliderData, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                print("[SlideShow] Downloaded")
                self.reloadData()
                //self.performSelector("timesUp", withObject: nil, afterDelay: 2.25)
            }
        })
        
    }
    override func totalItemsInSection(section: Int) -> Int {
        
        let slides=unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider|settings|WebHomeSlider|slides") as? NSArray//unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider|settings|WebHomeSlider|slides") as? NSArray
        if (slides == nil){
            return 0
        }
        return slides!.count
    }
    
    override func sizeOfItemAtIndex(indexPath:NSIndexPath) -> CGSize{
        
        return CGSize(width: 1140, height: 380)//1140, 380 image size
    }
    
    
    override func cellAtIndex(indexPath:NSIndexPath) -> UICollectionViewCell{
        let slide: UICollectionViewCell = self.dequeueReusableCellWithReuseIdentifier("slide", forIndexPath: indexPath)
        
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        
        let index=indexPath.row
        /*let totalItems=self.totalItemsInSection(0)
        index=indexPath.row-1
        if (index<0){
            index=totalItems-1
        }*/
        /*if (index>totalItems-1){
            index=index-totalItems
        }*/
        print("indexpath:\(indexPath.row) = \(index)")
        let SLSlides=unfold(pathForSliderData+"|settings|WebHomeSlider|slides") as? NSArray
        /*
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            SLSlides=SLSlides!.reverse()
        }
        */
        let SLSlide=SLSlides![index]
        for subview in slide.contentView.subviews {
            if (subview.isKindOfClass(UIImageView.self)){
                let imageView=subview as! UIImageView
                //addBranchListener(pathForSliderData, serverBonded: {
                    //unfold("\(pathForSliderData)|settings|WebHomeSlider|slides|\(indexPath.row)")!
                    
                //})
                
                
                let imageURL=unfold(SLSlide, instructions: ["item","images","pnr","lg"]) as? String
                if (imageURL != nil){
                    fetchDataUsingCache(imageURL!, downloaded: {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let image=imageUsingCache(imageURL!)
                            imageView.image=image
                            imageView.userInteractionEnabled = true
                            imageView.adjustsImageWhenAncestorFocused = true
                            imageView.frame=CGRectMake(0, 0, slide.frame.size.width, slide.frame.size.height)
                            
                            
                            
                        }
                        
                    })

                    
                }
                
            }
            if (subview.isKindOfClass(UILabel.self)){
                let titleLabel = subview as! UILabel
                titleLabel.frame=CGRectMake(50, slide.bounds.height-75, slide.bounds.width-100, 75)
                titleLabel.text=SLSlide.objectForKey("item")!.objectForKey("title")! as? String
                titleLabel.layer.shadowColor=UIColor.blackColor().CGColor
                titleLabel.layer.shadowRadius=5
                titleLabel.textColor=UIColor.whiteColor()
                
            }
        }
        
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = slide.bounds
        gradient.colors = [UIColor.clearColor().CGColor, UIColor.clearColor().CGColor, UIColor.clearColor().CGColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor]
        //slide.contentView.layer.addSublayer(gradient)
        
        
        
        return slide
    }
    
    var selectedSlideShow=false

    override func cellShouldFocus(view:UIView, indexPath:NSIndexPath){
        //view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        SLIndex=indexPath.row
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UIImageView.self)){
                
                //subview.frame=CGRect(x: 0, y: -20, width: subview.frame.size.width, height: subview.frame.size.height+40)
            }
            if (subview.isKindOfClass(UILabel.self)){
                subview.alpha=1
            }
        }
        selectedSlideShow=true
    }
    
    override func cellShouldLoseFocus(view:UIView, indexPath:NSIndexPath){
        //view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UIImageView.self)){
                subview.frame=view.bounds
            }
            if (subview.isKindOfClass(UILabel.self)){
                subview.alpha=0
            }
        }
        selectedSlideShow=false
    }
    
    func moveToSlide(atIndex:Int){
        if (unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider") != nil ){
            self.scrollToItemAtIndexPath(NSIndexPath(forRow: atIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
            SLIndex=atIndex
        }
    }
    
    
    
    func timesUp(){
        if (selectedSlideShow == false){
            
            moveToSlide(SLIndex)
            
        }
        
        timer=NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(timeToShow), target: self, selector: "timesUp", userInfo: nil, repeats: false)
        
        if (selectedSlideShow == false){
            
            SLIndex++;
            
            if (SLIndex>=(unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider|settings|WebHomeSlider|slides") as? NSArray)!.count){
                SLIndex=0
            }
        }
    }
    
    override func cellSelect(indexPath:NSIndexPath){
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        let videosData=unfold("\(pathForSliderData)|settings|WebHomeSlider|slides|\(indexPath.row)")!.objectForKey("item")!.objectForKey("files")
        if (videosData != nil){
            let videoData=videosData?.objectAtIndex((videosData?.count)!-1)
            let videoURLString=videoData?.objectForKey("progressiveDownloadURL") as! String
            
            let videoURL = NSURL(string: videoURLString)
            let player = AVPlayer(URL: videoURL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.window?.rootViewController!.presentViewController(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
}