//
//  rootController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/22/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit

extension UITabBarController {
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = (visible==false ? -height : 0)
        print("y:\(offsetY) \(visible)")
        // animate the tabBar
        UIView.animateWithDuration(animated ? 0.3 : 0.0) {
            self.tabBar.frame = CGRectOffset(frame, 0, offsetY)
            //self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height + offsetY)
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return self.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame)
    }
}

class rootController: UITabBarController, UITabBarControllerDelegate{
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*self delegating :D*/
        self.delegate=self
        
        
        /* make the tab bar on top match the rest of the app*/
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Selected)
        
        
        _ = DISPATCH_QUEUE_PRIORITY_DEFAULT
        //dispatch_async(dispatch_get_global_queue(priority, 0)) {
            //let image=self.imageUsingCache(imageURL)
            
            var attempts=0
            while (languageList == nil){
                if (attempts>10){
                    languageList=Array()
                }
                else {
                    let download=dictionaryOfPath(base+"/"+version+"/languages/"+languageCode+"/web")
                    languageList=download?.objectForKey("languages") as? Array<NSDictionary>
                    attempts++
                }
            }
            
            
            
            //dispatch_async(dispatch_get_main_queue()) {
                
                if (languageList == nil){
                    
                    _=UIAlertController(title: "Cannot connect to JW Broadcasting", message: "Make sure you're connected to the internet then try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    
                }
                else {
                    
                    
                    
                    for language in languageList! {
                        /*
                        language dictionary break down
                        
                        code = language code used by tv.jw.org... all the files are inside various language code named folders
                        locale = matches typical locale abbreviation and can be used with NSLocale
                        isRTL = Bool for right to left languages
                        name = Displayable string name for the language you are in?
                        vernacular = Displayable string name in that language?
                        isLangPair = 0; unkown bool
                        isSignLanguage = Bool for sign languages
                        
                        */
                        
                        /* This just simply looks for corresponding language code for the system language Locale */
                        
                        if (language.objectForKey("locale") as! String==NSLocale.preferredLanguages()[0]){
                            setLanguage(language.objectForKey("code") as! String, newTextDirection: ( language.objectForKey("isRTL")?.boolValue == true ? UIUserInterfaceLayoutDirection.RightToLeft : UIUserInterfaceLayoutDirection.LeftToRight ))
                            return
                        }
                    }
                    
                    
                    //let alertController=UIAlertController(title: "Auto language detection failed!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    /*show the language page*/
                    

                }
            //}
        
        
        timer=NSTimer.scheduledTimerWithTimeInterval(7.5, target: self, selector: "hide", userInfo: nil, repeats: false)
        
        }

    
    var timer:NSTimer?=nil

    func tabBarController(tabBarController: UITabBarController,
        shouldSelectViewController viewController: UIViewController) -> Bool{
            timer?.invalidate()
            timer=NSTimer.scheduledTimerWithTimeInterval(7.5, target: self, selector: "hide", userInfo: nil, repeats: false)
            print("should I? ya...")
            return true
    }

    func tabBarController(tabBarController: UITabBarController,
        didSelectViewController viewController: UIViewController){
            
            print("did I?")
            
    }
    
    func hide(){
        self.setTabBarVisible(false, animated: true)
    }
        
        
        
   // }
    
    /*
    Whenever the language is set or changed this method will change the tab bar buttons to match the appropriate languages and order.
    
    First it checks whether the text direction (Left to right, or right to left) has changed.
    
    If the current direction and the new direction are different then the order is reversed by setting the view controller array in reversed order. Animated for fun and beauty (:
    
    Sets the buttons using their corresponding keys for title. If the language is in right to left the for loop is reversed.
    
    
    NOTE
    
    As of September I do not see any right-to-left languages in tv.jw.org however that could change or I could be mistaken. The point is this is untested.
    
    */
    
    func setLanguage(newLanguageCode:String, newTextDirection:UIUserInterfaceLayoutDirection){
        languageCode=newLanguageCode
        
        /* check for possible direction change*/
        
        if (newTextDirection != textDirection){
            textDirection=UIUserInterfaceLayoutDirection.RightToLeft
            self.setViewControllers(self.viewControllers?.reverse(), animated: true)
        }
        
        /* download new translation */
        
        let tranlsatedKeyPhrases=dictionaryOfPath(base+"/"+version+"/translations/"+languageCode)?.objectForKey("translations")?.objectForKey(languageCode)
        
        
        /*These keys are what I found correspond to the navigation buttons on tv.jw.org*/
        
        let keyForButton=["lnkHomeView","homepageStreamingBlockTitle","homepageVODBlockTitle","homepageAudioBlockTitle","lnkLanguage"]
        
        var startIndex=0
        var endIndex=keyForButton.count
        
        /* reverse replacement order if right to left */
        
        if (textDirection==UIUserInterfaceLayoutDirection.RightToLeft){
            startIndex=keyForButton.count
            endIndex=0
        }
        
        /* replace titles */
        
        for var i=startIndex ; i<endIndex ; i++ {
            let newTitle=tranlsatedKeyPhrases?.objectForKey(keyForButton[i]) as! String
            self.tabBar.items?[i].title=newTitle
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
