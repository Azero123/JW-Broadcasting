//
//  ChannelSelector.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/14/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit
import AVKit

class ChannelSelector: SuperCollectionView {
    
    @IBOutlet weak var label:UILabel!

    override func prepare() {
        
        self.hidden=true
        self.label.superview!.hidden=true
        self.contentInset=UIEdgeInsetsMake(0, 60, 0, 0)
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480"
        print("[Channels] loading... \(streamingScheduleURL)")
        fetchDataUsingCache(streamingScheduleURL, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                self.label.text=unfold("\(streamingScheduleURL)|category|name")! as? String
                if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
                    self.label.textAlignment=NSTextAlignment.Right
                }
                else {
                    self.label.textAlignment=NSTextAlignment.Left
                }
                unfold(streamingScheduleURL)
                self.reloadData()
                print("[Channels] Reloaded")
                self.hidden=false
                self.label.superview!.hidden=false
            }
        })

    }
    
    override func totalItemsInSection(section: Int) -> Int {
        
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480"
        let channels:AnyObject?=unfold("\(streamingScheduleURL)|category|subcategories")
        if ((channels?.isKindOfClass(NSArray.self)) == true){
            return channels!.count
        }
        
        return 0
    }
    
    override func sizeOfItemAtIndex(indexPath:NSIndexPath) -> CGSize{
        
        let multiplier:CGFloat=1.5
        let ratio:CGFloat=1.875
        let width:CGFloat=320/2
        return CGSize(width: width*ratio*multiplier, height: width*multiplier+60)//450,300
    }
    
    
    override func cellAtIndex(indexPath:NSIndexPath) -> UICollectionViewCell{
        let channel: UICollectionViewCell = self.dequeueReusableCellWithReuseIdentifier("channel", forIndexPath: indexPath)
        
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480"
        let channelsMeta=(unfold("\(streamingScheduleURL)|category|subcategories") as? NSArray)
        
        /*
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            channelsMeta=channelsMeta!.reverse()
        }*/
        
        let channelMeta=channelsMeta?[indexPath.row] as? NSDictionary
        if (channelMeta != nil){
            let imageURL=unfold(channelMeta, instructions: ["images","wss","sm"]) as? String
            for subview in channel.contentView.subviews {
                if (subview.isKindOfClass(UIImageView.self)){
                    let imageView=(subview as! UIImageView)
                    imageView.userInteractionEnabled = true
                    //imageView.adjustsImageWhenAncestorFocused = true
                    
                    if (imageURL != nil){
                        fetchDataUsingCache(imageURL!, downloaded: {
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                imageView.image=imageUsingCache(imageURL!)
                                imageView.userInteractionEnabled=true
                                //imageView.adjustsImageWhenAncestorFocused = true
                                //channel.contentView.addSubview(imageView)
                            }
                        })
                    }
                }
                if (subview.isKindOfClass(UILabel.self)){
                    let titleLabel=subview as! UILabel
                    titleLabel.layer.zPosition=100000
                }
                if (subview.isKindOfClass(marqueeLabel.self)){
                    let titleLabel=subview as! marqueeLabel
                    titleLabel.text=channelMeta!.objectForKey("name") as? String
                    
                }
            }

        }
        
        
        return channel
    }
    
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    var currentURL:String?
    var playerItem:AVPlayerItem?
    var timerForPreview:NSTimer?
    
    override func cellShouldFocus(view:UIView, indexPath:NSIndexPath){
    
        view.subviews.first?.alpha=1
        timerForPreview?.invalidate()
        timerForPreview=nil
        timerForPreview=NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("bringUpPreview:"), userInfo: ["view":view,"indexPath":indexPath], repeats: false)
        
        self.currentURL=""
        readyTimer?.invalidate()
        readyTimer=nil
        
        player?.muted=true
        if (player == nil){
            player = AVPlayer()
        }
        if (playerLayer == nil){
            playerLayer=AVPlayerLayer(player: player)
        }
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UILabel.self)){
                (subview as! UILabel).textColor=UIColor.whiteColor()
                (subview as! UILabel).shadowColor=UIColor.darkGrayColor()
                subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y+5, width: subview.frame.size.width, height: subview.frame.size.height)
            }
            if (subview.isKindOfClass(UIImageView.self)){
                subview.clipsToBounds=true
                let scaleUp=subview.frame.size.width/398
                playerLayer!.frame=CGRect(x: -29, y: -13, width: subview.frame.size.width*scaleUp, height: subview.frame.size.height*scaleUp)
                subview.layer.addSublayer(self.playerLayer!)
            }
            
        }
        
        UIView.animateWithDuration(0.2, animations: {
            
            view.transform = CGAffineTransformMakeScale(1.1, 1.1)
            
            view.layer.shadowColor=UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5).CGColor
            view.layer.shadowOffset=CGSize(width: 0, height: 20)
            view.layer.shadowRadius=30
            view.layer.shadowOpacity=1.0
            }, completion: nil)

    }
    
    func bringUpPreview(timer:NSTimer){
        bringUpPreview(timer.userInfo!["view"] as! UIView, indexPath: timer.userInfo!["indexPath"] as! NSIndexPath)
    }
    
    func bringUpPreview(view:UIView, indexPath:NSIndexPath){
        
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480"
        fetchDataUsingCache(streamingScheduleURL, downloaded: {
            
            let streamMeta=unfold(streamingScheduleURL)//dictionaryOfPath(streamingScheduleURL, usingCache: true)
            
                
                let subcategory=streamMeta?.objectForKey("category")?.objectForKey("subcategories")!.objectAtIndex(indexPath.row)
                let playlist=subcategory!["media"] as! NSArray
                let newVidData=playlist[0]["files"]
                let videoURL=newVidData!![0]["progressiveDownloadURL"]
                let timeIndex=subcategory!["position"]?!["time"]?!.floatValue
                if (videoURL as? String != self.currentURL){
                    self.currentURL=videoURL as? String
                    //self.player?.replaceCurrentItemWithPlayerItem()
                    self.playerItem=AVPlayerItem(URL: NSURL(string: videoURL as! String)!)
                    //NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player?.currentItem)
                    // self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
                }
                if (self.player != nil){
                    if ((self.player?.currentTime().value)!-CMTimeMake(Int64(timeIndex!), 1).value < abs(10)){
                        self.playerItem?.seekToTime(CMTimeMake(Int64(timeIndex!), 1))
                    }
                    else {
                        
                    }
                }
                self.update()
            
            
            }, usingCache: false)
    }
    
    var readyTimer:NSTimer?=nil
    
    override func cellShouldLoseFocus(view:UIView, indexPath:NSIndexPath){
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UILabel.self)){
                (subview as! UILabel).textColor=UIColor.darkGrayColor()
                subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y-5, width: subview.frame.size.width, height: subview.frame.size.height)
            }
            /*
            if (subview.isKindOfClass(marqueeLabel.self)){
            let titleLabel=(subview as! marqueeLabel)
            //titleLabel.shutdownLabel()
            //titleLabel.pauseLabel()
            }*/
        }
        player?.replaceCurrentItemWithPlayerItem(nil)
        self.playerLayer?.removeFromSuperlayer()
        self.player?.pause()
        
        UIView.animateWithDuration(0.2, animations: {
            
            view.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
        
        view.layer.shadowOpacity=0.0
    }
    
    override func cellSelect(indexPath:NSIndexPath){
        if ((self.delegate?.isKindOfClass(HomeController)) == true){
            (self.delegate as! HomeController).goToStreamID=indexPath.row
            (self.delegate as! HomeController).performSegueWithIdentifier("presentStreaming", sender: self)
        }

        self.playerLayer?.removeFromSuperlayer()
        self.player?.pause()
    }
    
    
    func update(){
        
        dispatch_async(dispatch_get_main_queue()) {
            self.player?.muted=true
        if ((self.playerItem!.asset as! AVURLAsset).URL.absoluteString == self.currentURL){
            self.player?.replaceCurrentItemWithPlayerItem(self.playerItem)
        }
        if ((self.player) != nil && self.playerItem!.status == AVPlayerItemStatus.ReadyToPlay ){
            self.player?.play()
        }
        else if (self.playerLayer?.superlayer != nil){
            self.readyTimer=NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update"), userInfo: nil, repeats: false)
        }
        }
    }
}
