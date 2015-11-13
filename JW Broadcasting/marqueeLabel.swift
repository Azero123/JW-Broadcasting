//
//  marqueeLabel.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/10/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

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
        label.textColor=UIColor.darkGrayColor()
        self.backgroundColor=UIColor.clearColor()
        label.font=UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        label.frame=labelDemensionsAtScrollPoint(0)
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
            print("width is larger")
            return CGRect(x: point,y: 0,width: self.label.intrinsicContentSize().width,height: self.frame.size.height)
        }
        else {
            //print("too small:\(self.frame.width) \(self.label.intrinsicContentSize().width)")
            //print("excess space:\(self.frame.size.width-self.label.intrinsicContentSize().width)")
            //print("single side space:\((self.frame.size.width-self.label.intrinsicContentSize().width)/2)")
            let frame=CGRect(x: point+(self.bounds.size.width-self.label.intrinsicContentSize().width)/2,y: 0,width: self.label.intrinsicContentSize().width,height: self.frame.size.height)
            
            //print("frame:\(frame)")
            return frame
        }
    }
    
    var focus=false
    
    func beginFocus(){
        focus=true
        self.performSelector("checkStillFocused", withObject: nil, afterDelay: 1.5)
        self.label.textColor=UIColor.whiteColor()
    }
    
    func checkStillFocused(){
        if (focus==true){
            self.marquee()
        }
    }
    
    func endFocus(){
        focus=false
        self.label.layer.removeAllAnimations()
        self.label.frame=labelDemensionsAtScrollPoint(0)
        self.label.textColor=UIColor.darkGrayColor()
    }
    
    func marquee(){
        
        //print("marquee distance:\(self.frame.size.width) \(self.label.intrinsicContentSize().width)")
        
        if (self.frame.size.width<self.label.frame.size.width){
        
            print("animate")
            
        //self.label.frame=labelDemensionsAtScrollPoint(0)
            
            UIView.animateWithDuration(NSTimeInterval(abs(Int(self.frame.size.width-self.label.frame.size.width-50)))/50, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.label.frame=CGRect(x: self.frame.size.width-self.label.frame.size.width-50, y: 0, width: self.label.frame.size.width, height: self.label.frame.size.height)
                
                }, completion: nil)
        }
    }
    func finishedAnimation(){
        //self.label.frame=labelDemensionsAtScrollPoint(0)
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