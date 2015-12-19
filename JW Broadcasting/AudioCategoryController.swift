//
//  AudioCategoryController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/17/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit
import AVKit

class AudioCategoryController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var categoryIndex=0
    var previousLanguageCode=languageCode
    let images=["newsongs-singtojehovah","piano-singtojehovah","vocals-singtojehovah","kingdommelodies","drama","readings"]
    var playAll=true
    var shuffle=false
    var currentSongID=0
    var nextSongID=0
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var BackgroundEffectView: UIVisualEffectView!
    
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var playAllButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        playAllButton.clipsToBounds=false
        shuffleButton.clipsToBounds=false
        shuffleButton.titleLabel?.clipsToBounds=false
        
        playerViewController = AVPlayerViewController()
        player = AVQueuePlayer()
        playerViewController!.player = player
        
        let category="Audio"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let AudioDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        let title=unfold("\(AudioDataURL)|category|subcategories|\(categoryIndex)|name") as! String
        
        self.categoryTitle.text=title.componentsSeparatedByString("-")[0]
        if (title.componentsSeparatedByString("-").count>1){
            self.subLabel.text=title.componentsSeparatedByString("-")[1]
        }
        else {
            self.subLabel.text=""
        }
        self.categoryImage.image=UIImage(named: images[categoryIndex])
        self.backgroundImageView.image=UIImage(named: images[categoryIndex])
        self.categoryImage.contentMode = .ScaleToFill
        self.categoryImage.layoutIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        if (previousLanguageCode != languageCode){
            renewContent()
        }
        previousLanguageCode=languageCode
        
        self.view.hidden=false
    }
    
    override func viewDidDisappear(animated: Bool) {
       // self.player?.removeObserver(self, forKeyPath: "status")
        self.view.hidden=true
    }
    
    
    func renewContent(){
        
        //http://mediator.jw.org/v1/categories/E/Audio?detailed=1
        let category="Audio"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let AudioDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        self.categoryImage.image=UIImage(named: images[categoryIndex])
        self.backgroundImageView.image=UIImage(named: images[categoryIndex])
        self.categoryImage.contentMode = .ScaleToFill
        
        self.categoryImage.layoutIfNeeded()
        /*
        fetchDataUsingCache(AudioDataURL, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
            }
        })*/
        
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let category="Audio"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let AudioDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        let numberOfItems=unfold("\(AudioDataURL)|category|subcategories|\(categoryIndex)|media|count") as? Int
        if (numberOfItems != nil){
            return numberOfItems!
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath)
        cell.tag=indexPath.row
        let category="Audio"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let AudioDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        //print(unfold("\(AudioDataURL)|category|subcategories|\(1)|media|\(indexPath.row)|title"))
        cell.textLabel?.text = unfold("\(AudioDataURL)|category|subcategories|\(categoryIndex)|media|\(indexPath.row)|title") as? String
        let imageURL=unfold(nil, instructions: ["\(AudioDataURL)","category","subcategories",categoryIndex,"media",indexPath.row,"images",["sqr","sqs","cvr",""],["sm","md","lg","xs",""]]) as? String
        cell.detailTextLabel?.text=unfold("\(AudioDataURL)|category|subcategories|\(categoryIndex)|media|\(indexPath.row)|durationFormattedHHMM") as? String
        //cell.imageView?.image=UIImage(named: "Singing")
        if (imageURL != nil){
            fetchDataUsingCache(imageURL!, downloaded: {
                dispatch_async(dispatch_get_main_queue()) {
                    if (cell.tag == indexPath.row){
                        cell.imageView?.image = imageUsingCache(imageURL!)
                        cell.layoutIfNeeded()
                        cell.layoutSubviews()
                        cell.imageView?.layoutIfNeeded()
                    }
                }
            })
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    var playerViewController:AVPlayerViewController? = nil
    var player:AVQueuePlayer? = nil
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        player?.removeAllItems()
        nextSongID=indexPath.row
        playNextSong()
        
        
        self.presentViewController(playerViewController!, animated: true) {
            self.playerViewController!.player!.play()
            
            
        }
        
        
    }
    
    func playNextSong(){
        
        let category="Audio"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let AudioDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        let videoURLString=(unfold("\(AudioDataURL)|category|subcategories|\(categoryIndex)|media|\(nextSongID)|files|last|progressiveDownloadURL") as! String)
        currentSongID=nextSongID
        
        
        //player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.Prior, context: nil)

        
        let videoURL = NSURL(string: videoURLString)
        if (playAll){
            nextSongID=currentSongID+1
            if (shuffle){
                nextSongID=Int(arc4random_uniform(UInt32(unfold("\(AudioDataURL)|category|subcategories|\(categoryIndex)|media|count") as! Int)) + 1)
            }
            
            if (nextSongID>=unfold("\(AudioDataURL)|category|subcategories|\(categoryIndex)|media|count") as! Int){
                nextSongID=0
            }
            
            
            let nextVideoURLString=(unfold("\(AudioDataURL)|category|subcategories|\(categoryIndex)|media|\(nextSongID)|files|last|progressiveDownloadURL") as! String)
            let newItem=AVPlayerItem(URL: NSURL(string: nextVideoURLString)!)
            player!.insertItem(newItem, afterItem: nil)
            newItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.Prior, context: nil)
            
            
            
            
            
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: newItem)
        }
        else {
            playerViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    @IBAction func playAllButton(sender: AnyObject) {
        if (playAll==false){
            playAll=true
        }
        else {
            playAll=false
        }
    }
    @IBAction func shuffleButton(sender: AnyObject) {
        if (shuffle==false){
            shuffle=true
        }
        else {
            shuffle=false
        }
    }
    
    func playerItemDidReachEnd(notification:NSNotification){
        if (playerViewController != nil){
            //playerViewController?.player!.currentItem?.removeObserver(self, forKeyPath: "status")
            //playerViewController?.dismissViewControllerAnimated(true, completion: nil)
            playNextSong()
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (object != nil && object?.isKindOfClass(AVPlayerItem.self)==true && (object as! AVPlayerItem) == player?.currentItem && keyPath! == "status"){
            object?.removeObserver(self, forKeyPath: "status")
            //https://www.jw.org/apps/E_RSSMEDIAMAG?rln=E&rmn=wp&rfm=m4b
            if (player?.status == .ReadyToPlay){
                var isAudio = false
                
                for track in (player?.currentItem!.tracks)! {
                    if (track.assetTrack.mediaType == AVMediaTypeAudio){
                        isAudio=true
                    }
                }
                
                if (isAudio){
                    let category="Audio"
                    let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
                    let AudioDataURL=categoriesDirectory+"/"+category+"?detailed=1"
                    let imageURL=unfold(nil, instructions: ["\(AudioDataURL)","category","subcategories",self.categoryIndex,"media",currentSongID,"images",["sqr","sqs","cvr",""],["lg","sm","md","xs",""]]) as? String
                    
                    
                    let image=imageUsingCache(imageURL!)
                    let imageView=UIImageView(image: image)
                    self.playerViewController?.view.backgroundColor=UIColor.clearColor()
                    self.playerViewController?.contentOverlayView?.backgroundColor=UIColor.clearColor()
                    
                    let subviews=NSMutableArray(array: (self.playerViewController?.view.subviews)!)
                    
                    while subviews.count>0{
                        let subview=subviews.firstObject as! UIView
                        subviews.addObjectsFromArray(subview.subviews)
                        subview.backgroundColor=UIColor.clearColor()
                        subviews.removeObjectAtIndex(0)
                        
                    }
                    
                    imageView.layer.shadowColor=UIColor.blackColor().CGColor
                    imageView.layer.shadowOpacity=0.5
                    imageView.layer.shadowRadius=20
                    
                    imageView.center=(self.playerViewController?.contentOverlayView!.center)!
                    for subview in (self.playerViewController?.contentOverlayView?.subviews)! {
                        subview.removeFromSuperview()
                    }
                    
                    let backgroundImage=UIImageView(image: image)
                    backgroundImage.frame=(self.playerViewController?.contentOverlayView?.bounds)!
                    self.playerViewController?.contentOverlayView?.addSubview(backgroundImage)
                    
                    let backgroundEffect=UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
                    backgroundEffect.frame=(self.playerViewController?.contentOverlayView?.bounds)!
                    self.playerViewController?.contentOverlayView?.addSubview(backgroundEffect)
                    
                    self.playerViewController?.contentOverlayView?.addSubview(imageView)
                    
                    let label=UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 50))
                    label.text=unfold(nil, instructions: ["\(AudioDataURL)","category","subcategories",self.categoryIndex,"media",currentSongID,"title"]) as? String
                    label.center=CGPoint(x: imageView.center.x, y: imageView.center.y+imageView.frame.size.height/2+50)
                    label.textAlignment = .Center
                    label.font=UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
                    //title 3
                    self.playerViewController?.contentOverlayView?.addSubview(label)
                    
                }
            }
            //player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        }
        
    }

}
