//
//  test.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/21/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit
import AVKit

class SuperMediaPlayer: NSObject, UIGestureRecognizerDelegate {
    
    let playerViewController = AVPlayerViewController()
    let player=AVQueuePlayer()
    var statusObserver=false
    var dismissWhenFinished=true
    var nextDictionary:NSDictionary?=nil
    var finishedPlaying:()->Void = { () -> Void in
    }
    
    override init() {
        super.init()
        playerViewController.player=player
        
        
        /*NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(audioSessionInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
        */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioSessionInterrupted:", name: AVAudioSessionInterruptionNotification, object: nil)
        
        player.addPeriodicTimeObserverForInterval(CMTime(value: 1, timescale: 1), queue: nil, usingBlock: { (time:CMTime) in
            
            let playerAsset:AVAsset? = self.player.currentItem != nil ? self.player.currentItem!.asset : nil
            if (playerAsset != nil && playerAsset!.isKindOfClass(AVURLAsset.self)){
            if (NSUserDefaults.standardUserDefaults().objectForKey("saved-media-states") == nil){
                NSUserDefaults.standardUserDefaults().setObject(NSDictionary(), forKey: "saved-media-states")
                }
                //NSUserDefaults.standardUserDefaults().setObject(NSDictionary(), forKey: "saved-media-states")
                let updatedDictionary:NSMutableDictionary=(NSUserDefaults.standardUserDefaults().objectForKey("saved-media-states") as! NSDictionary).mutableCopy() as! NSMutableDictionary
                let seconds=Float(CMTimeGetSeconds(self.player.currentTime()))
                if (seconds>60*2.5 && Float(CMTimeGetSeconds(playerAsset!.duration))*Float(0.95)>seconds && CMTimeGetSeconds(playerAsset!.duration)>60*8){
                    updatedDictionary.setObject(NSNumber(float: seconds), forKey: (playerAsset as! AVURLAsset).URL.path!)
                    NSUserDefaults.standardUserDefaults().setObject(updatedDictionary, forKey: "saved-media-states")
                }
                else {
                    
                    updatedDictionary.removeObjectForKey((playerAsset as! AVURLAsset).URL.path!)
                    NSUserDefaults.standardUserDefaults().setObject(updatedDictionary, forKey: "saved-media-states")
                }
                
            }
        })
        
    }
    
    func audioSessionInterrupted(notification:NSNotification){
        print("interruption")
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceivePress press: UIPress) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func updatePlayerUsingDictionary(dictionary:NSDictionary){
        
        updatePlayerUsingString( unfold(dictionary, instructions: ["files","last","progressiveDownloadURL"]) as! String)
        updateMetaDataUsingDictionary(dictionary)
    }
    
    func updatePlayerUsingString(url:String){
        
        updatePlayerUsingURL(NSURL(string: url)!)
    }
    
