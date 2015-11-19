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
    
    override func prepare(){
        
        self.contentInset=UIEdgeInsetsMake(0, 60, 0, 60)
        
        /*fetch information on latest videos then reload the views*/
        
        let latestVideosPath=base+"/"+version+"/categories/"+languageCode+"/LatestVideos?detailed=1"
        print("[Latest] loading...")
        addBranchListener(latestVideosPath, serverBonded: {
            dispatch_async(dispatch_get_main_queue()) {
                self.label.text=unfold("\(latestVideosPath)|category|name")! as? String
                if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
                    self.label.textAlignment=NSTextAlignment.Right
                }
                else {
                    self.label.textAlignment=NSTextAlignment.Left
                }
                print("[Latest] downloaded")
                unfold(latestVideosPath)
                self.reloadData()
                /*well everything is downloaded now so lets hide the spinning wheel and start rendering the views*/
            }
        })
        
    }
    override func totalItemsInSection(section: Int) -> Int {
        
        let latestVideosPath=base+"/"+version+"/categories/"+languageCode+"/LatestVideos?detailed=1|category|media"
        let videos:AnyObject?=unfold(latestVideosPath)
        if ((videos?.isKindOfClass(NSArray.self)) == true){
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
        if (imageURL != nil) {
            
            fetchDataUsingCache(imageURL!, downloaded: {
                
                dispatch_async(dispatch_get_main_queue()) {
                    let image=imageUsingCache(imageURL!)
                    
                    for subview in cell.contentView.subviews {
                        if (subview.isKindOfClass(UIImageView.self)){
                            (subview as! UIImageView).image=image
                            subview.userInteractionEnabled = true
                            (subview as! UIImageView).adjustsImageWhenAncestorFocused = true
                        }
                        if (subview.isKindOfClass(marqueeLabel.self)){
                            
                            
                            let titleLabel=(subview as! marqueeLabel)
                            //titleLabel.frame=CGRectMake(50, 150, 600, 100)
                            titleLabel.text=(videoData!.objectForKey("title") as? String)!
                            titleLabel.layer.shadowColor=UIColor.blackColor().CGColor
                            titleLabel.layer.shadowRadius=5
                            
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
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UILabel.self)){
                (subview as! UILabel).textColor=UIColor.whiteColor()
                (subview as! UILabel).shadowColor=UIColor.darkGrayColor()
                subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y+5, width: subview.frame.size.width, height: subview.frame.size.height)
            }
            /*
            
            This is code for marquee effect on labels. Currently this does not work.
            
            if (subview.isKindOfClass(marqueeLabel.self)){
                let titleLabel=(subview as! marqueeLabel)
                //titleLabel.unpauseLabel()
            }*/
        }
    }
    
    override func cellShouldLoseFocus(view:UIView, indexPath:NSIndexPath){
        
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UILabel.self)){
                (subview as! UILabel).textColor=UIColor.darkGrayColor()
                subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y-5, width: subview.frame.size.width, height: subview.frame.size.height)
            }
            /*
            
            This is code for marquee effect on labels. Currently this does not work.
            
            if (subview.isKindOfClass(marqueeLabel.self)){
                let titleLabel=(subview as! marqueeLabel)
                //titleLabel.shutdownLabel()
                //titleLabel.pauseLabel()
            }*/
        }
    }
    
    override func cellSelect(indexPath: NSIndexPath) {
        
        let latestVideosPath=base+"/"+version+"/categories/"+languageCode+"/LatestVideos?detailed=1|category|media"
        let videos=unfold(latestVideosPath)! as? NSArray
        
        let videoData:NSArray?=unfold(videos, instructions: ["\(indexPath.row)","files"]) as? NSArray
        
        let videoFile=videoData?.objectAtIndex((videoData?.count)!-1)
        
        let videoURLString=videoFile?.objectForKey("progressiveDownloadURL") as! String
        
        
        let videoURL = NSURL(string: videoURLString)
        let player = AVPlayer(URL: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.window?.rootViewController!.presentViewController(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}
