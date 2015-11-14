//
//  SuperCollectionView.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/13/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class SuperCollectionView: UICollectionView {
    func prepare(){
    
        self.registerClass(UIView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "defaultHeader")
        self.registerClass(UIView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "defaultFooter")
        self.registerClass(UIView.self, forCellWithReuseIdentifier: "defaultCell")
    }
    
    func supplementaryElement(kind: String, forIndexPath indexPath:NSIndexPath) -> UICollectionReusableView{
        print("some supplementary element")
        if (kind==UICollectionElementKindSectionHeader){
            return headerForIndexPath(indexPath)
        }
        else {
            //UICollectionElementKindSectionFooter
            return footerForIndexPath(indexPath)
        }
    }
    
    func headerForIndexPath(indexPath:NSIndexPath) -> UICollectionReusableView{
        return self.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "defaultHeader", forIndexPath: indexPath)
        
    }
    
    func footerForIndexPath(indexPath:NSIndexPath) -> UICollectionReusableView{
        return self.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "defaultFooter", forIndexPath: indexPath)
    }
    
    func totalSections() -> Int {
        return 0
    }
    
    func totalItemsInSection(section: Int) -> Int {
        return 0
    }
    
    func sizeOfItemAtIndex(indexPath:NSIndexPath) -> CGSize{
        return CGSize(width: 0, height: 0)
    }
    
    func cellAtIndex(indexPath:NSIndexPath) -> UICollectionViewCell{
        let cell: UICollectionViewCell = self.dequeueReusableCellWithReuseIdentifier("slide", forIndexPath: indexPath)
        return cell
    }
    
    func cellShouldFocus(view:UIView, indexPath:NSIndexPath){
    }
    
    func cellShouldLoseFocus(view:UIView, indexPath:NSIndexPath){
    }
    
    func cellSelect(indexPath:NSIndexPath){
        
    }
}
