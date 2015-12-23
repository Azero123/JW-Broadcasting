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

The initial "playlist" is fetched using http://mediator.jw.org (base) on version "v1" using the language code (check rootController for information on language and language codes). Then the file location is "Streaming" and the website has a paramater sent called utcOffset with a typical value of -480.

The final url typically comes out as such:

http://mediator.jw.org/v1/schedules/E/Streaming?utcOffset=-480

This url contains all the information for every channel for hours worth of time in a JSON format with a format of:

category = {
    description = String
    key = "Streaming"
    name = "Streaming"
    type = "container"
    tags = [
    "RokuCategorySelectionPosterScreen" (Unkown string for Roku???)
    "JWLExclude" (Exclude from the JW Library app???)
    ]
    images = {} (Probably would follow the same format as in VOD if there were any images)
    parentCategory = null (Streaming does not have a parent category)
    subcategories = [
    %subcategory%,
    %subcategory%,
    ...
    ]

}

%subcategory% represents a Streaming channel (Children, Family, From our Studio, etc.) and follows this format:

%subcategory% = {
    position = {
    index = Int (The index in media that we will play)
    time = Float (The time progressed through the video)
    }
    media = [
    {
    files = [
    {
    progressiveDownloadURL = String (String of URL for mp4 file)
    }
    ...
    ] (files related to the video or audio file the later down the list the higher the resolution)
}



The key information we need here is where we are currently at and what videos to play.


Firstly we need to create a AVPlayerLayer we do this in startStream() on view did load after we ensure we have a relatively new schedule for the streams.

func startStream()
The startStream method sets up the AVPlayer in the AVPlayerLayer (check AVKit documentation by apple for information on these classes).
Lastly the notification for videos ending is configured to:
playerItemDidReachEnd(notification:NSNotification)


The "playlist" is refreshed every time a video ends by the notification method:
func playerItemDidReachEnd(notification:NSNotification)
Which calls func updateStream()

LATER IMPROVEMENT

Later instead of updating the files every time we need to start the stream we will have code that checks if the current file contains the video to be played at this time, then request a new file upon video completion however not change the time index or video url unless needed.
Also next up videos will be added the the AVPlayers queue so that it will preload them.
Lastly add code that when under poor connection drops the video quality down and monitors the for if the video gets off time (possible modifying the .rate slightly of the AVPlayer to catch up or slow down)

Possibly implement some form of HTTP sitching



POSSIBLE REQUESTS

Information for brothers in bethel on this page

Using stitching techniques we can have separate Audio, Video, and caption text. The users can enable/disable captions and the video would not have to be stored several times for different languages. (However downloaded videos may still require the current method of dubbing and captioning so maybe not?)


*/

import Foundation
import AVKit

class StreamingViewController : UIViewController {
    
    
    var currentURL:String?
    var playlist=[]
    var _streamID:Int=0
    var streamID:Int {
        
        /*
        The channel is being changed (probably from the HomeController to select the proper channel)
        */
        
        set (newValue){
            _streamID=newValue
            if (thisControllerIsVisible){ // Only update the stream if this page is already visible so that we don't modify variables before initialization
                updateStream()
                previousLanguageCode=languageCode // Keep in mind what language we were last in
                previousStreamId=streamID // Keep in mind the previous channel
            }
        }
        get {
            return _streamID
        }
        
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! // The spinning wheel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=0"
        
        /*
        Show the spinning wheel to the user so the user knows that we are downloading data
        */
        
        self.activityIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0)
        self.activityIndicator.hidesWhenStopped=true
        self.activityIndicator.startAnimating()
        self.view.userInteractionEnabled=true
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
            dictionaryOfPath(streamingScheduleURL, usingCache: false) //Download streaming schedule
            
            dispatch_async(dispatch_get_main_queue()) {
                if (self.view.hidden==false){ //Only display if view is visible (This was an ios 9.0 issue and the if statement could possibly be removed
                    self.startStream()
                    self.update()
                }
            }
        }
        
    }
    
    var _player:AVQueuePlayer?
    var player:AVQueuePlayer? {
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
        //creastes the AVPlayer applying necissary changes and then calls updateStream() to update the video to the schedule
        
        player = AVQueuePlayer()//Creates the player for the layer
        playerLayer=AVPlayerLayer(player: player)//Creates the layer
        playerLayer!.frame=UIScreen.mainScreen().bounds//Sets the video to be the size of the screen
        
        player!.actionAtItemEnd = AVPlayerActionAtItemEnd.None;
        updateStream()//Matches to the current video and to the stream index
    }
    
    var indexInPlaylist=0
    
    func playerItemDidReachEnd(notification:NSNotification){
        
        /*
        Current code for moving to the next stream video.
        */
        
        indexInPlaylist++ //Next video index
        self.player?.advanceToNextItem()
        self.performSelector("updateStream", withObject: nil, afterDelay: 1)//updateStream() //Makes sure we are on the right video and at the righr time (give or take 10 seconds)
    }
    
    var thisControllerIsVisible=false
    
    @IBOutlet var focusButton: UIButton!
    
    var initialAppear=true
    
    var previousLanguageCode=languageCode
    var previousStreamId = -1
    
    override func viewWillAppear(animated: Bool) {
        thisControllerIsVisible=true
        //if (initialAppear){
        if ((player) != nil || previousLanguageCode != languageCode || previousStreamId != streamID){ //If we have initialized the player and any major data has changed then we need to refresh the content
            updateStream()
        }
        previousLanguageCode=languageCode//Remember what language we are in
        previousStreamId=streamID//Remember what channel we are on
        self.view.hidden=false
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //updateStream()
    }
    
    override func viewWillDisappear(animated: Bool) {
        //Hide and pause the video when we leave the Streaming page
        self.view.hidden=true
        player?.pause()
    }
    
    override func viewDidDisappear(animated: Bool) {
        //Remeove any data we do not need store when streaming is off
        thisControllerIsVisible=false
        player?.pause()
        player?.replaceCurrentItemWithPlayerItem(nil)
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        //The view size changed so let's correct the player size
        
        playerLayer?.position=CGPointMake(0, 0)
        
        playerLayer!.frame=self.view.frame
        
    }
    
    func updateStream(){
        
        activityIndicator.startAnimating() //This process normally doesn't take a while but if it does let the user know the app is loading content
        
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480" //The Schedule url for all the streams
        
        
        
        
        if ((self.player?.currentItem) != nil){
            //self.player?.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
        }
        //fetchDataUsingCache(streamingScheduleURL, downloaded: {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                
                //let streamMeta=dictionaryOfPath(streamingScheduleURL, usingCache: false)
                
                dispatch_async(dispatch_get_main_queue()) {
                    print("[Channels] \(self.streamID)")
                    
                    fetchDataUsingCache(streamingScheduleURL, downloaded: nil)
                    
                    let subcategory=unfold("\(streamingScheduleURL)|category|subcategories|\(self.streamID)")//streamMeta?.objectForKey("category")?.objectForKey("subcategories")!.objectAtIndex(self.streamID)
                    
                    
                    
                    
                    //Code for getting current index
                    
                    var i=(unfold("\(streamingScheduleURL)|category|subcategories|\(self.streamID)|position|index") as! NSNumber).integerValue //Get the current index from tv.jw.org
                    self.indexInPlaylist=i //Getting the index was successful now use it
                    
                    
                    
                    
                    
                    var timeIndex=subcategory!.objectForKey("position")?.objectForKey("time")?.floatValue
                    
                    
                    if (self.player != nil){
                        
                        do {
                            let storedPath=cacheDirectory!+"/"+(NSURL(string: streamingScheduleURL)?.path!.stringByReplacingOccurrencesOfString("/", withString: "-"))! // the desired stored file path
                            
                            print("streaming stored path:\(storedPath)")
                            
                            let dateDataWasRecieved=try NSFileManager.defaultManager().attributesOfItemAtPath(storedPath)[NSFileModificationDate] as! NSDate
                            print("We have had this file since:\(dateDataWasRecieved.timeIntervalSinceNow)")
                            timeIndex=timeIndex!-Float(dateDataWasRecieved.timeIntervalSinceNow)
                            
                        }
                        catch {
                            print("[ERROR] problem discovering the date streaming schedule was recieved")
                        }
                        //The date that we got the file last, let's hope that we don't have any issues here
                        
                        
                    }
                    
                    
                    
                    while (true) {
                        let supposedCurrentVideoDuration=unfold("\(streamingScheduleURL)|category|subcategories|\(self.streamID)|media|\(i)|duration")
                        if ((supposedCurrentVideoDuration) == nil){
                            print("[ERROR] broke because current video duration could not be determined")
                            fetchDataUsingCache(streamingScheduleURL, downloaded: {
                                self.updateStream()
                                }, usingCache: false)
                            return
                        }
                        
                        let supposedCurrentVideoDurationInt=(supposedCurrentVideoDuration as! NSNumber).integerValue
                        
                        if (timeIndex>Float(supposedCurrentVideoDurationInt)){
                            timeIndex=timeIndex!-Float(supposedCurrentVideoDurationInt)
                            i++
                        }
                        else {
                            break
                        }
                        
                    }
                    
                    
                    
                    /*
                    
                    Check for new videos to add to queue.
                    This loops through all the upcoming videos in the stream comparing them with what we previously had.
                    If the videos do not match up it removes the video from the queue and replaces it with the new one.
                    
                    If we do not have any video in that place it just adds it to the queue.
                    
                    */
                    
                    
                    for ; i<(unfold("\(streamingScheduleURL)|category|subcategories|\(self.streamID)|media|count") as! NSNumber).integerValue  ; i++ {
                        let videoURL=unfold("\(streamingScheduleURL)|category|subcategories|\(self.streamID)|media|\(i)|files|\(StreamingLowestQuality ? "first": "last")|progressiveDownloadURL") as? String
                        if (self.player?.items().count > i){
                            //The video index is already taken so check it
                            if ((self.player?.items()[i].asset.isKindOfClass(AVURLAsset.self)) == true){
                                //Make sure the url is available
                                if ((self.player?.items()[i-1].asset as! AVURLAsset).URL.absoluteString != videoURL){
                                    //Okay so we have a differen't video than what we previously had so remove it and add the new video
                                    
                                    
                                    
                                    print("[Stream] Replace video \(i-1) \((self.player?.items()[i-1].asset as! AVURLAsset).URL.absoluteString) \(videoURL)")
                                    
                                    /*self.player?.removeItem((self.player?.items()[i-1])!)//remove
                                    
                                    let playerItem=AVPlayerItem(URL: NSURL(string: videoURL!)!)//make new video
                                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)//Let us know when the video finishes playing to go to the next one
                                    
                                    self.player?.insertItem(playerItem, afterItem: self.player?.items()[i-2])//Insert video to it's proper place
                                    */
                                }
                            }
                        }
                        else {
                            //The does not exist yet so just add the new video
                            
                            if (self.player != nil && videoURL != nil){
                                print("[Stream] add video")
                                let playerItem=AVPlayerItem(URL: NSURL(string: videoURL!)!)//make new video
                                //AVPlayerItemDidPlayToEndTimeNotification
                                NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)//Let us know when the video finishes playing to go to the next one
                                self.player?.insertItem(playerItem, afterItem: nil)//Insert video to it's proper place
                            }
                        }
                        
                    }
                    
                    
                    
                    
                    
                    if (self.player != nil){
                    
                        if ((self.player?.currentTime().value)!-CMTimeMake(Int64(timeIndex!), 1).value < abs(10)){
                            print("[Channels] too far behind")
                            self.player!.seekToTime(CMTimeMake(Int64(timeIndex!), 1))
                        }
                        else {
                            print("[Channels] close enough")
                            
                        }
                    }
                    
                    
                    
                    
                    
                }
            }
        
        //player?.setRate(1.5, time: kCMTimeInvalid, atHostTime: CMTimeMake(Int64(timeIndex!), 1))
        /*might try using set rate to speed the video up until it catches up to the current time that way users can watch the video uninterrupted. Currently having some bugs with this however*/

    }
    
    
    var advancedLabel:UILabel?
    
    
    func update(){
        
        if (StreamingAdvancedMode){
        
            if (advancedLabel == nil){
                advancedLabel=UILabel(frame: CGRect(x: 10, y: self.view.frame.height-50, width: self.view.bounds.width, height: 40))
                advancedLabel?.font=UIFont.systemFontOfSize(30)
                advancedLabel?.shadowColor=UIColor.blackColor()
                advancedLabel?.textColor=UIColor.whiteColor()
                self.view.superview!.addSubview(advancedLabel!)
                player?.rate=1.0
            }
        }
        if ((self.player) != nil && player?.currentItem != nil && player?.currentItem?.status == AVPlayerItemStatus.ReadyToPlay){
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