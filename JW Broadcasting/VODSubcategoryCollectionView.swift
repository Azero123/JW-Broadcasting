//
//  VODSubcategoryCollectionView.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/4/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class VODSubcategoryCollectionView: SuperCollectionView {
    
    let titlePosition:CGFloat=0
    
    var categoryName=""
    var _categoryCode = ""
    var categoryCode:String {
        set (newValue){
            _categoryCode=newValue
            
            let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
            let categoryDataURL=categoriesDirectory+"/"+newValue+"?detailed=1"
            fetchDataUsingCache(categoryDataURL, downloaded: nil)
        }
        get {
            return _categoryCode
        }
    }
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
        self.contentInset=UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
        categoryLabel.font=UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        setCategoryLabelLayout()
        categoryLabel.text=categoryName
        self.addSubview(categoryLabel)
        setCategoryLabelLayout()
        if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
            self.categoryLabel.textAlignment=NSTextAlignment.Right
        }
        else {
            self.categoryLabel.textAlignment=NSTextAlignment.Left
        }
    }
    
    override func prepare() {
        super.prepare()
        if (textDirection == .RightToLeft){//RTL alignment
            self.contentOffset=self.centerPointFor(CGPointMake(self.contentSize.width-self.frame.size.width+self.contentInset.right, 0))
        }
        
        
        categoryLabel.text=categoryName
        
        self.categoryLabel.text=categoryName
        
        self.performBatchUpdates({}, completion: { (finished:Bool) in
            self.setCategoryLabelLayout()
            if (textDirection == UIUserInterfaceLayoutDirection.RightToLeft){
                self.categoryLabel.textAlignment=NSTextAlignment.Right
            }
            else {
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            if (view==UIScreen.mainScreen().focusedView){
                
                UIView.transitionWithView((self.delegate as! VideoOnDemandCategory).backgroundImage, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                    
                    var indexPathRow=indexPath.row
                    if (self.categoryCode.containsString("Featured")&&streamingCell){
                        if (indexPathRow==0){
                            return
                        }
                        indexPathRow=indexPathRow-1
                    }
                    
                    let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
                    let categoryDataURL=categoriesDirectory+"/"+self.categoryCode+"?detailed=1"
                    let imageURL=unfold(nil, instructions: [
                        categoryDataURL,
                        "category",
                        "media",
                        "\(indexPathRow)",
                        "images",["lsr","wss","cvr","lss","wsr","pss","pns",""],
                        ["lg","md","sm","xs",""]]) as? String
                    if (imageURL != nil){
                        (self.delegate as! VideoOnDemandCategory).backgroundImage.image=imageUsingCache(imageURL!)
                    }
                    }, completion: nil)
            }
        }
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UILabel.self)){
                (subview as! UILabel).textColor=UIColor.whiteColor()
                //(subview as! UILabel).shadowColor=UIColor.blackColor()
                subview.layoutIfNeeded()
                subview.frame=CGRect(x: subview.frame.origin.x, y: view.bounds.size.height/2+10, width: subview.frame.size.width, height: subview.frame.size.height)
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
    
    override func didScroll() {
        
        if (self.contentSize.width<self.frame.size.width){
            if (self.contentOffset.x != -self.contentInset.left){
                self.contentOffset=CGPoint(x: -self.contentInset.left, y: 0)
            }
        }
        setCategoryLabelLayout()
    }
    
    func setCategoryLabelLayout(){
        
        if (textDirection == .RightToLeft){//RTL alignment
            let width=self.frame.size.width-self.contentInset.left-self.contentInset.right
            self.categoryLabel.frame=CGRectMake(-self.contentInset.right+self.contentOffset.x+self.contentInset.left , titlePosition, width, 40)
        }
        else {
            categoryLabel.frame=CGRectMake( self.contentInset.left+self.contentOffset.x+self.contentInset.left, titlePosition, self.frame.size.width-self.contentInset.left-self.contentInset.right, 40)
        }
    }
    
    override var contentInset:UIEdgeInsets {
        get {
            return super.contentInset
        }
        set (newValue){
            setCategoryLabelLayout()
            super.contentInset=newValue
        }
    }
    
    
}