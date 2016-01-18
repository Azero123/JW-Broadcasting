//
//  customActvityIndicator.swift
//  JW Broadcasting self Circle
//
//  Created by Austin Zelenka on 1/5/16.
//  Copyright © 2016 xquared. All rights reserved.
//

import UIKit

class JWBroadcastingActvityIndicator : UIActivityIndicatorView {
    
    override init(activityIndicatorStyle style: UIActivityIndicatorViewStyle) {
        super.init(activityIndicatorStyle: style)
        supportInit()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        supportInit()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        supportInit()
    }
    
    func supportInit(){
        //self.backgroundColor=UIColor.redColor()
        print(self.layer.sublayers?.first?.opacity=0)
        
        self.layer.borderColor=UIColor(colorLiteralRed: 63/255, green: 106/255, blue: 178/255, alpha: 1).CGColor
        self.layer.borderWidth=2
        //self.layer.cornerRadius=25
        self.layer.cornerRadius=self.frame.size.width/10
        print(self.layer.cornerRadius)
    }
    
    override func startAnimating() {
        super.startAnimating()
        //self.frame=CGRectMake(0, 0, 200, 200)
        //self.layoutIfNeeded()
        self.transform = CGAffineTransformMakeScale(0.1, 0.1)
        self.alpha=0
        UIView.animateKeyframesWithDuration(2, delay: 0, options: UIViewKeyframeAnimationOptions.Repeat, animations: {
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1, animations: {
                self.transform = CGAffineTransformMakeScale(0.1, 0.1)
                self.alpha=1
            })
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1, animations: {
                self.transform = CGAffineTransformMakeScale(5.2, 5.2)
                self.alpha=0
            })
            }, completion: nil)

    }
    /*
    override var frame:CGRect {
        set (newValue){
            self.layer.borderWidth=newValue.size.width/50
            self.layer.cornerRadius=newValue.size.width/2.5
            super.frame=newValue
        }
        get {
            return super.frame
        }
    }*/
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
}
