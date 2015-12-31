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
    var fadeLength:CGFloat=15
    var fadePadding:CGFloat = 20
    var fadePaddingWhenFull:CGFloat = 20
    var textSideOffset:CGFloat=10
    var labels:Array<UILabel?>=[UILabel()]
    var vMaskLayer:CAGradientLayer = CAGradientLayer()
    var gradientMask:CAGradientLayer? = CAGradientLayer()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds=false
        self.backgroundColor=UIColor.clearColor()
        //We do not want text in this label ever
        super.text=""
        //These are the sublabels used for marquee effects that will have text
        labels=[UILabel(),UILabel()]
        self.font=super.font
        self.textColor=super.textColor
        // begin side blur effect
        blurSides()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds=false
        self.backgroundColor=UIColor.clearColor()
        //We do not want text in this label ever
        super.text=""
        //These are the sublabels used for marquee effects that will have text
        labels=[UILabel(),UILabel()]
        self.font=super.font
        self.textColor=super.textColor
        // begin side blur effect
        blurSides()
    }
    
    var _darkBackground:Bool = false
    var darkBackground:Bool{
        set {
            /*
            If this variable is set to true then we bring up the dark background to see the text.
            */
            
            if (newValue == true){
                // defines the color of the background shadow effect
                let innerColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.20).CGColor
                let outerColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0).CGColor
                
                // define a vertical gradient (up/bottom edges)
                let colors = [outerColor,outerColor, innerColor ,outerColor,outerColor]
                let locations = [0.0,0.25, 0.5,0.75,1.0]
                
                // without specifying startPoint and endPoint, we get a vertical gradient
                vMaskLayer.opacity = 0.7
                vMaskLayer.colors = colors
                vMaskLayer.locations = locations
                vMaskLayer.bounds = self.bounds
                vMaskLayer.anchorPoint = CGPointZero
                
                self.layer.addSublayer(vMaskLayer)
            }
            else {
                // If we no longer are using the background darkness
                vMaskLayer.removeFromSuperlayer()
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
                self.labels[0]?.frame=CGRectMake(self.textSideOffset, (self.labels[0]?.frame.origin.y)!, (self.labels[0]?.frame.size.width)!, (self.labels[0]?.frame.size.height)!)
                self.labels[1]?.frame=CGRect(x: (self.labels[1]?.frame.size.width)!+self.padding+self.textSideOffset, y: 0, width: (self.labels[1]?.frame.size.width)!, height: self.frame.size.height)
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
                        label?.frame=CGRectMake((label?.frame.origin.x)!-(label?.frame.size.width)!-self.padding+self.textSideOffset, (label?.frame.origin.y)!, (label?.frame.size.width)!, (label?.frame.size.height)!)
                    }
                    
                }
                
                }, completion: { (finished:Bool) in
                    if (finished){
                        //reset label positions
                        self.labels[0]?.frame=CGRectMake(self.textSideOffset, (self.labels[0]?.frame.origin.y)!, (self.labels[0]?.frame.size.width)!, (self.labels[0]?.frame.size.height)!)
                        self.labels[1]?.frame=CGRect(x: (self.labels[1]?.frame.size.width)!+self.padding+self.textSideOffset, y: 0, width: (self.labels[1]?.frame.size.width)!, height: self.frame.size.height)
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
    
    var _font:UIFont = UIFont.systemFontOfSize(12)
    internal override var font: UIFont! {
        get {
            return _font
        }
        
        set {
            
            /*
            Passes the new font to the sublabels.
            Our font size has changed for the label so we need to correct its sizing so that it can scroll if it needs too.
            */
            _font=newValue
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
            
            var fadePaddingToUse=fadePaddingWhenFull
            
            var widthToUse=self.frame.size.width
            if (widthToUse>(labels[0]?.intrinsicContentSize().width)!){
                widthToUse=(labels[0]?.intrinsicContentSize().width)!
                fadePaddingToUse=fadePadding
            }
            
            let blurLeftDistance:CGFloat=(widthToUse)/2-fadePaddingToUse
            let blurWidth:CGFloat=(widthToUse)+fadePaddingToUse*2
            if (gradientMask != nil){
                gradientMask!.bounds = CGRectMake(blurLeftDistance, CGFloat(0), blurWidth, CGFloat(self.bounds.size.height))
                //gradientMask!.bounds=CGRectMake(-fadePadding, 0, self.bounds.size.width+fadePadding, self.bounds.size.height)
                gradientMask!.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
            }
            
            //The font does not get set to the labels because this occures on init before the labels are available. This needs corrected (remove this for loop when done so) in some way so that we can set the font size externally.
            for label in labels {
                label!.font = _font
            }
            //properly size the labels so that they take up as much space as they need and if they take up more space than we have to display build a second label for the scrolling positioning it after the first view with some padding space
            labels[0]?.frame=self.bounds
            self.addSubview(labels[0]!)
            if (labels[1]?.intrinsicContentSize().width>self.frame.size.width){
                labels[0]?.frame=CGRect(x: self.textSideOffset, y: 0, width: (labels[0]?.intrinsicContentSize().width)!, height: self.frame.size.height)
                self.addSubview(labels[1]!)
                labels[1]?.frame=CGRect(x: (labels[1]?.intrinsicContentSize().width)!+padding+self.textSideOffset, y: 0, width: (labels[1]?.intrinsicContentSize().width)!, height: self.frame.size.height)
                
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
        
        //Gets the distance in decimal form relative to the width that needs to be blurred
        let leftFadeStop = fadeLength/self.bounds.size.width
        let rightFadeStop = fadeLength/self.bounds.size.width
        
        //Set color positions, fully clear on far edges and fully opaque in the middle
        let colors=[UIColor.clearColor().CGColor,UIColor.whiteColor().CGColor,UIColor.whiteColor().CGColor,UIColor.clearColor().CGColor]
        //Start on the far left
        
        gradientMask!.bounds=self.bounds
        //Set the middle of the blur effect to the middle of the view
        gradientMask!.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        //Start on the far left
        gradientMask!.startPoint = CGPointMake(0.0, 0.5)
        //End on the far right
        gradientMask!.endPoint = CGPointMake(1.0, 0.5)
        gradientMask!.shouldRasterize = true
        gradientMask!.colors = colors as [AnyObject] //applies the alphas to their positions
        // Sets the decimal forms of the faded distance
        gradientMask!.locations = [0.0, leftFadeStop, (1.0 - rightFadeStop), 1.0]
        self.layer.mask=gradientMask!//Apply effect
    }

}
