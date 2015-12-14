//
//  MediaOnDemandMainCategories.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/13/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class MediaOnDemandMainCategories: SuperCollectionView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func cellShouldLoseFocus(view: UIView, indexPath: NSIndexPath) {
        for subview in (view.subviews.first!.subviews) {
            
            if (subview.isKindOfClass(UILabel.self) == true){
                (subview as! UILabel).textColor=UIColor.darkGrayColor()
                
                UIView.animateWithDuration(0.1, animations: {
                    subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y-20, width: subview.frame.size.width, height: subview.frame.size.height)
                })
                
            }
            if (subview.isKindOfClass(marqueeLabel.self) == true){
                (subview as! marqueeLabel).beginFocus()
            }
        }
    }
    
    override func cellShouldFocus(view: UIView, indexPath: NSIndexPath) {
        
        let category="VideoOnDemand"
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
        
        //self.backgroundImageView.image=imageUsingCache((unfold(categoryDataURL+"|category|subcategories|\(indexPath.row)|images|wss|lg") as? String)!)
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UILabel.self) == true){
                (subview as! UILabel).textColor=UIColor.whiteColor()
                subview.layoutIfNeeded()
                UIView.animateWithDuration(0.1, animations: {
                    subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y+20, width: subview.frame.size.width, height: subview.frame.size.height)
                })
                
            }
            if (subview.isKindOfClass(marqueeLabel.self) == true){
                (subview as! marqueeLabel).endFocus()
            }
        }

    }

}
