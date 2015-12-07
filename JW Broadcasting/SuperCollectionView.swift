//
//  SuperCollectionView.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/13/15.
//  Copyright © 2015 xquared. All rights reserved.
//

/*

Code for a custom UICollectionView that handles all it's own data and evnets.
This mostly is just for keeping code clean and not having 1 UIViewController that manages between 3+ different UICollectionViews.

The concept here is that the UICollectionViews will also recieve update events whenever a file is downloaded and conrent is modified.

INTENDED TO BE SUPERCLASSED


prepare()
Essentially an event to setup the content however this also acts as an update event so all the code inside of prepare() must be able to be run multiple times.

totalSections() -> Int
Number of sections in UICollectionView, same as numberOfSectionsInCollectionView(...) -> Int


totalItemsInSection(...) -> Int
Number of items in a section, same as collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int

sizeOfItemAtIndex() -> CGSize size of cell at index, same as collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize


supplementaryElement(...) -> UICollectionReusableView
This is intended to create Headers, Footers and decorative items inside the UICollectionView much like collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath)

Alternatives to supplementaryElement()
These preorganize whether the element is a header or footer coorespondingly.

headerForIndexPath(indexPath:NSIndexPath) -> UICollectionReusableView
footerForIndexPath(indexPath:NSIndexPath) -> UICollectionReusableView


cellAtIndex(indexPath:NSIndexPath) -> UICollectionViewCell This is intended to create UICollectionViewCells, same as collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell


Events called when focus changes either, focused or lose of focus correspondingly. Narrowed version of collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool
Use these events for any "hover" or focus effects.

cellShouldFocus(...)
cellShouldLoseFocus(...)




cellSelect(...) Event called upon cell chosen, same as collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool

*/



import UIKit

class SuperCollectionView: UICollectionView {
    func prepare(){
        /*

        Essentially an event to setup the content however this also acts as an update event so all the code inside of prepare() must be able to be run multiple times.
        
        Registers default cells and supplementary views so that their is a fall back if code is not implmeneted in superclass.
        
        */
    
        self.registerClass(UIView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "defaultHeader")
        self.registerClass(UIView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "defaultFooter")
        self.registerClass(UIView.self, forCellWithReuseIdentifier: "defaultCell")
    }
    
    func totalSections() -> Int {
        /*
        Number of sections in UICollectionView, same as numberOfSectionsInCollectionView(...) -> Int
        */
        return 0
    }
    
    func totalItemsInSection(section: Int) -> Int {
        /*
        Number of items in a section, same as collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
        */
        return 0
    }
    
    func sizeOfItemAtIndex(indexPath:NSIndexPath) -> CGSize{
        /*
        Size of cell at index, same as collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
        */
        return CGSize(width: 0, height: 0)
    }
    
    func supplementaryElement(kind: String, forIndexPath indexPath:NSIndexPath) -> UICollectionReusableView{
        /*
        This is intended to create Headers, Footers and decorative items inside the UICollectionView much like collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath)
        */
        
        if (kind==UICollectionElementKindSectionHeader){
            return headerForIndexPath(indexPath)
        }
        else {
            //UICollectionElementKindSectionFooter
            return footerForIndexPath(indexPath)
        }
    }
    
