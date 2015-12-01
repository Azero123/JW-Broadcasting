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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if (HomeFeaturedSlide){
            self.performSelector("timesUp", withObject: nil, afterDelay: 2.25)
        }
    }
    
    override func prepare(){
        
        (self.delegate as? HomeController)?.addActivity()
        
        self.contentInset=UIEdgeInsetsMake(0, 60, 0, 60)
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        
        print("[SlideShow] loading...")
        fetchDataUsingCache(pathForSliderData, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                print("[SlideShow] Loaded")
                
                
                
                if (textDirection == .RightToLeft){
                    self.contentOffset=self.centerPointFor(CGPointMake(self.contentSize.width-self.frame.size.width+self.contentInset.right, 0))
                }
                else {
                    self.contentOffset=CGPointMake(-self.contentInset.left, 0)
                }

                
                self.reloadData()
                
                
                (self.delegate as? HomeController)?.removeActivity()
            }
        })
    }
    override func totalItemsInSection(section: Int) -> Int {
        
        let slides=unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider|settings|WebHomeSlider|slides") as? NSArray//unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider|settings|WebHomeSlider|slides") as? NSArray
        if (slides == nil){
            print("[SlideShow][INCOMPLETION] no slides \(unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"))")
            return 0
        }
        return slides!.count
    }
    
    override func sizeOfItemAtIndex(indexPath:NSIndexPath) -> CGSize{
        
        return CGSize(width: 1140, height: 380)//1140, 380 image size
    }
    
    var indexOffset=0
    
    override func cellAtIndex(indexPath:NSIndexPath) -> UICollectionViewCell{
        let slide: UICollectionViewCell = self.dequeueReusableCellWithReuseIdentifier("slide", forIndexPath: indexPath)
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        
        var index=indexPath.row
        let totalItems=self.totalItemsInSection(0)
        index=indexPath.row-1+indexOffset
        while (index>totalItems-1){
            index = index-(totalItems)
        }
        while (index < -1){
            index = index+(totalItems)
        }
        if (index == -1){
            index = totalItems-1
        }
        
        //print("reloading index \(indexPath.row) as \(index)")
        
        /*if (index>totalItems-1){
        index=index-totalItems
        }*/
        let SLSlides=unfold(pathForSliderData+"|settings|WebHomeSlider|slides") as? NSArray
        if (SLSlides != nil){
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
                            //slide.layoutSubviews()
                            
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
                titleLabel.text=(SLSlide.objectForKey("item")!.objectForKey("title")! as? String)!
                titleLabel.layer.shadowColor=UIColor.blackColor().CGColor
                titleLabel.layer.shadowRadius=10
                titleLabel.layer.shadowOpacity=1
                titleLabel.textColor=UIColor.whiteColor()
                
            }
            if (subview.isKindOfClass(marqueeLabel.self)){
                (subview as! marqueeLabel).darkBackground=true
            }
            if (subview.isKindOfClass(MarqueeLabel.self)){
                (subview as! MarqueeLabel).type = .Continuous
                (subview as! MarqueeLabel).textAlignment = .Center
                (subview as! MarqueeLabel).lineBreakMode = .ByTruncatingHead
                (subview as! MarqueeLabel).scrollDuration = ((subview as! MarqueeLabel).intrinsicContentSize().width)/50
                (subview as! MarqueeLabel).fadeLength = 15.0
                (subview as! MarqueeLabel).leadingBuffer = 40.0
                (subview as! MarqueeLabel).animationDelay = 0
                (subview as! MarqueeLabel).pauseLabel()
            }
        }
        }


        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = slide.bounds
        gradient.colors = [UIColor.clearColor().CGColor, UIColor.clearColor().CGColor, UIColor.clearColor().CGColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).CGColor]
        //slide.contentView.layer.addSublayer(gradient)
        
        
        
        return slide
    }
    
    override func perferedFocus() -> NSIndexPath{
        return NSIndexPath(forRow: 1, inSection: 0)
    }
    
    var selectedSlideShow=false
    
    override func cellShouldFocus(view: UIView, indexPath: NSIndexPath, previousIndexPath: NSIndexPath?) {
        
        SLIndex=indexPath.row
        
        var index=indexPath.row
        
        let totalItems=self.totalItemsInSection(0)
        if (totalItems>=4){
            index=indexPath.row-1+indexOffset
            while (index>totalItems-1){
                index = index-(totalItems)
            }
            while (index < -1){
                index = index+(totalItems)
            }
            if (index == -1){
                index = totalItems-1
            }
            
        }
        
        
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        
        
        let SLSlides=unfold(pathForSliderData+"|settings|WebHomeSlider|slides") as? NSArray
        let SLSlide=SLSlides![index]
        let imageURL=unfold(SLSlide, instructions: ["item","images","pnr","lg"]) as? String
        if ((self.delegate?.isKindOfClass(HomeController.self)) == true){
            (self.delegate as! HomeController).backgroundImageView.image=imageUsingCache(imageURL!)
        }
        
        if (totalItems>=4){
            let leftIndex = 0
            let rightIndex = totalItems-1
            
            if ( previousIndexPath != nil){
                
                if (indexPath.row>previousIndexPath!.row){
                    loopItemFrom(leftIndex, to: rightIndex)
                    if (indexPath.row == totalItems-1){
                        loopItemFrom(leftIndex, to: rightIndex)
                    }
                }
                else if (indexPath.row<previousIndexPath!.row){
                    loopItemFrom(rightIndex, to: leftIndex)
                }
            }
            if (indexPath.row == 0){
                loopItemFrom(rightIndex, to: leftIndex)
            }
        }
        SLIndex=indexPath.row
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UILabel.self)){
                subview.alpha=1
            }
            if (subview.isKindOfClass(marqueeLabel.self)){
                (subview as! marqueeLabel).beginFocus()
            }
            if (subview.isKindOfClass(MarqueeLabel.self)){
                (subview as! MarqueeLabel).unpauseLabel()
            }
        }
        selectedSlideShow=true
        
    }
    
    func loopItemFrom(indexToMove:Int, to indexToGoTo:Int){
        let cell=self.cellForItemAtIndexPath(NSIndexPath(forRow: indexToMove, inSection: 0))
        if (indexToMove<indexToGoTo){
            indexOffset++
        }
        if (indexToMove>indexToGoTo){
            indexOffset--
        }
        cell?.hidden=true
        
        self.moveItemAtIndexPath(NSIndexPath(forRow: indexToMove, inSection: 0), toIndexPath: NSIndexPath(forRow: indexToGoTo, inSection: 0))
        self.performBatchUpdates({
            
            }, completion: { (finished:Bool) in
                cell?.hidden=false
        })
    }
    
    override func cellShouldLoseFocus(view:UIView, indexPath:NSIndexPath){
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UIImageView.self)){
                subview.frame=view.bounds
            }
            if (subview.isKindOfClass(UILabel.self)){
                subview.alpha=0
            }
            if (subview.isKindOfClass(marqueeLabel.self)){
                (subview as! marqueeLabel).endFocus()
            }
            if (subview.isKindOfClass(MarqueeLabel.self)){
                (subview as! MarqueeLabel).pauseLabel()
            }
        }
        selectedSlideShow=false
    }
    
    func moveToSlide(atIndex:Int){
        if (unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider") != nil ){
            
            if (self.cellForItemAtIndexPath(NSIndexPath(forRow: atIndex, inSection: 0)) != nil){
                self.scrollToItemAtIndexPath(NSIndexPath(forRow: atIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
                SLIndex=atIndex
            }
        }
    }
    
    
    
    func timesUp(){
        if (selectedSlideShow == false){
            
            moveToSlide(SLIndex)
            
        }
        
        timer=NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(timeToShow), target: self, selector: "timesUp", userInfo: nil, repeats: false)
        
        if (selectedSlideShow == false){
            
            SLIndex++;
            
            if (unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider|settings|WebHomeSlider|slides") == nil){
                SLIndex=0
                
            }
            else if (SLIndex>=(unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider|settings|WebHomeSlider|slides") as? NSArray)!.count){
                SLIndex=0
            }
        }
    }
    
    override func cellSelect(indexPath:NSIndexPath){
        
        var index=indexPath.row
        
        let totalItems=self.totalItemsInSection(0)
        index=indexPath.row-1+indexOffset
        
        if (totalItems>=4){
            while (index>totalItems-1){
                index = index-(totalItems)
            }
            while (index < -1){
                index = index+(totalItems)
            }
        }
        if (index == -1){
            index = totalItems-1
        }
        
        print("index: \(index)")
        
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        
        let videosData=unfold("\(pathForSliderData)|settings|WebHomeSlider|slides|\(index)")!.objectForKey("item")!.objectForKey("files") as? NSArray
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
    
    override func layoutForCellAtIndex(indexPath:NSIndexPath, withPreLayout:UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        /*
        Defines the position and size of the indivigual cell.
        */
        
        
        var positionIndex=indexPath.row
        
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            positionIndex=(self.numberOfItemsInSection(indexPath.section))-indexPath.row-1
        }
        
        let layoutAttribute=withPreLayout
        layoutAttribute.frame=CGRectMake((self.contentInset.left)+((layoutAttribute.frame.size.width)*(self.collectionViewLayout as! CollectionViewHorizontalFlowLayout).spacingPercentile)*CGFloat(positionIndex), ((self.frame.size.height)-(layoutAttribute.frame.size.height))/2, (layoutAttribute.frame.size.width), (layoutAttribute.frame.size.height))
        
        return layoutAttribute
    }
    
    override func centerPointFor(proposedContentOffset: CGPoint) -> CGPoint{
        
        
        let cellWidth=(self.delegate as! HomeController).collectionView(self, layout: self.collectionViewLayout, sizeForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)).width*(self.collectionViewLayout as! CollectionViewHorizontalFlowLayout).spacingPercentile
        
        let itemIndex=round((proposedContentOffset.x+((self.frame.size.width)-cellWidth)/2)/cellWidth)
        return CGPoint(x: itemIndex*(cellWidth)-((self.frame.size.width)-cellWidth)/2
            , y: 0)
        
    }
}