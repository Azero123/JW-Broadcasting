//
//  StreamingViewController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/15/15.
//  Copyright © 2015 Austin Zelenka. All rights reserved.
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
    var _streamID:Int=0
    var streamID:Int {
        set (newValue){
            _streamID=newValue
            if (thisControllerIsVisible){
                updateStream()
                previousLanguageCode=languageCode
                previousStreamId=streamID
            }
        }
        get {
            return _streamID
        }
        
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=0"
        
        self.activityIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0)
        self.activityIndicator.hidesWhenStopped=true
        self.activityIndicator.startAnimating()
        self.view.userInteractionEnabled=true
        //self.startStream()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
            dictionaryOfPath(streamingScheduleURL, usingCache: false)
            
            dispatch_async(dispatch_get_main_queue()) {
                if (self.view.hidden==false){
                    //currentVidMaybe!.count-1 is the highest quality
                    self.startStream()
                    self.update()
                }
            }
        }
        
    }
    
    var _player:AVPlayer?
    var player:AVPlayer? {
        set (newValue){
            _player=newValue
            //updateStream()
        }
        get {
            return _player
        }
    }
    var playerLayer:AVPlayerLayer?
    
    func startStream(){
        
        player = AVPlayer()
        playerLayer=AVPlayerLayer(player: player)
        playerLayer!.frame=UIScreen.mainScreen().bounds
        
        player!.actionAtItemEnd = AVPlayerActionAtItemEnd.None;
        updateStream()
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
    
    var initialAppear=true
    
    var previousLanguageCode=languageCode
    var previousStreamId = -1
    
    override func viewWillAppear(animated: Bool) {
        thisControllerIsVisible=true
        //if (initialAppear){
        if ((player) != nil || previousLanguageCode != languageCode || previousStreamId != streamID){
            updateStream()
        }
        previousLanguageCode=languageCode
        previousStreamId=streamID
        self.view.hidden=false
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //updateStream()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.view.hidden=true
        player?.pause()
    }
    
    override func viewDidDisappear(animated: Bool) {
        thisControllerIsVisible=false
        player?.pause()
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
        
        
        
        
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480"
        
        
        
        
        if ((self.player?.currentItem) != nil){
            //self.player?.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
        }
        //fetchDataUsingCache(streamingScheduleURL, downloaded: {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                
                let streamMeta=dictionaryOfPath(streamingScheduleURL, usingCache: false)
                
                dispatch_async(dispatch_get_main_queue()) {
                    print("[Channels] \(self.streamID)")
                    
                    let subcategory=streamMeta?.objectForKey("category")?.objectForKey("subcategories")!.objectAtIndex(self.streamID)
                    self.indexInPlaylist=0
                    self.playlist=subcategory!.objectForKey("media") as! NSArray
                    let newVidData=self.playlist.objectAtIndex(self.indexInPlaylist).objectForKey("files")
                    let videoURL=newVidData!.objectAtIndex(newVidData!.count-2).objectForKey("progressiveDownloadURL")
                    let timeIndex=subcategory!.objectForKey("position")?.objectForKey("time")?.floatValue
                    if (videoURL as? String != self.currentURL){
                        self.player?.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: NSURL(string: videoURL as! String)!))
                        
                        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player?.currentItem)
                       // self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
                    }
                    if (self.player != nil){
                        if ((self.player?.currentTime().value)!+10>CMTimeMake(Int64(timeIndex!), 1).value){
                            print("[Channels] too far behind")
                            self.player!.seekToTime(CMTimeMake(Int64(timeIndex!), 1))
                        }
                        else {
                            print("[Channels] close enough")
                            
                        }
                    }
                }
            }
        //})
        
        //player?.setRate(1.5, time: kCMTimeInvalid, atHostTime: CMTimeMake(Int64(timeIndex!), 1))
        /*might try using set rate to speed the video up until it catches up to the current time that way users can watch the video uninterrupted. Currently having some bugs with this however*/

    }
    
    /*override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print("observing...")
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
    }*/
    
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?){
        for press in presses {
            switch press.type {
            case .Select: break
                //print("Select")
                //timer?.invalidate()
                
                
            case .PlayPause: break
                //print("Play/Pause")
                //timer?.invalidate()
                
                /*case .UpArrow:
                print("Up Arrow")*/
            case .DownArrow:
                streamID++
                updateStream()
                print("Down arrow")
                
                
                let alert=UIAlertController(title: "Warning!", message: "This is a test zone feature.", preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(alert, animated: true, completion: {
                    self.dismissViewControllerAnimated(true, completion: {
                        self.advancedMode=true
                    
                    })
                    
                })
                
                
                case .LeftArrow:
                    streamID--
                print("Left arrow")
                updateStream()
                case .RightArrow:
                    streamID++
                print("Right arrow")
                updateStream()
                /*case .Menu:
                print("Menu")*/
            default:
                //keepDown()
                
                break
            }
        }
        
        super.pressesBegan(presses, withEvent: event)
        
    }
    
    
    var advancedLabel:UILabel?
    var advancedMode=false
    
    
    func update(){
        
        if (advancedMode){
        
            if (advancedLabel == nil){
                advancedLabel=UILabel(frame: CGRect(x: 10, y: self.view.frame.height-20, width: self.view.bounds.width, height: 40))
                advancedLabel?.font=UIFont.systemFontOfSize(30)
                advancedLabel?.shadowColor=UIColor.blackColor()
                advancedLabel?.textColor=UIColor.whiteColor()
                self.view.superview!.addSubview(advancedLabel!)
                player?.rate=1.0
            }
        }
        if ((self.player) != nil && player?.currentItem != nil){
        advancedLabel?.text=" bitrate \(player?.rate) \(floor((player?.currentTime().seconds)!))/\(floor((player?.currentItem?.duration.seconds)!)) \(player?.currentItem?.asset)"
            
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
        self.performSelector("update", withObject: nil, afterDelay: 0.25)
    }
    
}