    func headerForIndexPath(indexPath:NSIndexPath) -> UICollectionReusableView{
        /*
        Used to create header elements
        */
        return self.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "defaultHeader", forIndexPath: indexPath)
        
    }
    
    func footerForIndexPath(indexPath:NSIndexPath) -> UICollectionReusableView{
        /*
        Used to create footer elements
        */
        return self.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "defaultFooter", forIndexPath: indexPath)
    }
    
    func cellAtIndex(indexPath:NSIndexPath) -> UICollectionViewCell{
        /*
        Used to create cell elements, same as
        collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
        */
        let cell: UICollectionViewCell = self.dequeueReusableCellWithReuseIdentifier("slide", forIndexPath: indexPath)
        return cell
    }
    
    func cellShouldFocus(view:UIView, indexPath:NSIndexPath){
        /*
        Used to create hover effect and update content upon focus.
        */
    }
    
    func cellShouldFocus(view:UIView, indexPath:NSIndexPath, previousIndexPath:NSIndexPath?){
        /*
        Used to create hover effect and update content upon focus with some extra data on the previous item.
        */
    }
    
    func cellShouldLoseFocus(view:UIView, indexPath:NSIndexPath){
        /*
        Used to cancel hover effect and update content upon unfocus.
        */
    }
    
    func cellSelect(indexPath:NSIndexPath){
        /*
        Select or chose event for a cell.
        */
    }
    
    func perferedFocus() -> NSIndexPath{
        return NSIndexPath(forRow: 0, inSection: 0)
    }
    
    func canSelectCellAtIndex(indexPath:NSIndexPath) -> Bool {
        return true
    }
    
    func layoutForCellAtIndex(indexPath:NSIndexPath, withPreLayout:UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        /*
        Defines the position and size of the indivigual cell.
        */
        
        
        var positionIndex=indexPath.row
        
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            positionIndex=(self.numberOfItemsInSection(indexPath.section))-indexPath.row-2
        }
        
        let layoutAttribute=withPreLayout
        layoutAttribute.frame=CGRectMake((self.contentInset.left)+((layoutAttribute.frame.size.width)*(self.collectionViewLayout as! CollectionViewHorizontalFlowLayout).spacingPercentile)*CGFloat(positionIndex), ((self.frame.size.height)-(layoutAttribute.frame.size.height))/2, (layoutAttribute.frame.size.width), (layoutAttribute.frame.size.height))
        
        return layoutAttribute
    }
    
    func centerPointFor(proposedContentOffset: CGPoint) -> CGPoint{

        /* optional method for subclasses (check SlideShow.swift)*/
        
        return proposedContentOffset
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        /*
        States that all the collectionViews only have 1 section.
        */
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        /*
        Headers, footers and decoorative items are processed in this method. SuperCollectionViews manage their own supplementary items so if UICollectionView is a SuperCollectionView let it handle itself.
        */
        
        let supplementaryItem:UICollectionReusableView?=nil
        
        if (collectionView.isKindOfClass(SuperCollectionView.self)){
            return (collectionView as! SuperCollectionView).supplementaryElement(kind, forIndexPath: indexPath)
        }
        
        return supplementaryItem!
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        /*
        This method delegates how many videos or media types are in a UICollectionView. SuperCollectionViews manage their own cell count so if UICollectionView is a SuperCollectionView let it handle itself.
        */
        
        if (collectionView.isKindOfClass(SuperCollectionView.self)){
            return (collectionView as! SuperCollectionView).totalItemsInSection(section)
        }
        print("[ERROR] not enough")
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        /*
        This method processes and delegates UICollectionViewCells. UICollectionView that are SuperCollectionViews manage their own cells so if UICollectionView is a SuperCollectionView let it handle itself.
        */
        
        if (collectionView.isKindOfClass(SuperCollectionView.self)){
            return (collectionView as! SuperCollectionView).cellAtIndex(indexPath)
        }
        print("[ERROR] THIS SHOULD NEVER HAPPEN! \(collectionView)")
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        /*
        This method defines the size of UICollectionViewCells. UICollectionView that are SuperCollectionViews manage their own cell sizes so if UICollectionView is a SuperCollectionView let it handle itself.
        */
        
        if (collectionView.isKindOfClass(SuperCollectionView.self)){
            return (collectionView as! SuperCollectionView).sizeOfItemAtIndex(indexPath)
        }
        /*
        Unknown collectionView so default.
        */
        return CGSizeMake(0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
        
        /*
        
        This method handles when the user moves focus over a UICollectionViewCell and/or UICollectionView.
        
        UICollectionView that are SuperCollectionViews manage their own focus events so if UICollectionView is a SuperCollectionView let it handle itself.
        
        Lastly if he LatestVideos or SlideShow collection view are focused move everything up so you can see them.
        */
        
        if (context.previouslyFocusedView?.superview!.isKindOfClass(SuperCollectionView.self) == true && context.previouslyFocusedIndexPath != nil){
            (context.previouslyFocusedView?.superview as! SuperCollectionView).cellShouldLoseFocus(context.previouslyFocusedView!, indexPath: context.previouslyFocusedIndexPath!)
        }
        if (context.nextFocusedView?.superview!.isKindOfClass(SuperCollectionView.self) == true && context.nextFocusedIndexPath != nil){
            (context.nextFocusedView?.superview as! SuperCollectionView).cellShouldFocus(context.nextFocusedView!, indexPath: context.nextFocusedIndexPath!)
            (context.nextFocusedView?.superview as! SuperCollectionView).cellShouldFocus(context.nextFocusedView!, indexPath: context.nextFocusedIndexPath!, previousIndexPath: context.previouslyFocusedIndexPath)
        }
        
        return true
    }
    
}
