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
    var SLSlides=[]
    
    override func prepare(){
        
        self.contentInset=UIEdgeInsetsMake(0, 60, 0, 60)
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        
        fetchDataUsingCache(pathForSliderData, downloaded: {
            
            dispatch_async(dispatch_get_main_queue()) {
                self.reloadData()
                //self.performSelector("timesUp", withObject: nil, afterDelay: 2.25)
            }
        })
        
    }
    override func totalItemsInSection(section: Int) -> Int {
        
        let slides=unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider|settings|WebHomeSlider|slides") as? NSArray
        if (slides == nil){
            return 0
        }
        return slides!.count
    }
    
    override func sizeOfItemAtIndex(indexPath:NSIndexPath) -> CGSize{
        
        return CGSize(width: self.superview!.bounds.width-200, height: self.superview!.bounds.height*0.4)//1140, 380 image size
    }
    
    
    override func cellAtIndex(indexPath:NSIndexPath) -> UICollectionViewCell{
        let slide: UICollectionViewCell = self.dequeueReusableCellWithReuseIdentifier("slide", forIndexPath: indexPath)
        for subview in slide.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        slide.backgroundColor=UIColor.grayColor()
        
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        
            addBranchListener(pathForSliderData, serverBonded: {
                
                let SLSlide=unfold("\(pathForSliderData)|settings|WebHomeSlider|slides|\(indexPath.row)")!
                let imageURL=unfold(SLSlide, instructions: ["item","images","pnr","lg"]) as? String
                if (imageURL != nil){
                    
                    fetchDataUsingCache(imageURL!, downloaded: {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let image=imageUsingCache(imageURL!)
                            
                            let imageView=UIImageView(image: image)
                            imageView.userInteractionEnabled = true
                            //imageView.adjustsImageWhenAncestorFocused = true
                            imageView.frame=CGRectMake(0, 0, slide.frame.size.width, slide.frame.size.height)
                            
                            slide.contentView.addSubview(imageView)
                            
                            let dissipatingView=UIView(frame: CGRect(x: 0, y: 0, width: slide.frame.size.width, height: slide.frame.size.height))
                            
                            let playIcon=UILabel()
                            playIcon.frame=CGRectMake(50, 100, 100, 100)
                            playIcon.text=""
                            playIcon.font=UIFont(name: "jwtv", size: 75)!
                            playIcon.textColor=UIColor.whiteColor()
                            //dissipatingView.addSubview(playIcon)
                            
                            
                            let titleLabel=UILabel()
                            titleLabel.frame=CGRectMake(50, slide.bounds.height-75, slide.bounds.width-100, 75)
                            //titleLabel.backgroundColor=UIColor.redColor()
                            titleLabel.text=SLSlide.objectForKey("item")!.objectForKey("title")! as? String
                            titleLabel.layer.shadowColor=UIColor.blackColor().CGColor
                            titleLabel.layer.shadowRadius=5
                            titleLabel.layer.opacity=1
                            titleLabel.numberOfLines=3
                            //titleLabel.font=UIFont(name: "jwtv", size: 75)!
                            titleLabel.font=UIFont.systemFontOfSize(24)
                            titleLabel.textColor=UIColor.whiteColor()
                            
                            
                            
                            let gradient: CAGradientLayer = CAGradientLayer()
                            gradient.frame = slide.bounds
                            gradient.colors = [UIColor.clearColor().CGColor, UIColor.clearColor(), UIColor.blackColor().CGColor]
                            dissipatingView.layer.insertSublayer(gradient, atIndex: 0)
                            dissipatingView.alpha=0
                            dissipatingView.addSubview(titleLabel)
                            
                            
                            slide.contentView.addSubview(dissipatingView)
                        }
                        
                    })
                }
            })
        return slide
    }
    
    var selectedSlideShow=false

    override func cellShouldFocus(view:UIView, indexPath:NSIndexPath){
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UIImageView.self)){
                subview.frame=CGRect(x: 0, y: -20, width: subview.frame.size.width, height: subview.frame.size.height+40)
            }
        }
        selectedSlideShow=true
    }
    
    override func cellShouldLoseFocus(view:UIView, indexPath:NSIndexPath){
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UIImageView.self)){
                subview.frame=view.bounds
            }
        }
        selectedSlideShow=false
    }
    
    func moveToSlide(atIndex:Int){
        if (unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider") != nil ){
            self.scrollToItemAtIndexPath(NSIndexPath(forRow: atIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        }
    }
    
    
    
    func timesUp(){
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