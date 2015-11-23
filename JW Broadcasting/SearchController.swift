//
//  SearchController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/21/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

class SearchController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return keys.characters.count
    }
    
    let keys="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let key: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("key", forIndexPath: indexPath)
        
        for subview in key.contentView.subviews {
            if (subview.isKindOfClass(UILabel.self)){
                //(subview as! UIButton).setTitle("\(NSString(string: keys).substringWithRange(NSRange(location: indexPath.row,length: 1)))", forState: .Normal)
                (subview as! UILabel).text=NSString(string: keys).substringWithRange(NSRange(location: indexPath.row,length: 1))
            }
        }
        
        
        return key
    }
    
    func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        /*
        Makes all cells selectable.
        */
        
        return true
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        let cell=collectionView.cellForItemAtIndexPath(indexPath)
        
        UIView.animateWithDuration(0.2, animations: {
            
            cell!.transform = CGAffineTransformMakeScale(1.05, 1.05)
            }, completion: nil)
        UIView.animateKeyframesWithDuration(0.2, delay: 0.2, options: UIViewKeyframeAnimationOptions.CalculationModeLinear , animations: {
            cell!.transform = CGAffineTransformMakeScale(1.1, 1.1)
            }, completion: nil)
        
        
  
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool {
        collectionView.clipsToBounds=false
        if (context.previouslyFocusedView?.isKindOfClass(UICollectionViewCell.self) == true){
            context.previouslyFocusedView?.layer.shadowOpacity=0
            context.previouslyFocusedView?.transform = CGAffineTransformMakeScale(1.0, 1.0)
        }
        if (context.nextFocusedView?.isKindOfClass(UICollectionViewCell.self) == true){
            context.nextFocusedView?.layer.shadowColor=UIColor.blackColor().CGColor
            context.nextFocusedView?.layer.shadowRadius=10
            context.nextFocusedView?.layer.shadowOpacity=1
            context.nextFocusedView?.transform = CGAffineTransformMakeScale(1.1, 1.1)
        }
        return true
    }

}
