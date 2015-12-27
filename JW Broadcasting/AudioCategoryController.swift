//
//  AudioCategoryController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/17/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit
import AVKit

class AudioCategoryController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var categoryIndex=0
    var previousLanguageCode=languageCode
    let images=["newsongs-singtojehovah","piano-singtojehovah","vocals-singtojehovah","kingdommelodies","drama","readings"]
    var playAll=false
    var shuffle=false
    var currentSongID=0
    var nextSongID=0
    var smartPlayer = SuperMediaPlayer()
    
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
        
        let category="Audio"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let AudioDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        let title=categoryTitleCorrection(unfold("\(AudioDataURL)|category|subcategories|\(categoryIndex)|name") as! String)
        self.categoryTitle.text=title.componentsSeparatedByString("-")[0]
        if (title.componentsSeparatedByString("-").count>1){
            self.subLabel.text=title.componentsSeparatedByString("-")[1]
        }
        else {
            self.subLabel.text=""
        }
        self.categoryImage.image=UIImage(named: images[categoryIndex])
        //self.backgroundImageView.image=UIImage(named: images[categoryIndex])
        self.categoryImage.contentMode = .ScaleToFill
        self.categoryImage.layoutIfNeeded()
        self.categoryImage.layer.shadowColor=UIColor.blackColor().CGColor
        self.categoryImage.layer.shadowOpacity=0.25
        self.categoryImage.layer.shadowRadius=10
        
        let playAllLabel=UILabel(frame: CGRect(x: 0, y: 70, width: 100, height: 50))
        playAllLabel.text=unfold("\(base)/\(version)/translations/\(languageCode)|translations|\(languageCode)|itemPlayAllTitle") as? String
        self.playAllButton.addSubview(playAllLabel)
        playAllLabel.font=UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        playAllLabel.center=CGPoint(x: self.playAllButton.frame.size.width/2, y: playAllLabel.center.y)
        playAllLabel.textAlignment = .Center
        
        let shuffleLabel=UILabel(frame: CGRect(x: 0, y: 70, width: 100, height: 50))
        shuffleLabel.text=unfold("\(base)/\(version)/translations/\(languageCode)|translations|\(languageCode)|itemShuffleTitle") as? String
        self.shuffleButton.addSubview(shuffleLabel)
        shuffleLabel.font=UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        shuffleLabel.center=CGPoint(x: self.playAllButton.frame.size.width/2, y: playAllLabel.center.y)
        shuffleLabel.textAlignment = .Center
        
        playAllButton.addTarget(self, action: "playAllButton:", forControlEvents: UIControlEvents.PrimaryActionTriggered)
        shuffleButton.addTarget(self, action: "shuffleButton:", forControlEvents: UIControlEvents.PrimaryActionTriggered)
        
        
        let guide=UIFocusGuide()
        guide.preferredFocusedView=playAllButton
        playAllButton.addLayoutGuide(guide)
        guide.trailingAnchor.constraintEqualToAnchor(playAllButton.trailingAnchor, constant: 0).active=true
        guide.topAnchor.constraintEqualToAnchor(playAllButton.topAnchor, constant: -1000).active=true
        guide.bottomAnchor.constraintEqualToAnchor(playAllButton.bottomAnchor, constant: 0).active=true
        guide.leadingAnchor.constraintEqualToAnchor(playAllButton.leadingAnchor, constant: 0).active=true
        
    }
    
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        for item in presses {
            if item.type == .Menu {
                fadeVolume()
                playAll=false
                shuffle=false
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if (textDirection == .RightToLeft){
            UIView.appearance().semanticContentAttribute=UISemanticContentAttribute.ForceRightToLeft
        }
        playAll=true
        shuffle=false
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
        
        let title=unfold("\(AudioDataURL)|category|subcategories|\(categoryIndex)|media|\(indexPath.row)|title") as? String
        
        
        let extraction=titleExtractor(title!)
        
        
        var visualSongNumber:String?=nil
        if (extraction["visualNumber"] != nil){
            visualSongNumber=extraction["visualNumber"]!//Int(extraction["visualNumber"]!)
        }
        
        let attributedString=NSMutableAttributedString(string: "\(extraction["correctedTitle"]!)\n", attributes:  nil)
        let imageURL=unfold(nil, instructions: ["\(AudioDataURL)","category","subcategories",categoryIndex,"media",indexPath.row,"images",["sqr","sqs","cvr",""],["sm","md","lg","xs",""]]) as? String
        if (visualSongNumber != nil && (unfold("\(AudioDataURL)|category|subcategories|\(categoryIndex)|name") as! String).containsString("Sing to Jehovah")){
            cell.textLabel?.numberOfLines=2
            if (languageCode == "E"){
                let attributes=[NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1),NSForegroundColorAttributeName:UIColor.grayColor()]
                attributedString.appendAttributedString(NSMutableAttributedString(string: "Song: \(visualSongNumber!)", attributes: attributes))
            }
            else {
                attributedString.appendAttributedString(NSMutableAttributedString(string: "\(visualSongNumber!)", attributes: [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1),NSForegroundColorAttributeName:UIColor.grayColor()]))
            }
            
            if (extraction["parentheses"] != nil){
                attributedString.appendAttributedString(NSMutableAttributedString(string: "\(extraction["parentheses"]!)", attributes: [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1),NSForegroundColorAttributeName:UIColor.grayColor()]))
            }
            //[NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1),NSForegroundColorAttributeName:UIColor.grayColor()]
            cell.textLabel?.attributedText=attributedString
        }
        else if (extraction["parentheses"] != nil){
            cell.textLabel?.numberOfLines=2
            attributedString.appendAttributedString(NSMutableAttributedString(string: "\(extraction["parentheses"]!)", attributes: [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1),NSForegroundColorAttributeName:UIColor.grayColor()]))
            cell.textLabel?.attributedText=attributedString
        }
        else {
            //cell.textLabel?.numberOfLines=0
            cell.textLabel?.text=attributedString.string
        }
        
        cell.detailTextLabel?.font=UIFont.preferredFontForTextStyle(UIFontTextStyleBody)//cell.detailTextLabel?.font.fontWithSize(30)
        cell.detailTextLabel?.text=unfold("\(AudioDataURL)|category|subcategories|\(categoryIndex)|media|\(indexPath.row)|durationFormattedHHMM") as? String
        //cell.imageView?.image=UIImage(named: "Singing")
        
        
        
        /*
        
        WARNING
        
        The UITableViewCell image views are currently broken in Right to left so in the RTL Semantic table view images are off.
        
        */
        
        
        if (imageURL != nil && UIView.appearance().semanticContentAttribute != UISemanticContentAttribute.ForceRightToLeft){
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
        return 90
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        smartPlayer.player.removeAllItems()
        nextSongID=indexPath.row
        playAll=false
        shuffle=false
        playNextSong()
        
        
        self.smartPlayer.dismissWhenFinished=true
        
        self.smartPlayer.finishedPlaying = {() in
        }
        
        smartPlayer.playIn(self)
        
    }
    
    func playNextSong(){
        
        let category="Audio"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let AudioDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        currentSongID=nextSongID
        
        
        //player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.Prior, context: nil)
        
        //smartPlayer.nextDictionary=unfold("\(AudioDataURL)|category|subcategories|\(categoryIndex)|media|\(nextSongID)") as? NSDictionary
        smartPlayer.updatePlayerUsingDictionary((unfold("\(AudioDataURL)|category|subcategories|\(categoryIndex)|media|\(nextSongID)") as? NSDictionary)!)
        
        
        
    }
    
    
    func fadeVolume(){
        
        self.smartPlayer.player.volume=(self.smartPlayer.player.volume)-0.05
        if (self.smartPlayer.player.volume>0){
            self.performSelector("fadeVolume", withObject: nil, afterDelay: 0.02)
        }
        else {
            self.performSelector("restoreVolume", withObject: nil, afterDelay: 0.5)
        }
    }
    func restoreVolume(){
        self.smartPlayer.player.volume=1
    }
    
    @IBAction func playAllButton(sender: AnyObject) {
        playAll=true
        nextSongID=0
        playNextSong()
        self.smartPlayer.dismissWhenFinished=false
        
        self.smartPlayer.finishedPlaying = {() in
            
            self.nextSongID++
            
            self.playNextSong()
        }
        
        self.smartPlayer.playIn(self)
    }
    @IBAction func shuffleButton(sender: AnyObject) {
        playAll=true
        shuffle=true
        self.smartPlayer.dismissWhenFinished=false
        let category="Audio"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let AudioDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        self.nextSongID=Int(arc4random_uniform(UInt32(unfold("\(AudioDataURL)|category|subcategories|\(self.categoryIndex)|media|count") as! Int)) + 1)
        playNextSong()
        
        self.smartPlayer.finishedPlaying = {() in
            
            let category="Audio"
            let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
            let AudioDataURL=categoriesDirectory+"/"+category+"?detailed=1"
            self.nextSongID=Int(arc4random_uniform(UInt32(unfold("\(AudioDataURL)|category|subcategories|\(self.categoryIndex)|media|count") as! Int)) + 1)
            self.playNextSong()
        }
        
        self.smartPlayer.playIn(self)
    }
    
    /*func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if (UIView.appearance().semanticContentAttribute == UISemanticContentAttribute.ForceRightToLeft){
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            if (cell != nil){
                return Int(50/cell!.frame.size.width)
            }
            return 10
        }
        return 0
    }*/
}
