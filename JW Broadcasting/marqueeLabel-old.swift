//
//  marqueelabels[0]!.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/10/15.
//  Copyright © 2015 xquared. All rights reserved.
//


/*
Code for making UILabels that scroll when focused on and are their contents are too large for their display space.

MAJOR WARNING

This code appears to be broken (but still funcitonal if careful) with UICollectionViews, this appears to be an internal system issue but this is unclear.
When a CAGradientLayer has its bounds changed while in a UICollectionView that is not YET on screen a crash occures claiming an object of __NSCFType attempted to call doubleValue but this is not a valid selector.
Unkown how to fix this yet.




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
        //We do not want text in this label ever
        super.text=""
        //These are the sublabels used for marquee effects that will have text
        labels=[UILabel(),UILabel()]
    }
    
    var _darkBackground:Bool = false
    var darkBackground:Bool{
        set {
            /*
            If this variable is set to true then we bring up the dark background to see the text. This has to be tested as it also enables the side blur effect (can be changed by removing blurSlides()) and the blur effect is unstable currently.
            */
            
            if (newValue == true){
                // defines the color of the background shadow effect
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
                // begin side blur effect
                blurSides()
            }
            else {
                // If we no longer are using the background darkness and side blur effect
                vMaskLayer.removeFromSuperlayer()
                gradientMask?.removeFromSuperlayer()
            }
            // Save this so we can check it later.
            _darkBackground=newValue
        }
        get {
            return _darkBackground
        }
    }
    
    
    override func layoutSubviews(){
        //Call update to correct UILabels because the frame could have changed
        updateSublabels()
        super.layoutSubviews()
    }
    
    var _frame:CGRect=CGRect(x: 0, y: 0, width: 0, height: 0)
    override var frame:CGRect {
        get {
            return super.frame
        }
        set (newValue){
            //Call update to correct UILabels because the frame could have changed
            super.frame=newValue
            updateSublabels()
        }
    }
    
    var focus=false
    
    func beginFocus(){
        /*
        We recieved noticiation that the view is in focus however we want to give the user a second to recognize that before the animation begins. This fires a checker after delay to see if we need to animate once the time is up.
        */
        if (focus==false){
            focus=true
            self.performSelector("checkStillFocused", withObject: nil, afterDelay: 1.5)
        
        }
    }
    
    func checkStillFocused(){
        /*
        The label has been focused on for a little bit now so lets scroll so the user can read the rest.
        */
        if (focus==true){
            self.marquee()
        }
    }
    
    func endFocus(){
        /*
        If we lose focus remove the animations and reset the labels. WARNING because we are removing the labels through a CALayer the next time we go to animate it will throw the labels back to their last place in animation. Right now this method calls UIView.animationDuration(...) to set the text back, clearing the animation data, however this is unnecissary. (unless we want to leave this for a nice return animation)
        
        
        */
        
        if (focus==true){
            focus=false
            //stop UIView.animateWithDuration(...)
            labels[0]?.layer.removeAllAnimations()
            labels[1]?.layer.removeAllAnimations()
            self.layer.removeAllAnimations()
            UIView.animateWithDuration(0.1, animations: {
                //The normal positions of the labels
                self.labels[0]?.frame=CGRectMake(0, (self.labels[0]?.frame.origin.y)!, (self.labels[0]?.frame.size.width)!, (self.labels[0]?.frame.size.height)!)
                self.labels[1]?.frame=CGRect(x: (self.labels[1]?.frame.size.width)!+self.padding, y: 0, width: (self.labels[1]?.frame.size.width)!, height: self.frame.size.height)
            })
        }
    }
    
    func marquee(){
        /*
        Code for the marquee effect.
        First we check if we have enough content to scroll.
        The length of time to animate is based on the size of the text so that it is not too fast when the contents are larger.
        The animation is linear so as to not give a pausing/slowing effect.
        Second we don't scroll if RTL because this is not finished yet.
        When this all completes the labels are reset (in a way the users can not notice) and the loop is called again.
        */
        
        
        if (self.frame.size.width<self.labels[0]?.intrinsicContentSize().width){
            let width=labels[0]!.frame.size.width
            UIView.animateWithDuration( NSTimeInterval(width / CGFloat(50)), delay: 0, options: UIViewAnimationOptions.CurveLinear , animations: {
                for label in self.labels {
                    
                    if (textDirection == .RightToLeft){
                        
                    }
                    else {
                        //move text the space the text takes up plus the padding between labels.
                        label?.frame=CGRectMake((label?.frame.origin.x)!-(label?.frame.size.width)!-self.padding, (label?.frame.origin.y)!, (label?.frame.size.width)!, (label?.frame.size.height)!)
                    }
                    
                }
                
                }, completion: { (finished:Bool) in
                    if (finished){
                        //reset label positions
                        self.labels[0]?.frame=CGRectMake(0, (self.labels[0]?.frame.origin.y)!, (self.labels[0]?.frame.size.width)!, (self.labels[0]?.frame.size.height)!)
                        self.labels[1]?.frame=CGRect(x: (self.labels[1]?.frame.size.width)!+self.padding, y: 0, width: (self.labels[1]?.frame.size.width)!, height: self.frame.size.height)
                        //loop text again
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
            /*
            Passes the new text to the sublabels.
            Our text has changed for the label so we need to correct its sizing so that it can scroll if it needs too.
            Also this stops the text from being displayed in this label iteself.
            */
            
            if labels[0]!.text == newValue {
                return
            }
            for label in labels {
                //change the indivigual text of labels
                label!.text = newValue
            }
            //Tell the sublabels to update
            updateSublabels()
        }
    }
    
    internal override var attributedText: NSAttributedString? {
        get {
            return labels[0]!.attributedText
        }
        
        set {
            
            /*
            Passes the new text to the sublabels.
            Our text has changed for the label so we need to correct its sizing so that it can scroll if it needs too.
            Also this stops the text from being displayed in this label iteself.
            */
            
            if labels[0]!.attributedText == newValue {
                return
            }
            for label in labels {
                label!.attributedText = newValue
            }
            updateSublabels()
        }
    }
    
    internal override var font: UIFont! {
        get {
            return labels[0]!.font
        }
        
        set {
            
            /*
            Passes the new font to the sublabels.
            Our font size has changed for the label so we need to correct its sizing so that it can scroll if it needs too.
            */
            
            if labels[0]!.font == newValue {
                return
            }
            
            for label in labels {
                label!.font = newValue
            }
            self.updateSublabels()
            
        }
    }
    
    internal override var textColor: UIColor! {
        get {
            return labels[0]!.textColor
        }
        
        set {
            /*
            Passes the new text color to the sublabels.
            Applies a nice grey "shadow" effect to the back but we are not using it as a shadow but a highlighting tool to clearly read the text since the images can make it hard to see.
            */
            
            for label in labels {
                label!.textColor = newValue
                label?.shadowColor=UIColor.grayColor()
                label?.shadowOffset=CGSize(width: 0.5, height: 0.5)
            }
            updateSublabels()
        }
    }
    
    func updateSublabels(){
        /*
        This code is called whenever the real labels are needed to be corrected.
        Often this occures when an attribute is changed such as frame size, font size or text contents.
        */
        
        //do a double check that this object has finished initializing.
        if (labels.count == 2){
        
            //Update special gradient effects
            vMaskLayer.bounds = self.bounds
            let blurLeftDistance:CGFloat=(self.frame.size.width-(labels[0]?.intrinsicContentSize().width)!)/2-20
            let blurWidth:CGFloat=(labels[0]?.intrinsicContentSize().width)!+10
            if (gradientMask != nil){
                gradientMask!.bounds = CGRectMake(blurLeftDistance, CGFloat(0), blurWidth, CGFloat(self.bounds.size.height))
                gradientMask!.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
            }
            
            //The font does not get set to the labels because this occures on init before the labels are available. This needs corrected (remove this for loop when done so) in some way so that we can set the font size externally.
            for label in labels {
                label!.font = UIFont.systemFontOfSize(30)
            }
            //properly size the labels so that they take up as much space as they need and if they take up more space than we have to display build a second label for the scrolling positioning it after the first view with some padding space
            labels[0]?.frame=self.bounds
            self.addSubview(labels[0]!)
            if (labels[1]?.intrinsicContentSize().width>self.frame.size.width){
                labels[0]?.frame=CGRect(x: 0, y: 0, width: (labels[0]?.intrinsicContentSize().width)!, height: self.frame.size.height)
                self.addSubview(labels[1]!)
                labels[1]?.frame=CGRect(x: (labels[1]?.intrinsicContentSize().width)!+padding, y: 0, width: (labels[1]?.intrinsicContentSize().width)!, height: self.frame.size.height)
                
            }
            else {
                //This is needed to have centered text inside the label and removes the second label if the text has changed.
                if (self.textAlignment == .Center){
                    labels[0]?.frame=self.bounds
                    labels[0]?.textAlignment = .Center
                }
                labels[1]?.removeFromSuperview()
            }
        }
    }
    
    func blurSides(){
        /*
        Code borrowed from Charles Powell MarqueeLabel.swift
        Remake this code and then remove it so we don't need any acknowledgements and because it is causing crashes with UICollectionViews.
        This code makes the sides fade out so that we don't have chopped off text.
        */
        
        
        // Check for zero-length fade
        if (fadeLength <= 0.0) {
            gradientMask?.removeFromSuperlayer()
            return
        }
        
        
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
