//
//  SlideShow.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/13/15.
//  Copyright © 2015 xquared. All rights reserved.
//

let infiniteScrolling=false

import Foundation
import UIKit
import AVKit

class SlideShow: SuperCollectionView {
    
    var timer:NSTimer?
    var SLIndex=0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        /*
        Initial call for moving featured videos.
        */
        
        if (HomeFeaturedSlide){
            self.performSelector("timesUp", withObject: nil, afterDelay: NSTimeInterval(timeToShow))
        }
    }
    
    var focusReady=false
    
    override func prepare(){
        /*
        Sets edge margins to meet Apple's requirements.
        Downloads information on Featured videos.
        Aligns items properly for LTR or RTL.
        Ler's Home page know that this section is done loading.
        
        */
        
        
        let guide=UIFocusGuide()
        guide.preferredFocusedView=self
        self.addLayoutGuide(guide)
        guide.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor, constant: 0).active=true
        guide.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: 0).active=true
        guide.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: 300).active=true
        guide.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor, constant: 0).active=true
        
        focusReady=false
        (self.delegate as? HomeController)?.addActivity()//Tells home to prevent interaction
        
        self.contentInset=UIEdgeInsetsMake(0, 60, 0, 60)//Edge insets
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        
        print("[SlideShow] loading...")
        fetchDataUsingCache(pathForSliderData, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                print("[SlideShow] Loaded")
                
                
                
                //self.moveToSlide(1)
                
                if (textDirection == .RightToLeft){//RTL alignment
                    self.contentOffset=self.centerPointFor(CGPointMake(self.contentSize.width-self.frame.size.width+self.contentInset.right, 0))
                }
                else {//LTR alignment
                    //self.contentOffset=CGPointMake(-self.contentInset.left, 0)
                    let size=self.sizeOfItemAtIndex(NSIndexPath(forRow: 0, inSection: 0))
                    self.contentOffset=self.centerPointFor(CGPoint(x: size.width*(self.totalItemsInSection(0)>4 ? 2 : 1) , y: size.height))
                }
                
                self.performBatchUpdates({
                    self.reloadSections(NSIndexSet(index: 0))
                    }, completion: { (finished:Bool) in
                        if (finished){
                            //self.moveToSlide(1)
                            self.reloadItemsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)])
                            
                            self.performSelector("setFocusReady", withObject: nil, afterDelay: 1)
                            
                        }
                
                })

                //reload content
                self.reloadData()
                
                //Enable interaction
                (self.delegate as? HomeController)?.removeActivity()
            }
        })
    }
    
    func setFocusReady(){
        focusReady=true
        
        self.updateFocusIfNeeded()
        self.setNeedsFocusUpdate()
    }
    
    override func totalItemsInSection(section: Int) -> Int {
        //sets the number of items based on how many featured videos are available.
        let slides=unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider|settings|WebHomeSlider|slides") as? NSArray
        if (slides == nil){//If the file isn't downloaded yet
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
        slide.tag=indexPath.row
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        
        var index=indexPath.row % (self.totalItemsInSection(0))
        if (infiniteScrolling){
        let totalItems=self.totalItemsInSection(0)
        index=indexPath.row-2+indexOffset
        while (index>totalItems-1){
            index = index-(totalItems)
        }
        while (index < 0){
            index = index+(totalItems)
        }
        //print("reloading index \(indexPath.row) as \(index)")
        
        if (index>totalItems-1){
        index=index-totalItems
        }
        }
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
                            
                            
                            if (slide.tag==indexPath.row){
                                let image=imageUsingCache(imageURL!)
                                imageView.image=image
                                imageView.userInteractionEnabled = true
                                imageView.adjustsImageWhenAncestorFocused = true
                                imageView.frame=CGRectMake(0, 0, slide.frame.size.width, slide.frame.size.height)
                            }
                            
                            
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
        
        /*
        Detects what direction the user is scrolling and calls code to move the cells.
        Code for background effects based on image.
        Code for focus effects and blocking automatic sliding.
        */
        
        disableNavBar=true
        
        /*
        Some math to calculate the actual video ID
        */
        SLIndex=indexPath.row
        
        var index=indexPath.row % (totalItemsInSection(0))
        
        let totalItems=self.totalItemsInSection(0)
        if (totalItems>=4 && infiniteScrolling){
            index=indexPath.row-2+indexOffset
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

        
        
        
        /*
        Grabs the image url and then sets the background to that image to show the nice effect.
        */
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        
        let SLSlides=unfold(pathForSliderData+"|settings|WebHomeSlider|slides") as? NSArray
        let SLSlide=SLSlides![index]
        let imageURL=unfold(SLSlide, instructions: ["item","images","pnr","lg"]) as? String
        if ((self.delegate?.isKindOfClass(HomeController.self)) == true){
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                if (view==UIScreen.mainScreen().focusedView){
                    UIView.transitionWithView((self.delegate as! HomeController).backgroundImageView, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                        (self.delegate as! HomeController).backgroundImageView.image=imageUsingCache(imageURL!)
                        }, completion: nil)
                }
            }
        }
        
        
        
        
        /*
        Loops items from front to back or back to front for infinite looping.
        */
        if (totalItems>=4 && infiniteScrolling){
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
        }
        
        
        SLIndex=indexPath.row
        
        
        /*
        Effects for text and focusing
        */
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(marqueeLabel.self)){
                (subview as! marqueeLabel).beginFocus()
                subview.layoutIfNeeded()
            }
        }
        selectedSlideShow=true
        
    }
    
    func loopItemFrom(indexToMove:Int, to indexToGoTo:Int){
        /*
        Infinite scrolling code
        Code for moving last or first item to opposite side side.
        */
        if (indexToMove<indexToGoTo){
            indexOffset++
            
        }
        if (indexToMove>indexToGoTo){
            indexOffset--
        }
        self.layer.speed=0
        
        self.performBatchUpdates({
            
            self.layer.speed=0
            
            //self.deleteItemsAtIndexPaths([NSIndexPath(forRow: indexToMove, inSection: 0)])
            //self.insertItemsAtIndexPaths([NSIndexPath(forRow: indexToGoTo, inSection: 0)])
            self.moveItemAtIndexPath(NSIndexPath(forRow: indexToMove, inSection: 0), toIndexPath: NSIndexPath(forRow: indexToGoTo, inSection: 0))
            self.layer.speed=0
            }, completion: nil)
        self.layer.speed=1
    }
    
    override func cellShouldLoseFocus(view:UIView, indexPath:NSIndexPath){
        /*
        Code for unfocus effects and unblocking automatic sliding.
        */
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UIImageView.self)){
                subview.frame=view.bounds
            }
            if (subview.isKindOfClass(marqueeLabel.self)){
                (subview as! marqueeLabel).endFocus()
            }
        }
        selectedSlideShow=false
    }
    
    func moveToSlide(var atIndex:Int){
        /*
        Code for moving the slides after checking to make sure the cell it's going to is loaded.
        */
        
        if (unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider") != nil ){
            
            if (self.cellForItemAtIndexPath(NSIndexPath(forRow: atIndex, inSection: 0)) != nil){
                
                
                let totalItems=self.totalItemsInSection(0)
                let leftIndex = 0
                let rightIndex = totalItems-1
                
                /*Infinite loop auto scrolling*/
                
                if (totalItems>3 && infiniteScrolling){
                    
                    while (atIndex>totalItems-3){
                        atIndex--
                        loopItemFrom(leftIndex, to: rightIndex)
                    }
                    while (atIndex<2){
                        atIndex++
                        loopItemFrom(rightIndex, to: leftIndex)
                    }
                }
                
            }
            self.scrollToItemAtIndexPath(NSIndexPath(forRow: atIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
            
            SLIndex=atIndex
        }
    }
    
    
    
    func timesUp(){
        
        /*
        Code for clocking slide show and only calling it if set on by control.swift.
        Also resets index to scroll to after the last slide.
        */
        
        if (selectedSlideShow == false){
            
            moveToSlide(SLIndex)
            
        }
        
        timer=NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(timeToShow), target: self, selector: "timesUp", userInfo: nil, repeats: false)
        
        if (selectedSlideShow == false){
            
            SLIndex++
            
            if (unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider|settings|WebHomeSlider|slides") == nil){
                SLIndex=0
                
            }
            else if (SLIndex>=(unfold(base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider|settings|WebHomeSlider|slides") as? NSArray)!.count){
                SLIndex=0
            }
        }
    }
    let player=SuperMediaPlayer()
    
    override func cellSelect(indexPath:NSIndexPath){
        /*
        This cell was chosen so play the video.
        */
        
        /*
        Some math to calculate the actual video ID
        */
        var index=indexPath.row
        
        let totalItems=self.totalItemsInSection(0)
        if (infiniteScrolling){
        index=indexPath.row-2+indexOffset
        
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
        }
            
        /*
        Grab the video url
        make sure it is real
        create avplayerviewcontroller.
        Play video.
        */
        
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        
        player.updatePlayerUsingDictionary(unfold("\(pathForSliderData)|settings|WebHomeSlider|slides|\(index)|item") as! NSDictionary)
        player.playIn(self.delegate as! HomeController)
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
        /*
        Sets teh point to scroll to for this collection view.
        */
        
        let cellWidth=(self.delegate as! HomeController).collectionView(self, layout: self.collectionViewLayout, sizeForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)).width*(self.collectionViewLayout as! CollectionViewHorizontalFlowLayout).spacingPercentile
        
        var itemIndex=round((proposedContentOffset.x+((self.frame.size.width)-cellWidth)/2)/cellWidth)
        if (isnan(itemIndex)){
            itemIndex=0
        }
        return CGPoint(x: itemIndex*(cellWidth)-((self.frame.size.width)-cellWidth)/2
            , y: 0)
        
    }
    
    
    }