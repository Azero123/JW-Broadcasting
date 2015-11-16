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
}
