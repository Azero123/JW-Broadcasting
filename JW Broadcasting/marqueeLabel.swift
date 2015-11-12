//
//  marqueeLabel.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/10/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import Foundation
import UIKit

class marqueeLabel : UIView  {
    var i:CGFloat=0
    let label=UILabel()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        label.frame=labelDemensionsAtScrollPoint(0)
        label.textColor=UIColor.blackColor()
        self.addSubview(label)
        self.clipsToBounds=true
        label.textAlignment = .Center
        self.backgroundColor=UIColor.clearColor()
    }
    
    var _frame:CGRect=CGRect(x: 0, y: 0, width: 0, height: 0)
    override var frame:CGRect {
        set (newValue){
            _frame=newValue
            label.frame=labelDemensionsAtScrollPoint(0)
        }
        get {
            return _frame
        }
    }
    
    var _text=""
    var text:String {
        set (newValue){
            _text=newValue
            label.text=newValue
            label.frame=labelDemensionsAtScrollPoint(0)
        }
        get {
            return _text
        }
    }
    
    func labelDemensionsAtScrollPoint(point:CGFloat) -> CGRect{
        if (self.label.intrinsicContentSize().width>self.frame.size.width){
            return CGRect(x: 0,y: 0,width: self.label.intrinsicContentSize().width,height: self.frame.size.height)
        }
        else {
            return CGRect(x: (self.frame.width-self.label.intrinsicContentSize().width)/2,y: 0,width: self.label.intrinsicContentSize().width,height: self.frame.size.height)
        }
    }
    
    func marquee(){
        
        print("marquee distance:\(self.label.frame.width-self.label.intrinsicContentSize().width)")
        
        if (self.label.frame.width-self.label.intrinsicContentSize().width<0){
        
        self.label.frame=labelDemensionsAtScrollPoint(0)
            
            UIView.animateWithDuration(2, animations: {
                self.label.frame=self.labelDemensionsAtScrollPoint(self.label.frame.width-self.label.intrinsicContentSize().width)
                
            })
        }
    }
}

/*
- (void)animateLabeltext:(UILabel *)newView{
NSString * lbltest=newView.text;
newView.center=CGPointMake(ReqLbl.frame.size.width+newView.frame.size.width/2,newView.center.y);
[UIView animateWithDuration:lbltest.length/8
delay:0.0
options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
animations:^(void) {
newView.center=CGPointMake(-newView.frame.size.width/2,newView.center.y);
}
completion:^(BOOL finished) {
if(finished) {
[self animateLabeltext:newView];
}
}
];
}
*/