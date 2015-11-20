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
    
    /*
    - (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
    {
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    if (!attributes && [kind isEqualToString:CSStickyHeaderParallaxHeader]) {
    attributes = [CSStickyHeaderFlowLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    }
    return attributes;
    }
*/
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        print("supplementary!")
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)//super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)
        /*if (attributes != nil && elementKind == UICollectionElementKindSectionHeader){
            attributes
        }*/
        attributes.frame = CGRect(x: 0, y: 0, width: (self.collectionView?.frame.size.width)!, height: 50)
        
        return attributes
    }
    
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = super.layoutAttributesForElementsInRect(rect)!
        //let missingAttributes = NSMutableArray(array: super.layoutAttributesForElementsInRect(rect)!)
       // let offset = collectionView?.contentOffset
        var sections:[Int]=[]
        //var yBoost:CGFloat=0
        
        for attrs in attributes {
            
            if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
                attrs.frame=CGRect(x: (self.collectionView?.superview!.frame.size.width)!-attrs.frame.origin.x-((self.collectionView?.superview!.frame.size.width)!*0.7), y: attrs.frame.origin.y, width: attrs.frame.size.width, height: attrs.frame.height)
            }
            
            print("default attributes \(attrs.frame.origin.x)")
            
            attrs.frame=CGRect(x: (attrs.frame.origin.x), y: attrs.frame.origin.y+CGFloat(50*attrs.indexPath.section), width: attrs.frame.size.width, height: attrs.frame.height)
            
            if attrs.indexPath.row == 0 {
                sections.append(attrs.indexPath.section)
                //yBoost+=50
                let indexPath        = NSIndexPath(forItem: 0, inSection: attrs.indexPath.section)
                let layoutAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath)
                layoutAttributes?.frame=CGRect(x: (layoutAttributes?.frame.origin.x)!, y: attrs.frame.origin.y, width: (layoutAttributes?.frame.size.width)!, height: (layoutAttributes?.frame.size.height)!)
                attributes.append(layoutAttributes!)
            }
        }
        
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
