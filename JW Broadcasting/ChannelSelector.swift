//
//  ChannelSelector.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/14/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class ChannelSelector: SuperCollectionView {

    override func prepare() {
        
        self.contentInset=UIEdgeInsetsMake(0, 60, 0, 0)
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480"
        print("[Channels] loading... \(streamingScheduleURL)")
        fetchDataUsingCache(streamingScheduleURL, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                unfold(streamingScheduleURL)
                self.reloadData()
                print("[Channels] Reloaded")
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
        let channelMeta=unfold("\(streamingScheduleURL)|category|subcategories|\(indexPath.row)")
        if (channelMeta != nil){
            let imageURL=unfold(channelMeta, instructions: ["images","wss","sm"]) as? String
            
            for subview in channel.contentView.subviews {
                if (subview.isKindOfClass(UIImageView.self)){
                    let imageView=(subview as! UIImageView)
                    imageView.userInteractionEnabled = true
                    imageView.adjustsImageWhenAncestorFocused = true
                    
                    if (imageURL != nil){
                        fetchDataUsingCache(imageURL!, downloaded: {
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                imageView.image=imageUsingCache(imageURL!)
                                imageView.userInteractionEnabled=true
                                imageView.adjustsImageWhenAncestorFocused = true
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
    
    
    override func cellShouldFocus(view:UIView, indexPath:NSIndexPath){
        
        view.subviews.first?.alpha=1
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UILabel.self)){
                (subview as! UILabel).textColor=UIColor.whiteColor()
                (subview as! UILabel).shadowColor=UIColor.darkGrayColor()
                subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y+5, width: subview.frame.size.width, height: subview.frame.size.height)
            }
            /*
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
            if (subview.isKindOfClass(marqueeLabel.self)){
            let titleLabel=(subview as! marqueeLabel)
            //titleLabel.shutdownLabel()
            //titleLabel.pauseLabel()
            }*/
        }
    }
    
    override func cellSelect(indexPath:NSIndexPath){
        if ((self.delegate?.isKindOfClass(HomeController)) == true){
            (self.delegate as! HomeController).goToStreamID=indexPath.row
            (self.delegate as! HomeController).performSegueWithIdentifier("presentStreaming", sender: self)
        }
    }
}
