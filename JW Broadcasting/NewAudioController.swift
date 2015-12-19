//
//  NewAudioController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/14/15.
//  Copyright © 2015 xquared. All rights reserved.
//

//
//  MediaOnDemandController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/23/15.
//  Copyright © 2015 xquared. All rights reserved.
//


import UIKit

class NewAudioController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var MediaCollectionView: UICollectionView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var BackgroundEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.tabBarController as! rootController).disableNavBarTimeOut=true
        
        backgroundImageView.alpha=0.75
        BackgroundEffectView.alpha=0.99
        
        self.MediaCollectionView.clipsToBounds=false
        self.MediaCollectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        self.MediaCollectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer")
        (self.MediaCollectionView.collectionViewLayout as! CollectionViewAlignmentFlowLayout).spacingPercentile=1.35
        renewContent()
    }
    
    let images=["newsongs-singtojehovah","piano-singtojehovah","vocals-singtojehovah","kingdommelodies","drama","readings"]
    
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
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let AudioDataURL=categoriesDirectory+"/Audio?detailed=1"
        
        fetchDataUsingCache(AudioDataURL, downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
                    self.MediaCollectionView.reloadData()
            }
        })
    }
    
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let category="Audio"
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
        
        let category="Audio"
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
                
                let imageURL=unfold(categoryDataURL+"|category|subcategories|\(indexPath.row)|images|sqr|lg") as? String
                
                imageView.userInteractionEnabled = true
                imageView.adjustsImageWhenAncestorFocused = true
                imageView.image=UIImage(named: images[indexPath.row])
                if (imageURL != nil && imageURL != ""){
                    
                    fetchDataUsingCache(imageURL!, downloaded: {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let image=imageUsingCache(imageURL!)
                            (subview as! UIImageView).image=image
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
        
        let category="Audio"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        categoryToGoTo=unfold(categoryDataURL+"|category|subcategories|\(indexPath.row)|key") as! String
        categoryIndexToGoTo=indexPath.row
        return true
    }
    
    var categoryIndexToGoTo:Int=0
    var categoryToGoTo=""
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.destinationViewController.isKindOfClass(AudioCategoryController.self)){
            (segue.destinationViewController as! AudioCategoryController).categoryIndex=categoryIndexToGoTo
            //(segue.destinationViewController as! AudioCategoryController).category=categoryToGoTo
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let multiplier:CGFloat=1
        let ratio:CGFloat=1
        let width:CGFloat=360
        return CGSize(width: width*ratio*multiplier, height: width*multiplier)
    }
    
    func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
        return true
        
    }
    
    
    func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        /*
        
        This method handles when the user moves focus over a UICollectionViewCell and/or UICollectionView.
        
        UICollectionView that are SuperCollectionViews manage their own focus events so if UICollectionView is a SuperCollectionView let it handle itself.
        
        Lastly if he LatestVideos or SlideShow collection view are focused move everything up so you can see them.
        */
        
        if (context.nextFocusedView != nil && context.previouslyFocusedView?.superview!.isKindOfClass(SuperCollectionView.self) == true && context.previouslyFocusedIndexPath != nil){
            if (self == context.nextFocusedView) {
                /*[coordinator addCoordinatedAnimations:^{
                // focusing animations
                } completion:^{
                // completion
                }];*/
            } else if (self == context.previouslyFocusedView) {
                /*[coordinator addCoordinatedAnimations:^{
                // unfocusing animations
                } completion:^{
                // completion
                }];*/
            }
            (context.previouslyFocusedView?.superview as! SuperCollectionView).cellShouldLoseFocus(context.previouslyFocusedView!, indexPath: context.previouslyFocusedIndexPath!)
            coordinator.addCoordinatedAnimations({
                }, completion: nil)
            
        }
        if (context.nextFocusedView?.superview!.isKindOfClass(SuperCollectionView.self) == true && context.nextFocusedIndexPath != nil){
            
            
            coordinator.addCoordinatedAnimations({
                
                (context.nextFocusedView?.superview as! SuperCollectionView).cellShouldFocus(context.nextFocusedView!, indexPath: context.nextFocusedIndexPath!)
                (context.nextFocusedView?.superview as! SuperCollectionView).cellShouldFocus(context.nextFocusedView!, indexPath: context.nextFocusedIndexPath!, previousIndexPath: context.previouslyFocusedIndexPath)
                
                }, completion: nil)
        }
    }
    
}
