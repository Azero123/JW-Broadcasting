//
//  MediaOnDemandController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/23/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class MediaOnDemandController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var MediaCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var previousLanguageCode=languageCode
    
    override func viewWillAppear(animated: Bool) {
        if (previousLanguageCode != languageCode){
            renewContent()
        }
        previousLanguageCode=languageCode
        
        self.view.hidden=false
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.view.hidden=true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func renewContent(){
        
        //http://mediator.jw.org/v1/categories/E/Audio?detailed=1
        let category="VideoOnDemand"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        fetchDataUsingCache(categoryDataURL, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                self.MediaCollectionView.reloadData()
            }
        })
    }
    

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var header:UICollectionReusableView?=nil
        
        if (kind == UICollectionElementKindSectionHeader){
            
            
        }
        if (kind == UICollectionElementKindSectionFooter) {
            header=collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "footer", forIndexPath: indexPath)
            
        }
        
        return header!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("video", forIndexPath: indexPath)
        cell.alpha=1
        /*
        
        if (imageURL == ""){
            let sizes=unfold(imageRatios, instructions: [imageRatios.allKeys.first!]) as? NSDictionary
            imageURL=unfold(sizes, instructions: [sizes!.allKeys.last!]) as? String
        }
        
        for subview in cell.contentView.subviews {
            if (subview.isKindOfClass(UIImageView.self)){
                
                fetchDataUsingCache(imageURL!, downloaded: {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let image=imageUsingCache(imageURL!)
                        
                        var ratio=(image?.size.width)!/(image?.size.height)!
                        (subview as! UIImageView).frame=CGRect(x: (cell.frame.size.width-((cell.frame.size.height-60)*ratio))/2, y: 0, width: (cell.frame.size.height-60)*ratio, height: (cell.frame.size.height-60))
                        
                        if (image?.size.width>(image!.size.height)){
                            ratio=(image?.size.height)!/(image?.size.width)!
                            (subview as! UIImageView).frame=CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.width*ratio)
                        }
                        
                        (subview as! UIImageView).image=image
                        (subview as! UIImageView).frame=CGRect(x: (cell.frame.size.width-subview.frame.size.width)/2, y: (cell.frame.size.height-subview.frame.size.height)/2, width: subview.frame.size.width, height: subview.frame.size.height)
                        //(subview as! UIImageView).contentMode = .ScaleToFill
                        UIView.animateWithDuration(0.5, animations: {
                            subview.alpha=1
                        })
                        
                    }
                })
                
                subview.alpha=0
                subview.userInteractionEnabled = true
                (subview as! UIImageView).adjustsImageWhenAncestorFocused = true
                subview.layer.cornerRadius=5
            }
            if (subview.isKindOfClass(UILabel.self)){
                
                /*
                
                Code for removing the repetitive JW Broadcasting - before all the names of all the monthly broadcasts.
                */
                
                var title=(retrievedVideo!.objectForKey("title") as? NSString)!
                
                let replacementStrings=["JW Broadcasting —","JW Broadcasting—"]
                
                for replacement in replacementStrings {
                    
                    if (title.containsString(replacement)){
                        
                        title=title.stringByReplacingOccurrencesOfString(replacement, withString: "")
                        title=title.stringByAppendingString(" Broadcast")
                        /* replace " Broadcast" with a key from:
                        base+"/"+version+"/languages/"+languageCode+"/web"
                        so that this works with foreign languages*/
                    }
                    
                }
                
                let titleLabel=(subview as! UILabel)
                titleLabel.text=title as String
                titleLabel.layer.shadowColor=UIColor.darkGrayColor().CGColor
                titleLabel.layer.shadowRadius=5
                titleLabel.numberOfLines=3
                
            }
            if (subview.isKindOfClass(UIActivityIndicatorView.self)){
                (subview as! UIActivityIndicatorView).startAnimating()
                subview.transform = CGAffineTransformMakeScale(2.0, 2.0)
            }
        }
        
        
        */
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
        
        /*
        This method provides the blue highlighting to the cells and sets variable selectedSlideShow:Bool.
        If selectedSlideShow==true (AKA the user is interacting with the slideshow) then the slide show will not roll to next slide.
        
        */
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    }

    

    
}
