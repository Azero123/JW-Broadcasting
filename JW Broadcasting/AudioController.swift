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

class AudioController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var MediaCollectionView: UICollectionView!
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
        
        self.MediaCollectionView.clipsToBounds=false
        self.MediaCollectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        self.MediaCollectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer")
        (self.MediaCollectionView.collectionViewLayout as! CollectionViewAlignmentFlowLayout).spacingPercentile=1.35
        /*
        
        Generate content for language.
        
        */
        renewContent()
    }
    let images=[
        "NewSongs":"newsongs-singtojehovah",
        "Piano":"piano-singtojehovah",
        "Vocal":"vocals-singtojehovah",
        "KingdomMelodies":"kingdommelodies",
        "Dramas":"drama",
        "DramaticBibleReadings":"readings"
    ]
    
    let SLImages=[
        "NewSongs":"newsongs-singtojehovah",
        "Piano":"piano-singtojehovah",
        "Vocal":"vocals-singtojehovah",
        "KingdomMelodies":"kingdommelodies",
        "Dramas":"drama-jwblue",
        "DramaticBibleReadings":"dramaticbiblereading-jwblue"
    ]
    
    var previousLanguageCode=languageCode
    
    override func viewWillAppear(animated: Bool) {
        UIView.appearance().semanticContentAttribute=UISemanticContentAttribute.ForceLeftToRight
        if (previousLanguageCode != languageCode){
            renewContent()
        }
        previousLanguageCode=languageCode
        (self.tabBarController as! rootController).disableNavBarTimeOut=true
        
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
        
        let extraction=titleExtractor(unfold(categoryDataURL+"|category|subcategories|\(indexPath.row)|name") as! String)
        
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
                
                
                let key=unfold(categoryDataURL+"|category|subcategories|\(indexPath.row)|key") as! String
                imageView.image=UIImage(named: images[key]!)
                if (languageFromCode(languageCode)!["isSignLanguage"]?.boolValue == true){
                    imageView.image=UIImage(named: SLImages[key]!)
                }
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
                if ((subview as! UILabel).tag==0){
                    (subview as! UILabel).text=extraction["correctedTitle"]
                }
                if ((subview as! UILabel).tag==1){
                    (subview as! UILabel).text=extraction["subTitle"]
                }
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
        
        if (context.nextFocusedView != nil && context.previouslyFocusedView != nil && context.previouslyFocusedView?.superview != nil && context.previouslyFocusedView?.superview!.isKindOfClass(SuperCollectionView.self) == true && context.previouslyFocusedIndexPath != nil){
            
            (context.previouslyFocusedView?.superview as! SuperCollectionView).cellShouldLoseFocus(context.previouslyFocusedView!, indexPath: context.previouslyFocusedIndexPath!)
        }
        if (context.nextFocusedView?.superview!.isKindOfClass(SuperCollectionView.self) == true && context.nextFocusedIndexPath != nil){
            
            (context.nextFocusedView?.superview as! SuperCollectionView).cellShouldFocus(context.nextFocusedView!, indexPath: context.nextFocusedIndexPath!)
            (context.nextFocusedView?.superview as! SuperCollectionView).cellShouldFocus(context.nextFocusedView!, indexPath: context.nextFocusedIndexPath!, previousIndexPath: context.previouslyFocusedIndexPath)
        }
    }
    
}
