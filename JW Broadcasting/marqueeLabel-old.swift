//
//  marqueelabels[0]!.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/10/15.
//  Copyright © 2015 xquared. All rights reserved.
//




/*


WARNING


This code is not working and not finished. Ideally we want to make the text inside UICollectionViewCells scroll after a small delay of focus. However producing this effect with UIView.animation(...) seems to produce a lot of problems with the text jumping.
We also tried some code from cbpowell on Github (MarqueeLabel.swift) however this code seems to have some issues with side fade out effects not cooperating inside UICollectionViews and causing the app to crash.
https://github.com/cbpowell/MarqueeLabel
*/










import Foundation
import UIKit
import QuartzCore

class marqueeLabel : UILabel  {
    var i:CGFloat=0
    var labels:Array<UILabel?>=[UILabel()]
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds=true
        self.backgroundColor=UIColor.clearColor()
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        //labels[0]!.frame=labelDemensionsAtScrollPoint(0)
    }
    /*
    var _frame:CGRect=CGRect(x: 0, y: 0, width: 0, height: 0)
    override var frame:CGRect {
        set (newValue){
            _frame=newValue
            labels[0]!.frame=labelDemensionsAtScrollPoint(0)
        }
        get {
            return _frame
        }
    }
    
    var _text=""
    var text:String {
        set (newValue){
            _text=newValue
            labels[0]!.text=newValue
            labels[0]!.frame=labelDemensionsAtScrollPoint(0)
        }
        get {
            return _text
        }
    }*/
    
    var focus=false
    
    func beginFocus(){
        if (focus==false){
        focus=true
        self.performSelector("checkStillFocused", withObject: nil, afterDelay: 1.5)
        self.labels[0]!.textColor=UIColor.whiteColor()
        
        }
    }
    
    func checkStillFocused(){
        if (focus==true){
            /*self.labels[0]!.frame=labelDemensionsAtScrollPoint(0)
            self.performSelector("marquee", withObject: nil, afterDelay: 0.2)*/
            self.marquee()
        }
    }
    
    func endFocus(){
        if (focus==true){
        focus=false
        }
    }
    
    func marquee(){
        
        //print("marquee distance:\(self.frame.size.width) \(self.labels[0]!.intrinsicContentSize().width)")
        
        if (self.frame.size.width<self.labels[0]!.frame.size.width){
            
        
        
        
        }
    }
    func finishedAnimation(){
        //self.labels[0]!.frame=labelDemensionsAtScrollPoint(0)
    }
    /*
    override func drawTextInRect(rect: CGRect) {
        i++
        super.drawTextInRect(CGRect(x: 100+i, y: 0, width: 100, height: 100))
        self.setNeedsDisplay()
    }*/
}
