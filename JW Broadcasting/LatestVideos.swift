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
                (self.delegate as! HomeController).backgroundImageView.image=imageUsingCache(imageURL!)
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
    let playerViewController = AVPlayerViewController()
    
    override func cellSelect(indexPath: NSIndexPath) {
        
        let latestVideosPath=base+"/"+version+"/categories/"+languageCode+"/LatestVideos?detailed=1"
        let videoURLString=unfold("\(latestVideosPath)|category|media|\(indexPath.row)|files|last|progressiveDownloadURL")! as? String
        
        print((unfold("\(latestVideosPath)|category|media|\(indexPath.row)|primaryCategory") as! String))//primaryCategory
        
        
        let videoURL = NSURL(string: videoURLString!)
        let player = AVPlayer(URL: videoURL!)
        
        fetchDataUsingCache(base+"/"+version+"/categories/"+languageCode+"/\(unfold("\(latestVideosPath)|category|media|\(indexPath.row)|primaryCategory")!)?detailed=1", downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                
                print("downloaded")
                
                
                var itunesMetaData:Dictionary<String,protocol<NSCopying,NSObjectProtocol>>=[:]
                
                itunesMetaData[AVMetadataiTunesMetadataKeySongName]=unfold("\(latestVideosPath)|category|media|\(indexPath.row)|title") as? String
                itunesMetaData[AVMetadataiTunesMetadataKeyGenreID]="\(unfold(base+"/"+version+"/categories/"+languageCode+"/\(unfold("\(latestVideosPath)|category|media|\(indexPath.row)|primaryCategory")!)?detailed=1|category|name")!)"
                //itunesMetaData[AVMetadataiTunesMetadataKeyContentRating]="G"
                itunesMetaData[AVMetadataiTunesMetadataKeyDescription]="\nPublished by Watchtower Bible and Tract Society of New York, Inc.\n© 2016 Watch Tower Bible and Tract Society of Pennsylvania. All rights reserved."
                //unfold("\(latestVideosPath)|category|media|\(indexPath.row)|description") as? String
                itunesMetaData[AVMetadataiTunesMetadataKeyCopyright]="Copyright © 2016 Watch Tower Bible and Tract Society of Pennsylvania"
                itunesMetaData[AVMetadataiTunesMetadataKeyPublisher]="Watchtower Bible and Tract Society of New York, Inc."
                let imageURL=unfold("\(latestVideosPath)|category|media|\(indexPath.row)|images|lsr|md") as? String
                let image=UIImagePNGRepresentation(imageUsingCache(imageURL!)!)
                if (image != nil){ itunesMetaData[AVMetadataiTunesMetadataKeyCoverArt]=NSData(data: image!) }
                
                
                
                for key in NSDictionary(dictionary: itunesMetaData).allKeys {
                    
                    let metadataItem = AVMutableMetadataItem()
                    metadataItem.locale = NSLocale.currentLocale()
                    metadataItem.key = key as! String
                    metadataItem.keySpace = AVMetadataKeySpaceiTunes
                    metadataItem.value = itunesMetaData[key as! String]
                    player.currentItem!.externalMetadata.append(metadataItem)
                    
                }
            }
        })
        
        
        
        self.playerViewController.player = player
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        self.window?.rootViewController!.presentViewController(self.playerViewController, animated: true) {
            self.playerViewController.player!.play()
        }
        
        
        
        
    }
    
    func playerItemDidReachEnd(notification:NSNotification){
        playerViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
