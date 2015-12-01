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
    let padding:CGFloat=30
    let fadeLength:CGFloat=15
    var labels:Array<UILabel?>=[UILabel()]
    var vMaskLayer:CAGradientLayer = CAGradientLayer()
    let gradientMask:CAGradientLayer? = CAGradientLayer()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds=true
        self.backgroundColor=UIColor.clearColor()
        
        super.text=""
        
        labels=[UILabel(),UILabel()]
        //self.updateSublabels()
        
        //self.performSelector("blurSides", withObject: nil, afterDelay: 1.0)
    }
    
    var _darkBackground:Bool = false
    var darkBackground:Bool{
        set {
            if (newValue == true){
                let innerColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.15).CGColor
                let outerColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0).CGColor
                
                // define a vertical gradient (up/bottom edges)
                let colors = [outerColor,outerColor, innerColor,innerColor,outerColor]
                let locations = [0.0,0.05, 0.25,0.75,1.0]
                
                // without specifying startPoint and endPoint, we get a vertical gradient
                vMaskLayer.opacity = 0.7
                vMaskLayer.colors = colors
                vMaskLayer.locations = locations
                vMaskLayer.bounds = self.bounds
                vMaskLayer.anchorPoint = CGPointZero
                
                self.layer.addSublayer(vMaskLayer)
                blurSides()
            }
            else {
                vMaskLayer.removeFromSuperlayer()
                gradientMask?.removeFromSuperlayer()
            }
            _darkBackground=newValue
        }
        get {
            return _darkBackground
        }
    }
    
    
    override func layoutSubviews(){
        updateSublabels()
        super.layoutSubviews()
        //labels[0]!.frame=labelDemensionsAtScrollPoint(0)
    }
    
    var _frame:CGRect=CGRect(x: 0, y: 0, width: 0, height: 0)
    override var frame:CGRect {
        get {
            return super.frame
        }
        set (newValue){
            super.frame=newValue
            updateSublabels()
        }
    }
    
    var focus=false
    
    func beginFocus(){
        if (focus==false){
        focus=true
        self.performSelector("checkStillFocused", withObject: nil, afterDelay: 1.5)
        //self.labels[0]!.textColor=UIColor.whiteColor()
        
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
            labels[0]?.layer.removeAllAnimations()
            labels[1]?.layer.removeAllAnimations()
            self.layer.removeAllAnimations()
            UIView.animateWithDuration(0.1, animations: {
                self.labels[0]?.frame=CGRectMake(0, (self.labels[0]?.frame.origin.y)!, (self.labels[0]?.frame.size.width)!, (self.labels[0]?.frame.size.height)!)
                self.labels[1]?.frame=CGRect(x: (self.labels[1]?.frame.size.width)!+self.padding, y: 0, width: (self.labels[1]?.frame.size.width)!, height: self.frame.size.height)
            })
        }
    }
    
    func marquee(){
        if (self.frame.size.width<self.labels[0]?.intrinsicContentSize().width){
            let width=labels[0]!.frame.size.width
            UIView.animateWithDuration( NSTimeInterval(width / CGFloat(50)), delay: 0, options: UIViewAnimationOptions.CurveLinear , animations: {
                //self.blurSides()
                for label in self.labels {
                    
                    if (textDirection == .RightToLeft){
                        
                    }
                    else {
                        label?.frame=CGRectMake((label?.frame.origin.x)!-(label?.frame.size.width)!-self.padding, (label?.frame.origin.y)!, (label?.frame.size.width)!, (label?.frame.size.height)!)
                    }
                    
                }
                
                }, completion: { (finished:Bool) in
                    if (finished){
                        self.labels[0]?.frame=CGRectMake(0, (self.labels[0]?.frame.origin.y)!, (self.labels[0]?.frame.size.width)!, (self.labels[0]?.frame.size.height)!)
                        self.labels[1]?.frame=CGRect(x: (self.labels[1]?.frame.size.width)!+self.padding, y: 0, width: (self.labels[1]?.frame.size.width)!, height: self.frame.size.height)
                        self.marquee()
                    }
            })
        
        
        
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
    
    
    internal override var text: String? {
        get {
            return labels[0]!.text
        }
        
        set {
            if labels[0]!.text == newValue {
                return
            }
            let newChangedValue=newValue!
            for label in labels {
                label!.text = newChangedValue
            }
            updateSublabels()
            //super.text = text
        }
    }
    
    internal override var attributedText: NSAttributedString? {
        get {
            return labels[0]!.attributedText
        }
        
        set {
            if labels[0]!.attributedText == newValue {
                return
            }
            for label in labels {
                label!.attributedText = newValue
            }
            updateSublabels()
            //super.attributedText = attributedText
        }
    }
    
    internal override var font: UIFont! {
        get {
            return labels[0]!.font
        }
        
        set {
            if labels[0]!.font == newValue {
                return
            }
            
            for label in labels {
                label!.font = newValue
            }
            super.font = newValue
            self.updateSublabels()
            
        }
    }
    
    internal override var textColor: UIColor! {
        get {
            return labels[0]!.textColor
        }
        
        set {
            for label in labels {
                label!.textColor = newValue
                label?.shadowColor=UIColor.grayColor()
                label?.shadowOffset=CGSize(width: 0.5, height: 0.5)
                //label.shado
            }
            super.textColor = newValue
            updateSublabels()
        }
    }
    
    func updateSublabels(){
        
        if (labels.count == 2){
        
            
            vMaskLayer.bounds = self.bounds
            let blurLeftDistance:CGFloat=(self.frame.size.width-(labels[0]?.intrinsicContentSize().width)!)/2-20
            let blurWidth:CGFloat=(labels[0]?.intrinsicContentSize().width)!+10
            if (gradientMask != nil){
                gradientMask!.bounds = CGRectMake(blurLeftDistance, CGFloat(0), blurWidth, CGFloat(self.bounds.size.height))
                gradientMask!.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
            }
            
            for label in labels {
                label!.font = UIFont.systemFontOfSize(30)
            }
            labels[0]?.frame=self.bounds
            self.addSubview(labels[0]!)
            if (labels[1]?.intrinsicContentSize().width>self.frame.size.width){
                labels[0]?.frame=CGRect(x: 0, y: 0, width: (labels[0]?.intrinsicContentSize().width)!, height: self.frame.size.height)
                self.addSubview(labels[1]!)
                labels[1]?.frame=CGRect(x: (labels[1]?.intrinsicContentSize().width)!+padding, y: 0, width: (labels[1]?.intrinsicContentSize().width)!, height: self.frame.size.height)
                
            }
            else {
                if (self.textAlignment == .Center){
                    labels[0]?.frame=self.bounds
                    labels[0]?.textAlignment = .Center
                }
                labels[1]?.removeFromSuperview()
            }
        }
    }
    
    func blurSides(){
        // Check for zero-length fade
        /*if (fadeLength <= 0.0) {
            removeGradientMask()
            return
        }*/
        
        
        // Remove any in flight animations
        gradientMask!.removeAllAnimations()
        
        // Set up colors
        let transparent = UIColor.clearColor().CGColor
        let opaque = UIColor.blackColor().CGColor
        
        gradientMask!.bounds = self.layer.bounds
        gradientMask!.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        gradientMask!.shouldRasterize = true
        gradientMask!.rasterizationScale = UIScreen.mainScreen().scale
        gradientMask!.startPoint = CGPointMake(0.0, 0.5)
        gradientMask!.endPoint = CGPointMake(1.0, 0.5)
        // Start with default (no fade) locations
        gradientMask!.colors = [opaque, opaque, opaque, opaque]
        gradientMask!.locations = [0.0, 0.0, 1.0, 1.0]
        
        // Set mask
        self.layer.mask = gradientMask
        
        let leftFadeStop = fadeLength/self.bounds.size.width
        let rightFadeStop = fadeLength/self.bounds.size.width
        
        // Adjust stops based on fade length
        let adjustedLocations = [0.0, leftFadeStop, (1.0 - rightFadeStop), 1.0]
        
        // Determine colors for non-scrolling label (i.e. at home)
        let adjustedColors: [CGColorRef] = [transparent, opaque, opaque, transparent]
        /*let trailingFadeNeeded = (!self.labelize || self.labelShouldScroll())
        
        switch (type) {
        case .ContinuousReverse, .RightLeft:
            adjustedColors = [(trailingFadeNeeded ? transparent : opaque), opaque, opaque, opaque]
            
            // .MLContinuous, .MLLeftRight
        default:
            adjustedColors = [opaque, opaque, opaque, (trailingFadeNeeded ? transparent : opaque)]
            break
        }*/
        
        if (true) {
            // Create animation for location change
            let locationAnimation = CABasicAnimation(keyPath: "locations")
            locationAnimation.fromValue = gradientMask!.locations
            locationAnimation.toValue = adjustedLocations
            locationAnimation.duration = 0.25
            
            // Create animation for location change
            let colorAnimation = CABasicAnimation(keyPath: "colors")
            colorAnimation.fromValue = gradientMask!.locations
            colorAnimation.toValue = adjustedColors
            colorAnimation.duration = 0.25
            
            // Create animation group
            let group = CAAnimationGroup()
            group.animations = [locationAnimation, colorAnimation]
            group.duration = 0.25
            
            gradientMask!.addAnimation(group, forKey: colorAnimation.keyPath)
            gradientMask!.locations = adjustedLocations
            gradientMask!.colors = adjustedColors
        } else {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            gradientMask!.locations = adjustedLocations
            gradientMask!.colors = adjustedColors
            CATransaction.commit()
        }
    }

}
