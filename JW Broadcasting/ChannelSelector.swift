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
        
        (self.delegate as? HomeController)?.addActivity()
        
        self.contentInset=UIEdgeInsetsMake(0, 60, 0, 60)
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480"
        print("[Channels] loading...")
        fetchDataUsingCache(streamingScheduleURL, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                if (unfold("\(streamingScheduleURL)|category|name") != nil){
                    self.label.text=unfold("\(streamingScheduleURL)|category|name")! as? String
                }
                if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
                    self.label.textAlignment=NSTextAlignment.Right
                }
                else {
                    self.label.textAlignment=NSTextAlignment.Left
                }
                //unfold(streamingScheduleURL)
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
                
                //self.scrollToItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
                /*
                
                Code experiementation for RTL.
                
                if (textDirection == .RightToLeft){
                    self.scrollToItemAtIndexPath(NSIndexPath(forRow: self.totalItemsInSection(0)-1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
                }
                else {
                    //self.tabBarController!.selectedIndex=0
                }*/
                print("[Channels] Loaded")
                (self.delegate as? HomeController)?.removeActivity()
            }
        })

    }
    
    override func totalItemsInSection(section: Int) -> Int {
        
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480"
        let channels:AnyObject?=unfold("\(streamingScheduleURL)|category|subcategories")
        if ((channels?.isKindOfClass(NSArray.self)) == true){
            print("[INCOMPLETION] no channels")
            return channels!.count
        }
        return 0
    }
    
    override func sizeOfItemAtIndex(indexPath:NSIndexPath) -> CGSize{
        
        let multiplier:CGFloat=1.5
        let ratio:CGFloat=1.7777777777777
        let width:CGFloat=320/2
        
        return CGSize(width: width*ratio*multiplier, height: width*multiplier+60)//wss lg 640,360
    }
    
    
    override func cellAtIndex(indexPath:NSIndexPath) -> UICollectionViewCell{
        let channel: UICollectionViewCell = self.dequeueReusableCellWithReuseIdentifier("channel", forIndexPath: indexPath)
        channel.tag=indexPath.row
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480"
        let channelsMeta=(unfold("\(streamingScheduleURL)|category|subcategories") as? NSArray)

        
        let channelMeta=channelsMeta?[indexPath.row] as? NSDictionary
        if (channelMeta != nil){
            //For some reason medium image sizes are smaller than small?!?
            let imageURL=unfold(channelMeta, instructions: ["images","wss",["lg","sm","md"]]) as? String
            for subview in channel.contentView.subviews {
                if (subview.isKindOfClass(UIImageView.self)){
                    let imageView=(subview as! UIImageView)
                    imageView.userInteractionEnabled = true
                    //imageView.adjustsImageWhenAncestorFocused = true
                    
                    if (imageURL != nil){
                        fetchDataUsingCache(imageURL!, downloaded: {
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                if (channel.tag==indexPath.row){
                                    imageView.image=imageUsingCache(imageURL!)
                                    imageView.userInteractionEnabled=true
                                }
                            }
                        })
                    }
                }
                if (subview.isKindOfClass(UILabel.self)){
                    let titleLabel=subview as! UILabel
                    titleLabel.layer.zPosition=100000
                    titleLabel.text=channelMeta!.objectForKey("name") as? String
                }
            }

        }
        
        
        return channel
    }
    var timerForPreview:NSTimer?
    
    override func cellShouldFocus(view:UIView, indexPath:NSIndexPath){
        
        disableNavBar=true
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480"
        let channelsMeta=(unfold("\(streamingScheduleURL)|category|subcategories") as? NSArray)
        
        let channelMeta=channelsMeta?[indexPath.row] as? NSDictionary
        let imageURL=unfold(channelMeta, instructions: ["images","wss","sm"]) as? String
        let image=imageUsingCache(imageURL!)
        if (channelMeta != nil){
            if ((self.delegate?.isKindOfClass(HomeController.self)) == true){
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                    if (view==UIScreen.mainScreen().focusedView){
                        UIView.transitionWithView((self.delegate as! HomeController).backgroundImageView, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                            (self.delegate as! HomeController).backgroundImageView.image=image
                            }, completion: nil)
                    }
                }
            }
        }
        
        view.subviews.first?.alpha=1
        timerForPreview?.invalidate()
        timerForPreview=nil
        timerForPreview=NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("bringUpPreview:"), userInfo: ["view":view,"indexPath":indexPath], repeats: false)
        
        
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
        
        UIView.animateWithDuration(0.2, animations: {
            
            view.transform = CGAffineTransformMakeScale(1.1, 1.1)
            
            view.layer.shadowColor=UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5).CGColor
            view.layer.shadowOffset=CGSize(width: 0, height: 20)
            view.layer.shadowRadius=30
            view.layer.shadowOpacity=1.0
            }, completion: nil)

    }
    
    func bringUpPreview(timer:NSTimer){
        if (timer.userInfo!["view"] as? UIView == UIScreen.mainScreen().focusedView){
            bringUpPreview(timer.userInfo!["view"] as! UIView, indexPath: timer.userInfo!["indexPath"] as! NSIndexPath)
        }
    }
    
    var streamview:StreamView?=nil
    func bringUpPreview(view:UIView, indexPath:NSIndexPath){
        if (streamview == nil){
            streamview=StreamView()
        }
        if (streamview!.superview != nil){
            streamview?.player?.removeAllItems()
            for item in streamview!.player!.items() {
                item.asset.cancelLoading()
            }
            streamview!.removeFromSuperview()
        }
        
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480"
        let channelsMeta=(unfold("\(streamingScheduleURL)|category|subcategories") as? NSArray)
        
        let channelMeta=channelsMeta?[indexPath.row] as? NSDictionary
        let imageURL=unfold(channelMeta, instructions: ["images","wss","sm"]) as? String
        let image=imageUsingCache(imageURL!)
        
        for subview in view.subviews.first!.subviews {
            if (subview.isKindOfClass(UIImageView.self)){
                (subview as! UIImageView).image=nil
                streamview=StreamView(frame: CGRect(x: 0, y: 0, width: subview.bounds.size.width, height: subview.bounds.size.height))
                streamview!.image=image
            }
        }
        streamview!.streamID=indexPath.row
        /*
        //streamview.frame=CGRect(x: 0, y: 0, width: 860, height: 430)//(860.0, 430.0
        let width:CGFloat=2
        let height:CGFloat=1
        var ratio:CGFloat=width/height
        //streamview.frame=CGRect(x: (view.frame.size.width-((view.frame.size.height-60)*ratio))/2, y: 0, width: (view.frame.size.height-60)*ratio, height: (view.frame.size.height-60))
        
        if (width>height){
            ratio=height/width
            //streamview.frame=CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width*ratio)
        }
        */
        
        //print("image size: \(image!.size) \(imageURL)")
        //let sizeOfStream=CGSize(width: , height: <#T##Double#>)
        
        //streamview.frame=CGRect(x: (view.frame.size.width-streamview.frame.size.width)/2, y: (view.frame.size.height-streamview.frame.size.height)/2, width: streamview.frame.size.width, height: streamview.frame.size.height)
        
        view.subviews.first!.addSubview(streamview!)
        
    }
    
    var readyTimer:NSTimer?=nil
    
    override func cellShouldLoseFocus(view:UIView, indexPath:NSIndexPath){
        
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480"
        let channelsMeta=(unfold("\(streamingScheduleURL)|category|subcategories") as? NSArray)
        
        let channelMeta=channelsMeta?[indexPath.row] as? NSDictionary
        let imageURL=unfold(channelMeta, instructions: ["images","wss","sm"]) as? String
        let image=imageUsingCache(imageURL!)
        
        if (streamview != nil && streamview!.superview != nil){
            
            streamview?.player?.removeAllItems()
            if (streamview?.player != nil){
                for item in streamview!.player!.items() {
                    item.asset.cancelLoading()
                }
            }
            streamview!.removeFromSuperview()
            //streamview.playerLayer?.removeFromSuperlayer()
        }
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UILabel.self)){
                (subview as! UILabel).textColor=UIColor.darkGrayColor()
                subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y-5, width: subview.frame.size.width, height: subview.frame.size.height)
            }
            if (subview.isKindOfClass(marqueeLabel.self)){
                (subview as! marqueeLabel).endFocus()
            }
            if (subview.isKindOfClass(UIImageView.self)){
                subview.clipsToBounds=true
                (subview as! UIImageView).image=image
            }
            if (subview.isKindOfClass(StreamView.self)){
                (subview as! StreamView).image=nil
            }
        }
        
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

    }
    
    
}