    func updatePlayerUsingURL(url:NSURL){
        let newItem=AVPlayerItem(URL: url)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if (self.player.currentItem != nil){
            NSNotificationCenter.defaultCenter().removeObserver(self)
            NSNotificationCenter.defaultCenter().removeObserver(self.player.currentItem!)
            //print("replace item \(self.player.currentItem?.observationInfo)")
            if ("\(self.player.currentItem!.observationInfo)".containsString("(")){
                print("still here!")
                self.player.currentItem!.removeObserver(self, forKeyPath: "status")
            }
            
            print("replace item \(self.player.currentItem!.observationInfo)")
        }
        
        for item in player.items() {
            item.asset.cancelLoading()
            if ("\(item.observationInfo)".containsString("(")){
                print("still here!")
                item.removeObserver(self, forKeyPath: "status")
            }
        }
        
        player.removeAllItems()
        
        player.insertItem(newItem, afterItem: nil)
        //player.replaceCurrentItemWithPlayerItem(nil)
        statusObserver=true
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusChanged", name: "status", object: newItem)
        newItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.Prior, context: nil)
        //newItem.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.Prior, context: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: newItem)
        
    }
    
    func playerItemDidReachEnd(notification:NSNotification){
        print("did reach end \(notification.object) \(notification.object?.observationInfo!)")
        if ((notification.object?.isKindOfClass(AVPlayerItem)) == true){
            if (statusObserver){
                print("status observer")
                
                notification.object?.removeObserver(self, forKeyPath: "status")
                
            }
            while ("\(notification.object!.observationInfo)".containsString("(")){
                print("still here!")
                notification.object?.removeObserver(self, forKeyPath: "status")
            }
            statusObserver=false
            //NSNotificationCenter.removeObserver(self, forKeyPath: AVPlayerItemDidPlayToEndTimeNotification)
            //notification.object?.removeObserver(self, forKeyPath: AVPlayerItemDidPlayToEndTimeNotification)
            if (nextDictionary != nil){
                print("but we have more!")
                self.updatePlayerUsingDictionary(self.nextDictionary!)
            }
            else if (dismissWhenFinished){
                playerViewController.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        finishedPlaying()
        
        
    }
    
    func updateMetaDataUsingDictionary(dictionary:NSDictionary){
        
        
        fetchDataUsingCache(base+"/"+version+"/categories/"+languageCode+"/\(unfold(dictionary, instructions: ["primaryCategory"])!)?detailed=1", downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                
                self.updateMetaDataItem(AVMetadataiTunesMetadataKeyGenreID, keySpace: AVMetadataKeySpaceiTunes, value: "\(unfold(base+"/"+version+"/categories/"+languageCode+"/\(unfold(dictionary, instructions: ["primaryCategory"])!)?detailed=1|category|name")!)")
                
            }
        })
        
        
        var itunesMetaData:Dictionary<String,protocol<NSCopying,NSObjectProtocol>>=[:]
        
        itunesMetaData[AVMetadataiTunesMetadataKeySongName]=unfold(dictionary, instructions: ["title"]) as? String
        //itunesMetaData[AVMetadataiTunesMetadataKeyContentRating]="G"
        itunesMetaData[AVMetadataiTunesMetadataKeyDescription]="\nPublished by Watchtower Bible and Tract Society of New York, Inc.\n© 2016 Watch Tower Bible and Tract Society of Pennsylvania. All rights reserved."
        //unfold("\(latestVideosPath)|category|media|\(indexPath.row)|description") as? String
        itunesMetaData[AVMetadataiTunesMetadataKeyCopyright]="Copyright © 2016 Watch Tower Bible and Tract Society of Pennsylvania"
        itunesMetaData[AVMetadataiTunesMetadataKeyPublisher]="Watchtower Bible and Tract Society of New York, Inc."
        let imageURL=unfold(dictionary, instructions: ["images",["lsr","sqr","sqs","cvr",""],["sm","md","lg","xs",""]]) as? String
        if (imageURL != nil){
            let image=UIImagePNGRepresentation(imageUsingCache(imageURL!)!)
            if (image != nil){ itunesMetaData[AVMetadataiTunesMetadataKeyCoverArt]=NSData(data: image!) }
        }
        //unfold(dictionary, instructions: ["title","images","lsr","md"])
        
        
        for key in NSDictionary(dictionary: itunesMetaData).allKeys {
            
            updateMetaDataItem(key as! String, keySpace: AVMetadataKeySpaceiTunes, value: itunesMetaData[key as! String]!)
            
        }
        
        nextDictionary=dictionary
        
    }
    func updateMetaDataItem(key:String, keySpace:String, value:protocol<NSCopying,NSObjectProtocol>){
        
        if (player.currentItem == nil){
            print("player not ready!")
            return
        }
        
        let metadataItem = AVMutableMetadataItem()
        metadataItem.locale = NSLocale.currentLocale()
        metadataItem.key = key
        metadataItem.keySpace = keySpace
        metadataItem.value = value
        player.currentItem!.externalMetadata.append(metadataItem)
    }
    
    func play(){
        /*
        If return to within 30 Seconds than prompt for resume
        
        Had to be 5 min in or more
        Had to be less than 95 % through
        Video has to be longer than 10 minutes
        
        */

        playIn(UIApplication.sharedApplication().keyWindow!.rootViewController!)
    }
    
    func playIn(presenter:UIViewController){
        
        let playerAsset = self.player.currentItem!.asset
        if (playerAsset.isKindOfClass(AVURLAsset.self)){
            let urlPath=(playerAsset as! AVURLAsset).URL.path!
            if (NSUserDefaults.standardUserDefaults().objectForKey("saved-media-states") != nil && (NSUserDefaults.standardUserDefaults().objectForKey("saved-media-states") as! NSDictionary).objectForKey(urlPath) != nil){
                
                var seekPoint = CMTimeMake(0, 0)
                let seconds=(NSUserDefaults.standardUserDefaults().objectForKey("saved-media-states") as! NSDictionary).objectForKey(urlPath) as! NSNumber
                
                seekPoint=CMTimeMake(Int64(seconds.floatValue), 1)
                
                let fromBeginningText=unfold(base+"/"+version+"/translations/"+languageCode+"|translations|\(languageCode)|btnPlayFromBeginning") as? String
                let resumeText=unfold(base+"/"+version+"/translations/"+languageCode+"|translations|\(languageCode)|btnResume") as? String
                
                let alert=UIAlertController(title: "", message: "", preferredStyle: .Alert)
                alert.view.tintColor = UIColor.greenColor()
                
                alert.addAction(UIAlertAction(title: nil, style: .Cancel , handler: nil))
                
        
                let action=UIAlertAction(title: resumeText, style: .Default, handler: { (action:UIAlertAction) in
                    
                    self.playerViewController.player?.seekToTime(seekPoint)
                    if (self.player.currentItem == nil && self.nextDictionary != nil){
                        self.updatePlayerUsingDictionary(self.nextDictionary!)
                    }
                    presenter.presentViewController(self.playerViewController, animated: true) {
                        self.playerViewController.player!.play()
                    }
                })
                alert.addAction(action)
                alert.addAction(UIAlertAction(title: fromBeginningText, style: .Default, handler: { (action:UIAlertAction) in
                    if (self.player.currentItem == nil && self.nextDictionary != nil){
                        self.updatePlayerUsingDictionary(self.nextDictionary!)
                    }
                    
                    presenter.presentViewController(self.playerViewController, animated: true) {
                        self.playerViewController.player!.play()
                    }
                }))
                presenter.presentViewController(alert, animated: true, completion: nil)
            }
            if (self.player.currentItem == nil && self.nextDictionary != nil){
                self.updatePlayerUsingDictionary(self.nextDictionary!)
            }
            
            presenter.presentViewController(self.playerViewController, animated: true) {
                self.playerViewController.player!.play()
            }
            
        }
        else {
            
            if (self.player.currentItem == nil && self.nextDictionary != nil){
                self.updatePlayerUsingDictionary(self.nextDictionary!)
            }
            
            presenter.presentViewController(self.playerViewController, animated: true) {
                self.playerViewController.player!.play()
            }
        }

        
    }
    
    func exitPlayer(){
        
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (object != nil && object?.isKindOfClass(AVPlayerItem.self)==true && (object as! AVPlayerItem) == player.currentItem && keyPath! == "status"){
            object?.removeObserver(self, forKeyPath: "status")
            statusObserver=false
            //https://www.jw.org/apps/E_RSSMEDIAMAG?rln=E&rmn=wp&rfm=m4b
            if (player.status == .ReadyToPlay){
                var isAudio = false
                
                for track in (player.currentItem!.tracks) {
                    if (track.assetTrack.mediaType == AVMediaTypeAudio){
                        isAudio=true
                    }
                    if (track.assetTrack.mediaType == AVMediaTypeVideo){
                        isAudio=false
                        break
                    }
                }
                
                if (isAudio){
                    if (nextDictionary != nil && playerViewController.contentOverlayView != nil){
                        fillEmptyVideoSpaceWithDictionary(nextDictionary!)
                        self.nextDictionary=nil
                    }
                    else {
                        print("wanted to fill but couldn't")
                    }
                    
                }
                else {
                    self.nextDictionary=nil
                }
            }
        }
        
    }
    
    func fillEmptyVideoSpaceWithDictionary(dictionary:NSDictionary){
        let imageURL=unfold(dictionary, instructions: ["images",["sqr","sqs","cvr",""],["TVOS","lg","sm","md","xs",""]]) as? String
        for subview in (self.playerViewController.contentOverlayView?.subviews)! {
            subview.removeFromSuperview()
        }
        
        var image:UIImage?=nil
        let imageView=UIImageView()
        let backgroundImage=UIImageView()
        
        if ((unfold(dictionary, instructions: ["primaryCategory"]) as! String) == "KingdomMelodies"){
            image = UIImage(named: "kingdommelodies.png")
            //imageView.image=image
            //backgroundImage.image=image
        }
        
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if (image == nil){
                image=imageUsingCache(imageURL!)
            }
            dispatch_async(dispatch_get_main_queue()) {
                
                if (image != nil){
                    imageView.image=image
                    imageView.frame=CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height)
                    if (imageView.frame.width>imageView.frame.height){
                        if (imageView.frame.width>270){
                            let scaleDown=imageView.frame.size.width/270
                            imageView.frame=CGRect(x: 0, y: 0, width: imageView.frame.width/scaleDown, height: imageView.frame.height/scaleDown)
                        }
                    }
                    else {
                        if (imageView.frame.height>270){
                            let scaleDown=imageView.frame.size.height/270
                            imageView.frame=CGRect(x: 0, y: 0, width: imageView.frame.width/scaleDown, height: imageView.frame.height/scaleDown)
                        }
                    }
                    backgroundImage.image=image
                    imageView.center=CGPoint(x: (self.playerViewController.contentOverlayView?.frame.size.width)!/2, y: 705-imageView.frame.size.height/2-150)
                }
                
                
                var title=unfold(dictionary, instructions: ["title"]) as? String
                let extraction=titleExtractor(title!)
                
                var visualSongNumber:Int?=nil
                if ((title?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))>3){
                    visualSongNumber=Int(title!.substringToIndex(title!.startIndex.advancedBy(3)))
                }
                title=extraction["correctedTitle"]
                
                let scripturesLabel=UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 100))
                scripturesLabel.center=CGPoint(x: imageView.center.x, y: 845)
                scripturesLabel.textAlignment = .Center
                scripturesLabel.font=UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
                scripturesLabel.text=extraction["parentheses"]
                
                self.playerViewController.contentOverlayView?.addSubview(scripturesLabel)
                
                
                
                
                let label=UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 100))
                if (languageCode == "E" && ((unfold(dictionary, instructions: ["primaryCategory"]) as! String) == "Piano" || (unfold(dictionary, instructions: ["primaryCategory"]) as! String) == "Vocal" || (unfold(dictionary, instructions: ["primaryCategory"]) as! String) == "NewSongs")){
                    label.text="Song \(visualSongNumber!): \(title!)"
                }
                else {
                    label.text=(title!)
                }
                
                
                //imageView.center.y+imageView.frame.size.height/2+90
                label.center=CGPoint(x: imageView.center.x, y: 700)
                label.textAlignment = .Center
                label.font=UIFont.preferredFontForTextStyle(UIFontTextStyleTitle2)
                label.clipsToBounds=false
                //title 3
                self.playerViewController.contentOverlayView?.addSubview(label)
                
                
                
                let category="Audio"
                let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
                let AudioDataURL=categoriesDirectory+"/"+category+"?detailed=1"
                
                var albumTitle=""
                
                let albumKey=unfold(dictionary, instructions: ["primaryCategory"]) as! String
                let albums=unfold("\(AudioDataURL)|category|subcategories") as! NSArray
                for album in albums {
                    if (album["key"] as! String == albumKey){
                        albumTitle=album["name"] as! String
                    }
                }
                
                //let albumTitle=unfold("\(AudioDataURL)|category|subcategories|\(self.categoryIndex)|name") as! String
                
                
                let Albumlabel=UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 100))
                Albumlabel.text=categoryTitleCorrection(albumTitle)
                Albumlabel.center=CGPoint(x: imageView.center.x, y: 775)
                Albumlabel.textAlignment = .Center
                Albumlabel.font=UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
                Albumlabel.clipsToBounds=false
                Albumlabel.textColor=UIColor.darkGrayColor()
                //title 3
                self.playerViewController.contentOverlayView?.addSubview(Albumlabel)
            }
            
        }
        
        
        self.playerViewController.view.backgroundColor=UIColor.clearColor()
        self.playerViewController.contentOverlayView?.backgroundColor=UIColor.clearColor()
        
        let subviews=NSMutableArray(array: (self.playerViewController.view.subviews))
        
        while subviews.count>0{
            let subview=subviews.firstObject as! UIView
            subviews.addObjectsFromArray(subview.subviews)
            subview.backgroundColor=UIColor.clearColor()
            subviews.removeObjectAtIndex(0)
            
        }
        
        imageView.layer.shadowColor=UIColor.blackColor().CGColor
        imageView.layer.shadowOpacity=0.5
        imageView.layer.shadowRadius=20
        
        
        backgroundImage.frame=(self.playerViewController.contentOverlayView?.bounds)!
        self.playerViewController.contentOverlayView?.addSubview(backgroundImage)
        
        let backgroundEffect=UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        backgroundEffect.frame=(self.playerViewController.contentOverlayView?.bounds)!
        self.playerViewController.contentOverlayView?.addSubview(backgroundEffect)
        
        self.playerViewController.contentOverlayView?.addSubview(imageView)
    }
    
    func disconnect(){
        print("disconnect")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}