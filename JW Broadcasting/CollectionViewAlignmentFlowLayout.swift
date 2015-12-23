//
//  CollectionViewAlignmentFlowLayout.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/18/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class CollectionViewAlignmentFlowLayout: UICollectionViewFlowLayout {
    var spacingPercentile:CGFloat=1
    var headerSpace:CGFloat=50
    var headerBottomSpace:CGFloat=25
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        /*
        Defines the position and size of the indivigual cell.
        */
        
        
        let layoutAttribute=super.layoutAttributesForItemAtIndexPath(indexPath)?.copy() as! UICollectionViewLayoutAttributes
        
        /*
        Handles right to left placement of items. Does this by reversing the math (Getting the far right distance and moving the attributes back the normal distance plus their width instead of from the left and adding both.)
        */
        
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            layoutAttribute.frame=CGRect(x: (self.collectionView?.frame.size.width)!-(layoutAttribute.frame.origin.x)-(layoutAttribute.frame.size.width), y: (layoutAttribute.frame.origin.y), width: (layoutAttribute.frame.size.width), height: (layoutAttribute.frame.size.height))
        }
        
        
        return layoutAttribute
    }
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        /*
        
        Supplementary item code is handled differently for UICollectionViewFlowLayout then it's subclasses?
        I was unable to do so without creating code to tell it where to add the items. This just creates the attributes without a position.
        
        */
        
        
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
        attributes.frame = CGRect(x: 0, y: 0, width: (self.collectionView?.frame.size.width)!, height: 50)
        
        return attributes
    }
    
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        /*
        Because previously layoutAttributesForItemAtIndexPath(...) was not being called for our needs consistently. Now all elements are laid out so that we don't have errors with users panning/scrolling through cells too quickly for the items to cells.*/
        
        var attributes:Array<UICollectionViewLayoutAttributes>=super.layoutAttributesForElementsInRect(rect)!
        if (self.collectionView?.numberOfSections()>0){
            for (var i=0;i<self.collectionView?.numberOfItemsInSection(0);i++){
                attributes.append(self.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: i, inSection: 0))!)
            }
        }
        
        
        for attrs in attributes {
            /*
            Handles right to left placement of items. Does this by reversing the math (Getting the far right distance and moving the attributes back the normal distance plus their width instead of from the left and adding both.)
            */
            /*
            if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            attrs.frame=CGRect(
            x: self.collectionView!.frame.size.width-attrs.frame.origin.x,
            y: attrs.frame.origin.y,
            width: attrs.frame.size.width,
            height: attrs.frame.height)
            }*/
            /*
            Calculates the vertical position of the items using spacgingPercentile and the offset added by section headers.
            */
            
            attrs.frame=CGRect(x: (attrs.frame.origin.x), y: attrs.frame.origin.y*spacingPercentile+CGFloat(headerSpace*CGFloat(attrs.indexPath.section+1))-25, width: attrs.frame.size.width, height: attrs.frame.height)
            
            /*
            
            Whenever the first item for the section is being generated it first adds in the section header in it's place (roughly).
            
            */
            
            if attrs.indexPath.row == 0 {
                let indexPath        = NSIndexPath(forItem: 0, inSection: attrs.indexPath.section)
                let layoutAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath)
                layoutAttributes?.frame=CGRect(x: (layoutAttributes?.frame.origin.x)!, y: attrs.frame.origin.y-headerSpace+headerBottomSpace, width: (layoutAttributes?.frame.size.width)!, height: (layoutAttributes?.frame.size.height)!)
                attributes.append(layoutAttributes!)
            }
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func collectionViewContentSize() -> CGSize {
        
        /*
        This calculates the content height for the collection view for our code so it has enough space to scroll.
        To do this we account for how many cells there are based on the suggested content height then we multiply the actual space the cells take up by that number then we add the height all the headers take up.
        */
        
        
        var layout=CGSize(width: 0,height: 0)
        if ((self.collectionView?.delegate?.isKindOfClass(CategoryController.self)) == true){
            layout=(self.collectionView!.delegate as! CategoryController).collectionView(self.collectionView!, layout: self, sizeForItemAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        }
        else if ((self.collectionView?.delegate?.isKindOfClass(MediaOnDemandController.self)) == true){
            
            print((self.collectionView!.delegate as! MediaOnDemandController).collectionView(self.collectionView!, layout: self, sizeForItemAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)))
            
            //self.collectionView.
            return CGSize(width: (self.collectionView?.frame.size.width)!, height: 1500)
            //layout=(self.collectionView!.delegate as! MediaOnDemandController).collectionView(self.collectionView!, layout: self, sizeForItemAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        }
        else if ((self.collectionView?.delegate?.isKindOfClass(AudioController.self)) == true){
            
            print((self.collectionView!.delegate as! AudioController).collectionView(self.collectionView!, layout: self, sizeForItemAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)))
            
            //self.collectionView.
            return CGSize(width: (self.collectionView?.frame.size.width)!, height: 500)
            //layout=(self.collectionView!.delegate as! MediaOnDemandController).collectionView(self.collectionView!, layout: self, sizeForItemAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        }
        let verticalRowCount=ceil(super.collectionViewContentSize().height/(layout.height))
        
        let headerHeight=layoutAttributesForSupplementaryViewOfKind( UICollectionElementKindSectionHeader , atIndexPath: NSIndexPath(forRow: 0, inSection: 0))?.frame.size.height
        let accumulativeHeaderHeight=CGFloat((self.collectionView?.numberOfSections())!)*headerHeight!
        
        let completedContentSize=CGSize(width: super.collectionViewContentSize().width, height: (layout.height)*spacingPercentile*verticalRowCount+accumulativeHeaderHeight)
        
        return completedContentSize
    }
}
