//
//  VideoOnDemandController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/23/15.
//  Copyright © 2015 xquared. All rights reserved.
//


import UIKit

class VideoOnDemandController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var VideoCollectionView: UICollectionView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var BackgroundEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        The gradual contextual background effect is not blurred exactly to apples default we change the color a bit to be more apparent and noticable.
        */
        
        backgroundImageView.alpha=0.75
        BackgroundEffectView.alpha=0.99
        
        /*
        Prepareing the collection view by registering some of its generation abilities and setting the space between the cells customly.
        */
        
        self.VideoCollectionView.clipsToBounds=false
        self.VideoCollectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        self.VideoCollectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer")
        (self.VideoCollectionView.collectionViewLayout as! CollectionViewAlignmentFlowLayout).spacingPercentile=1.275
        
        /*
        
        Generate content for language.
        
        */
        
        renewContent()
    }
    
    var previousLanguageCode=languageCode
    
    override func viewWillAppear(animated: Bool) {
        
        /*
        The detail view controller of this view uses the semantic ForceRightToLeft. Incase the view was in RTL when it left we need to turn that off because this view manages all it's own RTL layouts.
        */
        
        UIView.appearance().semanticContentAttribute=UISemanticContentAttribute.ForceLeftToRight
        (self.tabBarController as! rootController).disableNavBarTimeOut=true
        /*
        The view may be reappearing so if the language has been changed since the view last was ran that we need to update the content to the new language.
        */
        if (previousLanguageCode != languageCode){
            renewContent()
        }
        previousLanguageCode=languageCode
        
        /*
        Old code for when TVOS 9.0 couldn't even handle change in view controllers properly if they were running methods in background.
        (Leave this incase we want to update the app to work in 9.0)
        */
        
        self.view.hidden=false
    }
    
    override func viewDidDisappear(animated: Bool) {
        /*
        Old code for when TVOS 9.0 couldn't even handle change in view controllers properly if they were running methods in background.
        (Leave this incase we want to update the app to work in 9.0)
        */
        self.view.hidden=true
    }
    
    func renewContent(){
        
        //http://mediator.jw.org/v1/categories/E/Audio?detailed=1
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let VODDataURL=categoriesDirectory+"/VideoOnDemand?detailed=1"
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            fetchDataUsingCache(VODDataURL, downloaded: {
                dispatch_async(dispatch_get_main_queue()) {
                    self.VideoCollectionView.reloadData()
                }
            })
        }
    }
    
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let category="VideoOnDemand"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        let response=unfold(categoryDataURL+"|category|subcategories|count") as? Int
        if (response == nil){
            return 0
        }
        return response!
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
        let category="VideoOnDemand"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        for subview in cell.contentView.subviews {
            if (subview.isKindOfClass(UIActivityIndicatorView.self)){
                subview.transform = CGAffineTransformMakeScale(2.0, 2.0)
                (subview as! UIActivityIndicatorView).startAnimating()
            }
            if (subview.isKindOfClass(UIImageView.self)){
                
                let imageView=subview as! UIImageView
                imageView.image=UIImage()
                let imageURL=unfold(categoryDataURL+"|category|subcategories|\(indexPath.row)|images|wss|lg") as? String
                
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
                }
            }
            if (subview.isKindOfClass(UILabel.self)){
                (subview as! UILabel).text=unfold(categoryDataURL+"|category|subcategories|\(indexPath.row)|name") as! NSString as String
            }
        }
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        let category="VideoOnDemand"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        categoryToGoTo=unfold(categoryDataURL+"|category|subcategories|\(indexPath.row)|key") as! String
        categoryIndexToGoTo=indexPath.row
        return true
    }
    
    var categoryIndexToGoTo:Int=0
    var categoryToGoTo=""
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*
        Let the subcategory View Controller know what the desired category is to display.
        */
        
        if (segue.destinationViewController.isKindOfClass(VideoOnDemandCategory.self)){
            (segue.destinationViewController as! VideoOnDemandCategory).categoryIndex=categoryIndexToGoTo
            (segue.destinationViewController as! VideoOnDemandCategory).category=categoryToGoTo
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        /*
        This handles the frame sizes of the previews without destroying ratios.
        */
        
        let multiplier:CGFloat=0.80
        let ratio:CGFloat=1.77777777777778
        let width:CGFloat=360
        return CGSize(width: width*ratio*multiplier, height: width*multiplier) //Currently set to 512,288
    }
    
    func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        /*
        
        This method handles when the user moves focus over a UICollectionViewCell and/or UICollectionView.
        
        UICollectionView that are SuperCollectionViews manage their own focus events so if UICollectionView is a SuperCollectionView let it handle itself.
        
        Lastly if he LatestVideos or SlideShow collection view are focused move everything up so you can see them.
        */
        
        if (context.nextFocusedView != nil && context.previouslyFocusedView?.superview!.isKindOfClass(SuperCollectionView.self) == true && context.previouslyFocusedIndexPath != nil){
            (context.previouslyFocusedView?.superview as! SuperCollectionView).cellShouldLoseFocus(context.previouslyFocusedView!, indexPath: context.previouslyFocusedIndexPath!)
            
        }
        if (context.nextFocusedView?.superview!.isKindOfClass(SuperCollectionView.self) == true && context.nextFocusedIndexPath != nil){
            
            (context.nextFocusedView?.superview as! SuperCollectionView).cellShouldFocus(context.nextFocusedView!, indexPath: context.nextFocusedIndexPath!)
            (context.nextFocusedView?.superview as! SuperCollectionView).cellShouldFocus(context.nextFocusedView!, indexPath: context.nextFocusedIndexPath!, previousIndexPath: context.previouslyFocusedIndexPath)
            
        }
    }
    
    
}
