//
//  CollectionViewHorizontalFlowLayout.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/25/15.
//  Copyright © 2015 Austin Zelenka. All rights reserved.
//


/*
This is some code for horizontal scrolling in UICollectionViews.
After trying to use the default parameters for horizontal code it wasn't quiet living up to expectations.

layoutAttributesForItemAtIndexPath(...) defines the position and size of the indivigual cell.

layoutAttributesForElementsInRect(...) This was modified because previously layoutAttributesForItemAtIndexPath(...) was not being called for our needs consistently. Now all elements are laid out so that we don't have errors with users panning/scrolling through cells too quickly for the items to cells.
WARNING It appears that some cases this code crashes do to not "reusing" layout attributes. Come back to this later but this is low priority because it is dificult to reproduce and rarely occuring.

targetContentOffsetForProposedContentOffset(...) This corrects center cells for our custom layout positions.
*/



import UIKit

class CollectionViewHorizontalFlowLayout: UICollectionViewFlowLayout {
    
    var spacingPercentile:CGFloat=1
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        /*
        Defines the position and size of the indivigual cell.
        */
    
        
        var positionIndex=indexPath.row
        
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            positionIndex=(self.collectionView?.numberOfItemsInSection(indexPath.section))!-indexPath.row-1
        }
        
        let layoutAttribute=super.layoutAttributesForItemAtIndexPath(indexPath)
        
        layoutAttribute?.frame=CGRectMake((self.collectionView?.contentInset.left)!+((layoutAttribute?.frame.size.width)!*spacingPercentile)*CGFloat(positionIndex), ((self.collectionView?.frame.size.height)!-(layoutAttribute?.frame.size.height)!)/2, (layoutAttribute?.frame.size.width)!, (layoutAttribute?.frame.size.height)!)
        
        return layoutAttribute
    }
   
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        /*
        This was modified because previously layoutAttributesForItemAtIndexPath(...) was not being called for our needs consistently. Now all elements are laid out so that we don't have errors with users panning/scrolling through cells too quickly for the items to cells.
        WARNING It appears that some cases this code crashes do to not "reusing" layout attributes. Come back to this later but this is low priority because it is dificult to reproduce and rarely occuring.
        
        Code creates an array fills it with all layouts for all cells in the UICollectionView that this flow layour represents and hands back to UICollectionView code.
        */
        var attributes:Array<UICollectionViewLayoutAttributes>=[]
        
        for (var i=0;i<self.collectionView?.numberOfItemsInSection(0);i++){
            attributes.append(self.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: i, inSection: 0))!)
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        /*
        To ensure that whenever something changes in the UICollectionView, everything gets updated.
        */
        return true
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        /*
        So Apples code does not necissarily know how to calculate to center our UICollectionViewCells so if we implement this method we can change where apple things the point to center is.
        First we calculate how wide the cells are roughly (probably could use some improvements but for now this is fine as it works until there are dozens of featured items). Then using that width we discover to which cell index the code is originally taking us. Then we calculate where that cell index would be for our code and return it.
        */
        
        let cellWidth=(self.collectionView?.delegate as! HomeController).collectionView(self.collectionView!, layout: self, sizeForItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0)).width*spacingPercentile
        
        let itemIndex=round((proposedContentOffset.x+((self.collectionView?.frame.size.width)!-cellWidth)/2)/cellWidth)
        return CGPoint(x: itemIndex*(cellWidth)-((self.collectionView?.frame.size.width)!-cellWidth)/2
            , y: 0)
    }
    
}
