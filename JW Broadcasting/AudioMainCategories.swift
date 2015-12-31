//
//  AudioMainCategories.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 12/18/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class AudioMainCategories: SuperCollectionView {
    
    
    
    let images=[
        "NewSongs":"newsongs-singtojehovah",
        "Piano":"piano-singtojehovah",
        "Vocal":"vocals-singtojehovah",
        "KingdomMelodies":"kingdommelodies",
        "Dramas":"drama",
        "DramaticBibleReadings":"readings"
    ]
    
    override func cellShouldLoseFocus(view: UIView, indexPath: NSIndexPath) {
        for subview in (view.subviews.first!.subviews) {
            
            if (subview.isKindOfClass(UILabel.self) == true){
                (subview as! UILabel).textColor=UIColor.darkGrayColor()
                
                UIView.animateWithDuration(0.1, animations: {
                    //subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y-20, width: subview.frame.size.width, height: subview.frame.size.height)
                    subview.layoutIfNeeded()
                })
                
            }
            if (subview.isKindOfClass(marqueeLabel.self) == true){
                (subview as! marqueeLabel).endFocus()
            }
        }
    }
    
    override func cellShouldFocus(view: UIView, indexPath: NSIndexPath) {
        
        if ((self.delegate?.isKindOfClass(NewAudioController.self)) == true){
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                if (view==UIScreen.mainScreen().focusedView){

                    UIView.transitionWithView((self.delegate as! NewAudioController).backgroundImageView, duration: 0.5, options: .TransitionCrossDissolve, animations: {
                        
                        let category="Audio"
                        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
                        let categoryDataURL=categoriesDirectory+"/"+category+"?detailed=1"
                        let key=unfold(categoryDataURL+"|category|subcategories|\(indexPath.row)|key") as! String
                        (self.delegate as! NewAudioController).backgroundImageView.image=UIImage(named: self.images[key]!)
                        }, completion: nil)
                }
            }
            
        }
        
        for subview in (view.subviews.first!.subviews) {
            if (subview.isKindOfClass(UILabel.self) == true){
                (subview as! UILabel).textColor=UIColor.whiteColor()
                subview.layoutIfNeeded()
                subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y+30, width: subview.frame.size.width, height: subview.frame.size.height)
                /*UIView.animateWithDuration(0.1, animations: {
                    subview.frame=CGRect(x: subview.frame.origin.x, y: subview.frame.origin.y+30, width: subview.frame.size.width, height: subview.frame.size.height)
                })*/
                
            }
            if (subview.isKindOfClass(marqueeLabel.self) == true){
                (subview as! marqueeLabel).beginFocus()
            }
        }
        
    }

}
