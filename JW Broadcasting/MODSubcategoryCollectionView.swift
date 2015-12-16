//
//  MODSubcategoryCollectionView.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/4/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class MODSubcategoryCollectionView: SuperCollectionView {
    
    var categoryName=""
    var categoryCode=""
    let categoryLabel=UILabel()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        initSupport()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSupport()
    }
    
    func initSupport(){
        categoryLabel.font=UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        categoryLabel.frame=CGRectMake(self.contentInset.left , 0, self.frame.size.width-self.contentInset.left-self.contentInset.right, 40)
        categoryLabel.text=categoryName
        self.addSubview(categoryLabel)
    }
    
    override func prepare() {
        super.prepare()
        if (textDirection == .RightToLeft){//RTL alignment
            self.contentOffset=self.centerPointFor(CGPointMake(self.contentSize.width-self.frame.size.width+self.contentInset.right, 0))
        }
        
        
        categoryLabel.text=categoryName
        
        self.categoryLabel.text=categoryName
        
        self.performBatchUpdates({}, completion: { (finished:Bool) in
            if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
                let width=self.frame.size.width-self.contentInset.left-self.contentInset.right
                self.categoryLabel.frame=CGRectMake(self.contentSize.width-width-self.contentInset.right , 0, width, 40)
                self.categoryLabel.textAlignment=NSTextAlignment.Right
            }
            else {
                self.categoryLabel.frame=CGRectMake(self.contentInset.left , 0, self.frame.size.width-self.contentInset.left-self.contentInset.right, 40)
                self.categoryLabel.textAlignment=NSTextAlignment.Left
            }
            self.rightSide()
        })
        
        //self.performSelector("rightSide", withObject: nil, afterDelay: 1.0)
        
    }
    
    func rightSide(){
        
        if (textDirection == .RightToLeft){//RTL alignment
            self.contentOffset=self.centerPointFor(CGPointMake(self.contentSize.width-self.frame.size.width+self.contentInset.right, 0))
        }
    }
    
    override func cellShouldFocus(view: UIView, indexPath: NSIndexPath) {
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UILabel.self)){
                (subview as! UILabel).textColor=UIColor.whiteColor()
                //(subview as! UILabel).shadowColor=UIColor.blackColor()
                subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y+5, width: subview.frame.size.width, height: subview.frame.size.height)
            }
            if (subview.isKindOfClass(marqueeLabel.self)){
                (subview as! marqueeLabel).beginFocus()
            }
            if (subview.isKindOfClass(StreamView.self)){
                (subview as! StreamView).focus()
            }
        }
    }
    
    override func cellShouldLoseFocus(view: UIView, indexPath: NSIndexPath) {
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UILabel.self)){
                (subview as! UILabel).textColor=UIColor.darkGrayColor()
                subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y-5, width: subview.frame.size.width, height: subview.frame.size.height)
            }
            if (subview.isKindOfClass(marqueeLabel.self)){
                (subview as! marqueeLabel).endFocus()
            }
            if (subview.isKindOfClass(StreamView.self)){
                (subview as! StreamView).unfocus()
            }
        }
    }
    
    override var preferredFocusedView:UIView? {
        get {
            return self.cellAtIndex(NSIndexPath(forRow: 0, inSection: 0))
        }
    }
    
    override func didScroll() {
        if (textDirection == .RightToLeft){//RTL alignment
            let width=self.frame.size.width-self.contentInset.left-self.contentInset.right
            self.categoryLabel.frame=CGRectMake(-self.contentInset.right+self.contentOffset.x+60 , 0, width, 40)
        }
        else {
            categoryLabel.frame=CGRectMake( self.contentInset.left+self.contentOffset.x+60, 0, self.frame.size.width-self.contentInset.left-self.contentInset.right, 40)
        }
    }
    
}
