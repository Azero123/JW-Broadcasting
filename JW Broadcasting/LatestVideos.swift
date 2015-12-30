//
//  LatestVideos.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/14/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit
import AVKit

class LatestVideos: SuperCollectionView {
    
    @IBOutlet weak var label:UILabel!
    let player=SuperMediaPlayer()
    
    override func prepare(){
        
        self.contentInset=UIEdgeInsetsMake(0, 60, 0, 60)
        
        /*fetch information on latest videos then reload the views*/
        
        (self.delegate as? HomeController)?.addActivity()
        let latestVideosPath=base+"/"+version+"/categories/"+languageCode+"/LatestVideos?detailed=1"
        print("[Latest] loading...")
        fetchDataUsingCache(latestVideosPath, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
            if (unfold("\(latestVideosPath)|category|name") != nil){
                self.label.text=unfold("\(latestVideosPath)|category|name")! as? String
            }
            if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
                self.label.textAlignment=NSTextAlignment.Right
            }
            else {
                self.label.textAlignment=NSTextAlignment.Left
            }
            print("[Latest] Loaded")
                //unfold(latestVideosPath)
                self.reloadData()
                
                
                self.performBatchUpdates({
                    }, completion: { (finished:Bool) in
                        if (finished){
                            
                            if (textDirection == .RightToLeft){
                                self.contentOffset=self.centerPointFor(CGPointMake(self.contentSize.width-self.frame.size.width+self.contentInset.right, 0))
                            }
                            else {
                                self.contentOffset=CGPointMake(-self.contentInset.left, 0)
                            }
                        }
                })
                
            (self.delegate as? HomeController)?.removeActivity()
            /*well everything is downloaded now so lets hide the spinning wheel and start rendering the views*/
            }
        })
        
    }
    override func totalItemsInSection(section: Int) -> Int {
        
        let latestVideosPath=base+"/"+version+"/categories/"+languageCode+"/LatestVideos?detailed=1|category|media"
        let videos:AnyObject?=unfold(latestVideosPath)
        if ((videos?.isKindOfClass(NSArray.self)) == true){
            print("[INCOMPLETION] no latest videos")
            return videos!.count
        }
        return 0
    }
    
    override func sizeOfItemAtIndex(indexPath:NSIndexPath) -> CGSize{
        
        return CGSize(width: 560/1.05, height: 360/1.05)//588,378
    }
    
    override func cellAtIndex(indexPath:NSIndexPath) -> UICollectionViewCell{
        
        let cell: UICollectionViewCell = self.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)

        for subview in cell.contentView.subviews {
            if (subview.isKindOfClass(UIImageView.self)){
                (subview as! UIImageView).image=UIImage()
            }
        }
        
        let latestVideosPath=base+"/"+version+"/categories/"+languageCode+"/LatestVideos?detailed=1"
        
        let videosData:NSArray?=unfold("\(latestVideosPath)|category|media") as? NSArray
        /*
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            videosData=videosData!.reverse()
        }*/
        
        let videoData=videosData![indexPath.row] as? NSDictionary
        let imageURL=unfold(videoData, instructions: ["images","lsr","md"]) as? String
        if (imageURL != nil && imageURL != "") {
            
            fetchDataUsingCache(imageURL!, downloaded: {
                
                dispatch_async(dispatch_get_main_queue()) {
                    let image=imageUsingCache(imageURL!)
                    
                    for subview in cell.contentView.subviews {
                        if (subview.isKindOfClass(UIImageView.self)){
                            (subview as! UIImageView).image=image
                            subview.userInteractionEnabled = true
                            (subview as! UIImageView).adjustsImageWhenAncestorFocused = true
                        }
                        if (subview.isKindOfClass(UILabel.self)){
                            
                            
                            let titleLabel=(subview as! UILabel)
                            titleLabel.text=(videoData!.objectForKey("title") as? String)!
                            titleLabel.layer.shadowColor=UIColor.blackColor().CGColor
                            titleLabel.layer.shadowRadius=5
                            titleLabel.frame=CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, titleLabel.frame.size.width, titleLabel.frame.size.height)
                        }
                        if (subview.isKindOfClass(marqueeLabel.self)){
                            
                            (subview as! marqueeLabel).fadeLength=15
                            (subview as! marqueeLabel).fadePadding = 30
                            (subview as! marqueeLabel).fadePaddingWhenFull = -5
                            (subview as! marqueeLabel).textSideOffset=15
                        }
                    }
                }
            })
        }
        
        return cell
    }
    
    var selectedSlideShow=false
    
    override func cellShouldFocus(view:UIView, indexPath:NSIndexPath){
        
        view.subviews.first?.alpha=1
        
        
        let latestVideosPath=base+"/"+version+"/categories/"+languageCode+"/LatestVideos?detailed=1"
        
        let videosData:NSArray?=unfold("\(latestVideosPath)|category|media") as? NSArray
        
        let videoData=videosData![indexPath.row] as? NSDictionary
        let imageURL=unfold(videoData, instructions: ["images","lsr","md"]) as? String
        if (imageURL != nil){
            if ((self.delegate?.isKindOfClass(HomeController.self)) == true){
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                    if (view==UIScreen.mainScreen().focusedView){
                        UIView.transitionWithView((self.delegate as! HomeController).backgroundImageView, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                            (self.delegate as! HomeController).backgroundImageView.image=imageUsingCache(imageURL!)
                            }, completion: nil)
                    }
                }
            }
        }
        
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UILabel.self)){
                (subview as! UILabel).textColor=UIColor.whiteColor()
                (subview as! UILabel).shadowColor=UIColor.darkGrayColor()
                subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y+5, width: subview.frame.size.width, height: subview.frame.size.height)
            }
            if (subview.isKindOfClass(marqueeLabel.self)){
                (subview as! marqueeLabel).beginFocus()
                subview.layoutIfNeeded()
            }
        }
    }
    
    override func cellShouldLoseFocus(view:UIView, indexPath:NSIndexPath){
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UILabel.self)){
                (subview as! UILabel).textColor=UIColor.darkGrayColor()
                subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y-5, width: subview.frame.size.width, height: subview.frame.size.height)
            }
            if (subview.isKindOfClass(marqueeLabel.self)){
                (subview as! marqueeLabel).endFocus()
            }
        }
    }
    
    override func cellSelect(indexPath: NSIndexPath) {
        
        let latestVideosPath=base+"/"+version+"/categories/"+languageCode+"/LatestVideos?detailed=1"
        let dict=unfold("\(latestVideosPath)|category|media|\(indexPath.row)") as! NSDictionary
        player.updatePlayerUsingDictionary(dict)
        player.playIn(self.delegate as! HomeController)
        
        
    }
}
