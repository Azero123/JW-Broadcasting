//
//  StreamingViewController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/15/15.
//  Copyright © 2015 xquared. All rights reserved.
//

/*
External references:

func dictionaryOfPath(path: String) -> NSDictionary? in AppDelegate
let base in AppDelegate
let version in AppDelegate
var languageCode in AppDelegate

This view controller represents the Streaming page. I opened reviewed the resources for http://tv.jw.org and tried to mimic the functionality of requesting a list of the next video files coming up playing them one at a time.

The initial "playlist" is fetched using http://mediator.jw.org (base) on version "v1" using the language code (check rootController for information on language and language codes).

The video url and current time index is then sent to:
func startStream(vidURL:String,time:Float)
The startStream method sets up the AVPlayer in the AVPlayerLayer (check AVKit documentation by apple for informatino on these classes).
Lastly the notification for videos ending is configured to:
playerItemDidReachEnd(notification:NSNotification)


The "playlist" is refreshed every time a video ends by the notification method:
func playerItemDidReachEnd(notification:NSNotification)
Which calls func updateStream()


*/

import Foundation
import AVKit

class StreamingViewController : UIViewController {
    
    //http://mediator.jw.org/v1/schedules/E/Streaming?utcOffset=-420
    
    
    var currentURL:String?
    var playlist=[]
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-420"
        
        self.activityIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0)
        self.activityIndicator.hidesWhenStopped=true
        self.activityIndicator.startAnimating()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
            let streamMeta=dictionaryOfPath(streamingScheduleURL, usingCache: false)
            
            dispatch_async(dispatch_get_main_queue()) {
                let subcategory=streamMeta?.objectForKey("category")?.objectForKey("subcategories")!.objectAtIndex(0)
                self.playlist=subcategory!.objectForKey("media") as! NSArray
                let currentVidMaybe=self.playlist.objectAtIndex(0).objectForKey("files")
                let timeIndex=subcategory!.objectForKey("position")?.objectForKey("time")?.floatValue
                if (self.view.hidden==false){
                    //currentVidMaybe!.count-1 is the highest quality
                    self.startStream((currentVidMaybe?.objectAtIndex(currentVidMaybe!.count-2).objectForKey("progressiveDownloadURL"))! as! String,time: timeIndex!)
                }
            }
        }
        
    }
    
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    
    func startStream(vidURL:String,time:Float){
        let videoURLString=vidURL
        
        let videoURL = NSURL(string: videoURLString)
        player = AVPlayer(URL: videoURL!)
        playerLayer=AVPlayerLayer(player: player)
        playerLayer!.frame=UIScreen.mainScreen().bounds
        
        player!.actionAtItemEnd = AVPlayerActionAtItemEnd.None;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player?.currentItem)
        self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        
        
        player!.seekToTime(CMTimeMake(Int64(time), 1))
        player!.play()
        
    }
    
    var indexInPlaylist=0
    
    func playerItemDidReachEnd(notification:NSNotification){
        indexInPlaylist++
        let newVidData=playlist.objectAtIndex(indexInPlaylist).objectForKey("files")
        let videoURL=newVidData!.objectAtIndex(newVidData!.count-1).objectForKey("progressiveDownloadURL")
        player?.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: NSURL(string: videoURL as! String)!))
        if (thisControllerIsVisible){
            player?.play()
            updateStream()
        }
    }
    
    var thisControllerIsVisible=false
    
    @IBOutlet var focusButton: UIButton!
    override func viewWillAppear(animated: Bool) {
        thisControllerIsVisible=true
        if ((player) != nil){
            self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
            player!.play()
            updateStream()
        }
        
        self.view.hidden=false
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.view.hidden=true
        player?.pause()
    }
    
    override func viewDidDisappear(animated: Bool) {
        thisControllerIsVisible=false
        player?.pause()
        player?.currentItem?.removeObserver(self, forKeyPath: "status")
        player?.replaceCurrentItemWithPlayerItem(nil)
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        playerLayer?.position=CGPointMake(0, 0)
        
        playerLayer!.frame=self.view.frame
        
    }
    
    func updateStream(){
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        activityIndicator.startAnimating()
        
        
        
        
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-420"
        
        //fetchDataUsingCache(streamingScheduleURL, downloaded: {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                print("streaming schedule downloaded...")
                
                let streamMeta=dictionaryOfPath(streamingScheduleURL, usingCache: false)
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    let subcategory=streamMeta?.objectForKey("category")?.objectForKey("subcategories")!.objectAtIndex(0)
                    self.indexInPlaylist=0
                    self.playlist=subcategory!.objectForKey("media") as! NSArray
                    let newVidData=self.playlist.objectAtIndex(self.indexInPlaylist).objectForKey("files")
                    let videoURL=newVidData!.objectAtIndex(newVidData!.count-2).objectForKey("progressiveDownloadURL")
                    let timeIndex=subcategory!.objectForKey("position")?.objectForKey("time")?.floatValue
                    if (videoURL as? String != self.currentURL){
                        self.player?.currentItem?.removeObserver(self, forKeyPath: "status")
                        self.player?.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: NSURL(string: videoURL as! String)!))
                        self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
                    }
                    self.player!.seekToTime(CMTimeMake(Int64(timeIndex!), 1))
                }
            }
        //})
        
        //player?.setRate(1.5, time: kCMTimeInvalid, atHostTime: CMTimeMake(Int64(timeIndex!), 1))
        /*might try using set rate to speed the video up until it catches up to the current time that way users can watch the video uninterrupted. Currently having some bugs with this however*/

    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (object as? AVPlayerItem == self.player!.currentItem && keyPath! == "status"){
        
            if (self.player!.currentItem!.status == AVPlayerItemStatus.ReadyToPlay) {
                activityIndicator.stopAnimating()
                if (self.view.hidden==false){
                    self.view.layer.addSublayer(playerLayer!)
                }
                if (thisControllerIsVisible){
                    player?.play()
                }
            }
            
        }
    }
    
}