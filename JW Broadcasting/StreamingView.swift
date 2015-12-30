//
//  LivePreview.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/11/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit
import AVKit

class StreamView: UIImageView {
    
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
    
    var activityIndicator: UIActivityIndicatorView! = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge ) // The spinning wheel
    
    convenience init(){
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        supportInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        supportInit()
    }
    
    let darkener=CALayer()
    
    func supportInit(){
        
        self.userInteractionEnabled = true
        //self.adjustsImageWhenAncestorFocused = true
        //self.backgroundColor=UIColor.blackColor()
        self.clipsToBounds=true
        /*let guide=UIFocusGuide()
        guide.preferredFocusedView=self
        self.superview!.addLayoutGuide(guide)*/
        /*
        UIFocusGuide *focusGuide = [[UIFocusGuide alloc]init];
        focusGuide.preferredFocusedView = [self preferredFocusedView];
        [self.view addLayoutGuide:focusGuide];
        */
        
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=0"
        /*
        Show the spinning wheel to the user so the user knows that we are downloading data
        */
        
        self.backgroundColor=UIColor.clearColor()
        self.opaque=true
        //self.activityIndicator.color=UIColor(colorLiteralRed: 0.3, green: 0.44, blue: 0.64, alpha: 1.0)
        //self.activityIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0)
        darkener.frame=self.bounds
        darkener.backgroundColor=UIColor.blackColor().CGColor
        darkener.opacity=0.5
        self.layer.addSublayer(darkener)
        
        let fadeInAnimation=CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.fromValue = 0
        fadeInAnimation.toValue = 0.5
        fadeInAnimation.additive = false
        fadeInAnimation.removedOnCompletion = true
        fadeInAnimation.duration = 1
        fadeInAnimation.fillMode = kCAFillModeForwards;
        darkener.addAnimation(fadeInAnimation, forKey: nil)
        
        self.activityIndicator.frame=CGRectMake(0, 0, self.activityIndicator.frame.size.width*4, self.activityIndicator.frame.size.height*4)
        self.activityIndicator.layer.shadowColor=UIColor.blackColor().CGColor
        self.activityIndicator.layer.shadowOpacity=1
        self.activityIndicator.layer.shadowRadius=5
        
        activityIndicator.center=CGPointMake(self.bounds.width/2, self.bounds.height/2)
        self.addSubview(activityIndicator)
        self.activityIndicator.hidesWhenStopped=true
        self.activityIndicator.startAnimating()
        self.userInteractionEnabled=true
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            dictionaryOfPath(streamingScheduleURL, usingCache: false) //Download streaming schedule
            

            dispatch_async(dispatch_get_main_queue()) {
                
                /*fetchDataUsingCache("streaming", downloaded: {
                    dispatch_async(dispatch_get_main_queue()) {
                        if (self.subcategoryCollectionViews.indexOf(collectionView as! MODSubcategoryCollectionView)! == 0){
                            if (indexPath.row==0){
                                
                                cell.contentView.addSubview(StreamView(frame: cell.bounds))
                            }
                        }
                    }
                })*/
                
                if (self.hidden==false){ //Only display if view is visible (This was an ios 9.0 issue and the if statement could possibly be removed
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
        playerLayer?.backgroundColor=UIColor.clearColor().CGColor
        playerLayer?.opaque=true
        playerLayer!.frame=self.bounds//Sets the video to be the size of the screen
        
        
        let scaleUp:CGFloat=1//playerLayer!.frame.size.width/474
        print("scale up:\(scaleUp)")
        if (playerLayer != nil && self.superview != nil){
            playerLayer!.frame=CGRect(x: ((self.superview?.frame.size.width)!-self.frame.size.width*scaleUp)/2, y: ((self.frame.size.height)-self.frame.size.height*scaleUp)/2, width: self.frame.size.width*scaleUp, height: self.frame.size.height*scaleUp)
        }
        
        player!.actionAtItemEnd = AVPlayerActionAtItemEnd.None;
        updateStream()//Matches to the current video and to the stream index
        self.player?.play()
        self.player?.muted=true
        self.userInteractionEnabled=true
        
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
    /*
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
    */
    
    func updateStream(){
        
        NSLog("start update stream")
        activityIndicator.startAnimating() //This process normally doesn't take a while but if it does let the user know the app is loading content
        
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480" //The Schedule url for all the streams
        
        
        
        
        if ((self.player?.currentItem) != nil){
            //self.player?.currentItem?.removeObserver(self, forKeyPath: "status", context: nil)
        }
        //fetchDataUsingCache(streamingScheduleURL, downloaded: {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            
            //let streamMeta=dictionaryOfPath(streamingScheduleURL, usingCache: false)
            
                print("[Channels] \(self.streamID)")
                
            fetchDataUsingCache(streamingScheduleURL, downloaded: {
                unfold("\(streamingScheduleURL)")
            })
            
                let subcategory=unfold("\(streamingScheduleURL)|category|subcategories|\(self.streamID)")//streamMeta?.objectForKey("category")?.objectForKey("subcategories")!.objectAtIndex(self.streamID)
            
            
                
                
                //Code for getting current index
            
                var i=(unfold("\(streamingScheduleURL)|category|subcategories|\(self.streamID)|position|index") as! NSNumber).integerValue //Get the current index from tv.jw.org
            self.indexInPlaylist=i //Getting the index was successful now use it
            
                
                
                
                
                var timeIndex=subcategory!.objectForKey("position")?.objectForKey("time")?.floatValue
                
                
                if (self.player != nil){
                    
                    do {
                        let storedPath=cacheDirectory!+"/"+(NSURL(string: streamingScheduleURL)?.path!.stringByReplacingOccurrencesOfString("/", withString: "-"))! // the desired stored file path
                        
                        
                        let dateDataWasRecieved=try NSFileManager.defaultManager().attributesOfItemAtPath(storedPath)[NSFileModificationDate] as! NSDate
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
            
                for ; i<(unfold("\(streamingScheduleURL)|category|subcategories|\(self.streamID)|media|count") as! NSNumber).integerValue ; i++ {
                    let videoURL=unfold("\(streamingScheduleURL)|category|subcategories|\(self.streamID)|media|\(i)|files|\(StreamingLowestQuality || true ? "first": "last")|progressiveDownloadURL") as? String
                    //imageUsingCache(unfold("\(streamingScheduleURL)|category|subcategories|\(self.streamID)|media|\(i)|") as! String)
                    
                    
                    if (self.player?.items().count > i){
                        //The video index is already taken so check it
                        if ((self.player?.items()[i].asset.isKindOfClass(AVURLAsset.self)) == true){
                            //Make sure the url is available
                            //if ((self.player?.items()[i-1].asset as! AVURLAsset).URL.absoluteString != videoURL){
                                //Okay so we have a differen't video than what we previously had so remove it and add the new video
                                
                                
                                
                                //print("[Stream] Replace video \(i-1) \((self.player?.items()[i-1].asset as! AVURLAsset).URL.absoluteString) \(videoURL)")
                                
                                /*self.player?.removeItem((self.player?.items()[i-1])!)//remove
                                
                                let playerItem=AVPlayerItem(URL: NSURL(string: videoURL!)!)//make new video
                                NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)//Let us know when the video finishes playing to go to the next one
                                
                                self.player?.insertItem(playerItem, afterItem: self.player?.items()[i-2])//Insert video to it's proper place
                                */
                            //}
                        }
                    }
                    else {
                        //The does not exist yet so just add the new video
                        
                        if (self.player != nil && videoURL != nil){
                            print("[Stream] add video")
                            
                            /*
                            let operation = NSBlockOperation()
                            operation.addExecutionBlock { () -> Void in
                                print("start operation")
                                // create the asset
                                let asset = AVURLAsset(URL: NSURL(string: videoURL!)!, options: nil)
                                // load values for track keys
                                let keys = ["tracks", "duration"]
                                asset.loadValuesAsynchronouslyForKeys(keys, completionHandler: { () -> Void in
                                    // Loop through and check to make sure keys loaded
                                    var successful = true
                                    for key in keys {
                                        var error: NSError?
                                        let keyStatus: AVKeyValueStatus = asset.statusOfValueForKey(key, error: &error)
                                        if keyStatus == .Failed {
                                            successful=false
                                            print("Failed to load key: \(key), error: \(error)")
                                        }
                                        else if keyStatus != .Loaded {
                                            successful=false
                                            print("Warning: Ignoring key status: \(keyStatus), for key: \(key), error: \(error)")
                                        }
                                    }
                                    if successful == true {
                                        if operation.cancelled == false {
                                            let composition = self.createCompositionFromAsset(asset)
                                            // register notifications
                                            let playerItem = AVPlayerItem(asset: composition)
                                            //self.registerNotificationsForItem(playerItem)
                                            //self.playerItem = playerItem
                                            // create the player
                                            //let player = AVPlayer(playerItem: playerItem)
                                            //self.player.player = player
                                            self.player?.insertItem(playerItem, afterItem: nil)
                                            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
                                        }
                                    }
                                    else {
                                        print("Failed to load asset")
                                    }
                                })
                            }
                                // add operation to the queue
                                NSOperationQueue().addOperation(operation)*/
                            
                            
                            let playerItem=AVPlayerItem(URL: NSURL(string: videoURL!)!)//make new video
                            //AVPlayerItemDidPlayToEndTimeNotification
                            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)//Let us know when the video finishes playing to go to the next one
                            self.player?.insertItem(playerItem, afterItem: nil)//Insert video to it's proper place
                        }
                    }
                    
                }
                
                
                if (self.player != nil){
                    print("\((self.player?.currentTime().value)!) \(timeIndex)")
                    if (abs((self.player?.currentTime().value)!-CMTimeMake(Int64(timeIndex!), 1).value) > abs(10)){
                        print("[Channels] too far behind")
                        self.player!.seekToTime(CMTimeMake(Int64(timeIndex!), 1))
                    }
                    else {
                        print("[Channels] close enough")
                        
                    }
                }
                
                
                
                
                
            
        }
        
        //player?.setRate(1.5, time: kCMTimeInvalid, atHostTime: CMTimeMake(Int64(timeIndex!), 1))
        /*might try using set rate to speed the video up until it catches up to the current time that way users can watch the video uninterrupted. Currently having some bugs with this however*/
        
        NSLog("end update stream")
    }
        
        
        
    func createCompositionFromAsset(asset: AVAsset, repeatCount: UInt8 = 16) -> AVMutableComposition {
        let composition = AVMutableComposition()
        let timescale = asset.duration.timescale
        let duration = asset.duration.value
        let editRange = CMTimeRangeMake(CMTimeMake(0, timescale), CMTimeMake(duration, timescale))
        do {
            try composition.insertTimeRange(editRange, ofAsset: asset, atTime: composition.duration)
            
            for _ in 0 ..< repeatCount - 1 {
                try composition.insertTimeRange(editRange, ofAsset: asset, atTime: composition.duration)
            }
        }
        catch {
            
        }
        return composition
    }
    /*
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
    case .DownArrow: break
    case .LeftArrow: break
    case .RightArrow: break
    default:
    //keepDown()
    
    break
    }
    }
    
    super.pressesBegan(presses, withEvent: event)
    
    }
    */
    
    var advancedLabel:UILabel?
    
    
    func update(){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        if (StreamingAdvancedMode){
            
            if (self.advancedLabel == nil){
                self.advancedLabel=UILabel(frame: CGRect(x: 10, y: self.bounds.height-50, width: self.bounds.width, height: 40))
                self.advancedLabel?.font=UIFont.systemFontOfSize(30)
                self.advancedLabel?.shadowColor=UIColor.blackColor()
                self.advancedLabel?.textColor=UIColor.whiteColor()
                self.addSubview(self.advancedLabel!)
                self.player?.rate=1.0
            }
        }
        if ((self.player) != nil && self.player?.currentItem != nil && self.player?.currentItem?.status == AVPlayerItemStatus.ReadyToPlay){
            self.advancedLabel?.text=" bitrate \(self.player?.rate) \(floor((self.player?.currentTime().seconds)!))/\(floor((self.player?.currentItem?.duration.seconds)!)) \(self.player?.currentItem?.asset)"
            
            if (self.player!.currentItem!.status == AVPlayerItemStatus.ReadyToPlay) {
                self.activityIndicator.stopAnimating()
                if (self.hidden==false){
                    if (self.playerLayer!.superlayer == nil){
                        dispatch_async(dispatch_get_main_queue()) {
                            self.playerLayer?.player?.play()
                            self.layer.addSublayer(self.playerLayer!)
                            
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                                self.darkener.removeFromSuperlayer()
                                self.image=nil
                            }
                            
                            
                            //self.playerLayer?.backgroundColor=UIColor.blackColor().CGColor
                            /*
                            let positionAnimate=CABasicAnimation(keyPath: "position")
                            positionAnimate.duration=0.5
                            positionAnimate.fromValue=NSValue(CGPoint:self.darkener.frame.origin)
                            positionAnimate.toValue=NSValue(CGPoint:(self.playerLayer?.frame.origin)!)
                            positionAnimate.removedOnCompletion=false
                            
                            self.darkener.addAnimation(positionAnimate, forKey: nil)
                            */
                            
                            CATransaction.begin()
                            let frameAnimate=CABasicAnimation(keyPath: "bounds")
                            frameAnimate.duration=0.5
                            frameAnimate.fromValue=NSValue(CGRect:self.darkener.bounds)
                            frameAnimate.toValue=NSValue(CGRect:(self.playerLayer?.bounds)!)
                            frameAnimate.removedOnCompletion=false
                            //frameAnimate.fillMode=kCAF
                            CATransaction.setCompletionBlock({
                                
                                
                                
                                CATransaction.begin()
                                let fadeInAnimation=CABasicAnimation(keyPath: "opacity")
                                fadeInAnimation.fromValue = 0
                                fadeInAnimation.toValue = 1
                                fadeInAnimation.additive = false
                                fadeInAnimation.removedOnCompletion = true
                                fadeInAnimation.duration = 1
                                fadeInAnimation.fillMode = kCAFillModeForwards
                                CATransaction.setCompletionBlock({
                                    
                                    self.darkener.removeFromSuperlayer()
                                    self.image=nil
                                    })
                                self.playerLayer!.addAnimation(fadeInAnimation, forKey: nil)
                                CATransaction.commit()
                            })
                            self.darkener.addAnimation(frameAnimate, forKey: nil)
                            CATransaction.commit()
                            
                            
                            
                        
                        }
                    }
                }
                if (self.thisControllerIsVisible){
                    
                    let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=-480" //The Schedule url for all the streams
                    NSLog("busy in play unfolding")
                    let subcategory=unfold("\(streamingScheduleURL)|category|subcategories|\(self.streamID)")//streamMeta?.objectForKey("category")?.objectForKey("subcategories")!.objectAtIndex(self.streamID)
                    NSLog("busy in play unfolding")
                    
                    var timeIndex=subcategory!.objectForKey("position")?.objectForKey("time")?.floatValue
                    
                    
                    do {
                        let storedPath=cacheDirectory!+"/"+(NSURL(string: streamingScheduleURL)?.path!.stringByReplacingOccurrencesOfString("/", withString: "-"))! // the desired stored file path
                        
                        
                        let dateDataWasRecieved=try NSFileManager.defaultManager().attributesOfItemAtPath(storedPath)[NSFileModificationDate] as! NSDate
                        timeIndex=timeIndex!-Float(dateDataWasRecieved.timeIntervalSinceNow)
                        
                    }
                    catch {
                        print("[ERROR] problem discovering the date streaming schedule was recieved")
                    }
                    //The date that we got the file last, let's hope that we don't have any issues here
                    
                    
                    
                    self.player!.seekToTime(CMTimeMake(Int64(timeIndex!), 1))
                    
                        print("play")
                        if (abs((self.player?.currentTime().value)!-CMTimeMake(Int64(timeIndex!), 1).value) < abs(10)){
                            /*self.player?.play()
                            self.darkener.removeFromSuperlayer()
                            self.image=nil
                            self.layer.addSublayer(self.playerLayer!)*/
                        }
                }
            }
            
        }
            //print("ping")
            dispatch_async(dispatch_get_main_queue()) {
                self.performSelector("update", withObject: nil, afterDelay: 0.25)
            }
        }
    }
    
    
    
    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        return true
    }
    
    func focus() {
        // handle focus appearance changes
        
        let hMotionEffect=UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis)
        hMotionEffect.minimumRelativeValue = -10
        hMotionEffect.maximumRelativeValue = 10
        
        let vMotionEffect=UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.TiltAlongVerticalAxis)
        vMotionEffect.minimumRelativeValue = -10
        vMotionEffect.maximumRelativeValue = 10
        
        let group=UIMotionEffectGroup()
        group.motionEffects=[hMotionEffect,vMotionEffect]
        self.addMotionEffect(group)
        
        //self.backgroundColor=UIColor.blackColor()
        self.transform = CGAffineTransformMakeScale(1.135, 1.135)
        self.superview!.layer.shadowColor=UIColor.grayColor().CGColor
        self.superview!.layer.shadowOpacity=1
        self.superview!.layer.shadowRadius=30
        self.superview!.layer.shadowOffset=CGSize(width: 10, height: 50)
        //self.superview?.backgroundColor=UIColor.blackColor()
        
    }
    func unfocus(){
        self.motionEffects.removeAll()
        self.transform = CGAffineTransformMakeScale(1, 1)
        self.superview!.layer.shadowOpacity=0
        // handle unfocused appearance changes
    }
    
    override func canBecomeFocused() -> Bool {
        return true
    }
    
    
    var _frame:CGRect=CGRect(x: 0, y: 0, width: 0, height: 0)
    override var frame:CGRect {
        get {
            return super.frame
        }
        set (newValue){
            //Call update to correct UILabels because the frame could have changed
            super.frame=newValue
            activityIndicator.center=CGPointMake(self.bounds.width/2, self.bounds.height/2)
            /*let scaleUp:CGFloat=1
            if (playerLayer != nil){
                playerLayer!.frame=CGRect(x: ((self.superview?.frame.size.width)!-self.frame.size.width*scaleUp)/2, y: ((self.superview?.frame.size.height)!-self.frame.size.height*scaleUp)/2, width: self.frame.size.width*scaleUp, height: self.frame.size.height*scaleUp)
            }*/
        }
    }
    
}
