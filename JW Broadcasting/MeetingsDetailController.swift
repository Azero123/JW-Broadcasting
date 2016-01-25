//
//  MeetingsDetailController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 1/19/16.
//  Copyright © 2016 xquared. All rights reserved.
//

import UIKit

class MeetingsDetailController: UIViewController {

    var categoryNumber=0 // Internal identifier for category
    
    let videos=unfold(NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("languageVideos", ofType: nil)!), instructions: []) as? [NSDictionary] // Download the video data
    
    var preparedVideos:[NSDictionary]=[] // Variable for run time organized video data
    
    let player=SuperMediaPlayer()
    
    @IBOutlet weak var VideoHorizontalView: UICollectionView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var NoVideosLabel: UILabel!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (self.VideoHorizontalView.collectionViewLayout as! CollectionViewHorizontalFlowLayout).spacingPercentile=1.5
        self.VideoHorizontalView.clipsToBounds=false
        /*
        Display the appropriate title text and picture for the chosen category.
        */
        
        if (categoryNumber == 1){
            categoryTitleLabel.text="Meetings"
            categoryImageView.image=UIImage(named: "meetings.jpeg")
        }
        else if (categoryNumber == 2){
            categoryTitleLabel.text="Assemblies"
            categoryImageView.image=UIImage(named: "assemblies.jpeg")
        }
        else if (categoryNumber == 3){
            categoryTitleLabel.text="Conventions"
            categoryImageView.image=UIImage(named: "conventions.jpeg")
            
        }
        
        
        /*
        Videos in Stream.JW.org are not organized.
        Using the data for the videos contained in self.videos we sort out only the videos that pretain to this section (Weekly Meetings, Assemblies, Regional Conventions).
        
        */
        
        for video in videos! {
            if ((video.objectForKey("data")!.objectForKey("section") as! String) == "\(categoryNumber)"){
                preparedVideos.append(video)
            }
        }
        
        /*
        If there are no videos in this section then display the text for no videos.
        
        */
        
        if (preparedVideos.count==0){
            NoVideosLabel.hidden=false
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        /*
        We only are displaying 1 section of content and the table view needs to know that.
        */
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*
        Give the table view the number of videos in the section so that it generates the right amount of rows.
        */
        return preparedVideos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /*
        Generate a row with the title text provided from Stream.JW.org (Exp. Circuit Assembly with Branch Representative - Morning)
        */
        
        let cell=tableView.dequeueReusableCellWithIdentifier("item", forIndexPath: indexPath)
        cell.textLabel?.text=preparedVideos[indexPath.row].objectForKey("title") as? String
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        /*
        The rows by default seem rather small for TVOS so we bump up the size.
        */
        return 90
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        /*
        Using our custom player we play the hls formatted file.
        HLS is nicer than a regular mp4 because it provides bit rate adjustments.
        Sadly at this time tv.jw.org does not use HLS.
        */
        
        player.updatePlayerUsingString(unfold(preparedVideos, instructions:  [indexPath.row,"data","vod_url_hls"]) as! String)
        player.playIn(self)
        
    }
    
    
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 6
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var header:UICollectionReusableView?=nil
        
        if (kind == UICollectionElementKindSectionHeader){
            header=collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath)
        }
        if (kind == UICollectionElementKindSectionFooter) {
            header=collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "footer", forIndexPath: indexPath)
            
        }
        
        return header!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("category", forIndexPath: indexPath)
        cell.alpha=1
        cell.tag=indexPath.row
        cell.clipsToBounds=false
        
        for subview in cell.contentView.subviews {
            if (subview.isKindOfClass(UIActivityIndicatorView.self)){
                subview.transform = CGAffineTransformMakeScale(2.0, 2.0)
                (subview as! UIActivityIndicatorView).startAnimating()
            }
            if (subview.isKindOfClass(UIImageView.self)){
                
                let imageView=subview as! UIImageView
                imageView.image=UIImage(named: "Day-1")
                imageView.userInteractionEnabled = true
                imageView.adjustsImageWhenAncestorFocused = true
                /*let imageURL=unfold(categoryDataURL+"|category|subcategories|\(indexPath.row)|images|wss|lg") as? String
                
                imageView.userInteractionEnabled = true
                imageView.adjustsImageWhenAncestorFocused = true
                imageView.alpha=0.2
                if (imageURL != nil && imageURL != ""){
                
                fetchDataUsingCache(imageURL!, downloaded: {
                
                dispatch_async(dispatch_get_main_queue()) {
                if (cell.tag==indexPath.row){
                imageView.alpha=1
                let image=imageUsingCache(imageURL!)
                (subview as! UIImageView).image=image
                }
                }
                })
                }*/
            }
            if (subview.isKindOfClass(UILabel.self)){
                (subview as! UILabel).text="Day-1"
            }
        }
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        /*
        This handles the frame sizes of the previews without destroying ratios.
        */
        
        let multiplier:CGFloat=1.0
        let ratio:CGFloat=0.8
        let width:CGFloat=250
        return CGSize(width: width*multiplier, height: width*ratio*multiplier) //Currently set to 512,288
    }
}
