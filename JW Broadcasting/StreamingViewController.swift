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
        let streamMeta=dictionaryOfPath(base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-420")
        let subcategory=streamMeta?.objectForKey("category")?.objectForKey("subcategories")!.objectAtIndex(0)
        playlist=subcategory!.objectForKey("media") as! NSArray
        let currentVidMaybe=playlist.objectAtIndex(0).objectForKey("files")
        let timeIndex=subcategory!.objectForKey("position")?.objectForKey("time")?.floatValue
        
        startStream((currentVidMaybe?.objectAtIndex(currentVidMaybe!.count-1).objectForKey("progressiveDownloadURL"))! as! String,time: timeIndex!)
        activityIndicator.hidesWhenStopped=true
        activityIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0)
        activityIndicator.startAnimating()
    }
    
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    
    func startStream(vidURL:String,time:Float){
        let videoURLString=vidURL
        
        let videoURL = NSURL(string: videoURLString)
        player = AVPlayer(URL: videoURL!)
        playerLayer=AVPlayerLayer(player: player)
        playerLayer!.frame=self.view.frame
        
        player!.actionAtItemEnd = AVPlayerActionAtItemEnd.None;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player?.currentItem)
        self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        
        
        player!.seekToTime(CMTimeMake(Int64(time), 1))
        
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
    override func viewDidAppear(animated: Bool) {
        thisControllerIsVisible=true
        player!.play()
        updateStream()
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
        //self.navigationController?.navigationBarHidden=true
        //focusButton.canBecomeFocused()
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
        let streamMeta=dictionaryOfPath(base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-420")
        let subcategory=streamMeta?.objectForKey("category")?.objectForKey("subcategories")!.objectAtIndex(0)
        indexInPlaylist=0
        playlist=subcategory!.objectForKey("media") as! NSArray
        let newVidData=playlist.objectAtIndex(indexInPlaylist).objectForKey("files")
        let videoURL=newVidData!.objectAtIndex(newVidData!.count-1).objectForKey("progressiveDownloadURL")
        let timeIndex=subcategory!.objectForKey("position")?.objectForKey("time")?.floatValue
        if (videoURL as? String != currentURL){
            player?.currentItem?.removeObserver(self, forKeyPath: "status")
            player?.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: NSURL(string: videoURL as! String)!))
            self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        }
        player!.seekToTime(CMTimeMake(Int64(timeIndex!), 1))
        
        //player?.setRate(1.5, time: kCMTimeInvalid, atHostTime: CMTimeMake(Int64(timeIndex!), 1))
        /*might try using set rate to speed the video up until it catches up to the current time that way users can watch the video uninterrupted. Currently having some bugs with this however*/

    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print("observed:\(object)")
        if (object as? AVPlayerItem == self.player!.currentItem && keyPath! == "status"){
        
            if (self.player!.currentItem!.status == AVPlayerItemStatus.ReadyToPlay) {
                activityIndicator.stopAnimating()
                self.view.layer.addSublayer(playerLayer!)
                if (thisControllerIsVisible){
                    player?.play()
                }
            }
            
        }
    }
    
}