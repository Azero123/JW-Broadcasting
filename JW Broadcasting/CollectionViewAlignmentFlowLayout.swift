//
//  CollectionViewAlignmentFlowLayout.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/18/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class CollectionViewAlignmentFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        /*
        Defines the position and size of the indivigual cell.
        */
        
        let layoutAttribute=super.layoutAttributesForItemAtIndexPath(indexPath)
        
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            layoutAttribute?.frame=CGRect(x: (self.collectionView?.frame.size.width)!-(layoutAttribute?.frame.origin.x)!, y: (layoutAttribute?.frame.origin.y)!, width: (layoutAttribute?.frame.size.width)!, height: (layoutAttribute?.frame.size.height)!)
        }
        
        
        //layoutAttribute?.frame=CGRectMake((self.collectionView?.contentInset.left)!+((layoutAttribute?.frame.size.width)!*spacingPercentile)*CGFloat(positionIndex), ((self.collectionView?.frame.size.height)!-(layoutAttribute?.frame.size.height)!)/2, (layoutAttribute?.frame.size.width)!, (layoutAttribute?.frame.size.height)!)
        
        return layoutAttribute
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = super.layoutAttributesForElementsInRect(rect)! 
        
        let offset = collectionView?.contentOffset
        
        
        for attrs in attributes {
            if attrs.representedElementKind == nil {
                let indexPath        = NSIndexPath(forItem: 0, inSection: attrs.indexPath.section)
                let layoutAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath)
                
                attributes.append(layoutAttributes!)
            }
        }
        /*
        for attrs in attributes {
            if attrs.representedElementKind == nil {
                continue
            }
            
            if attrs.representedElementKind == UICollectionElementKindSectionHeader {
                
                var headerRect = attrs.frame
                headerRect.size.height = 100
                headerRect.origin.y = offset!.y
                attrs.frame = headerRect
                attrs.zIndex = 1024
                break
            }
        }
        */
        return attributes
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSizeMake(UIScreen.mainScreen().bounds.width, 40)
    }
}
