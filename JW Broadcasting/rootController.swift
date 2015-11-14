//
//  rootController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/22/15.
//  Copyright © 2015 Austin Zelenka. All rights reserved.
//

import UIKit
import TVMLKit

extension UITabBarController : TVApplicationControllerDelegate {
    
    /*method to check whether the tab bar is lined up or not*/
    
    func tabBarIsVisible() ->Bool {
        return self.view.frame.origin.y == 0
    }
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        
        /*If the tab bar is already in the right place then we don't need to animate so just exit now. No bugs no glitches (: */
        if (tabBarIsVisible() == visible) { return }
        
        /*figure out what the height of the tab bar is*/
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = (visible==false ? -height : 0)
        
        /*animate the removal of the tab bar so it looks nice if "animated" is true*/
        UIView.animateWithDuration(animated ? 0.3 : 0.0) {
            /*adjust the view to move upward hiding the tab bar and then stretch it to make up for moving it*/
            self.tabBar.frame=CGRect(x: 0, y: offsetY, width: self.tabBar.frame.size.width, height: self.tabBar.frame.size.height)
        }
    }
    
    
}

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

func languageFromLocale(var locale:String) -> NSDictionary?{
    locale=locale.componentsSeparatedByString("-")[0]
    if (languageList?.count>0){
        for language in languageList! {
            
            /* This just simply looks for corresponding language for the system language Locale */
            if (language.objectForKey("locale") as! String==locale){
                return language
            }
        }
    }
    return nil
}


func languageFromCode(code:String) -> NSDictionary?{
    
    if (languageList?.count>0){
        for language in languageList! {
            
            /* This just simply looks for corresponding language for the system language code */
            
            if (language.objectForKey("code") as! String==code){
                return language
            }
        }
    }
    return nil
}

var translatedKeyPhrases:NSDictionary?

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
        
                let download=dictionaryOfPath(base+"/"+version+"/languages/"+languageCode+"/web")
                languageList=download?.objectForKey("languages") as? Array<NSDictionary>
            
            
            //dispatch_async(dispatch_get_main_queue()) {
        
        
                if (languageList?.count==0){
                    
                    self.performSelector("displayUnableToConnect", withObject: self, afterDelay: 1.0)
                    
                }
                else {
                    
                    
                    let libraryDirectory=NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first
                    let settingsDirectory=libraryDirectory!+"/settings.plist"
                    let settings=NSMutableDictionary(contentsOfFile: settingsDirectory)
                    
                    var language:NSDictionary?
                    
                    if ((settings) != nil){
                        language=languageFromCode(settings?.objectForKey("language") as! String) //Attempt using language from settings file
                    }
                    if (language == nil){
                        language=languageFromLocale(NSLocale.preferredLanguages()[0]) ; print("system language")} //Attempt using system language
                    if (language == nil){
                        print("unable to find a language")
                        //Language detection has failed default to english
                        self.performSelector("displayFailedToFindLanguage", withObject: nil, afterDelay: 1.0); print("default english")
                        
                        language=languageFromLocale("en")
                    }
                    if (language == nil){ language=languageList?.first; print("default random") } //English failed use any language
                    
                    if ((language) != nil){
                        self.setLanguage(language!.objectForKey("code") as! String, newTextDirection: ( language!.objectForKey("isRTL")?.boolValue == true ? UIUserInterfaceLayoutDirection.RightToLeft : UIUserInterfaceLayoutDirection.LeftToRight ))
                    }

                }
            //}
        
        
        timer=NSTimer.scheduledTimerWithTimeInterval(7.5, target: self, selector: "hide", userInfo: nil, repeats: false)
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRecognizer.direction = .Right //|| .Up || .Left || .Right
        self.view.addGestureRecognizer(swipeRecognizer)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)];
        self.view.addGestureRecognizer(tapRecognizer)
        
        }
    
    func displayFailedToFindLanguage(){
        let alert=UIAlertController(title: "Language Unknown", message: "Unable to find a language for you.", preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayUnableToConnect(){
        //msgAPIFailureErrorTitle
        if (translatedKeyPhrases != nil){
            let alert=UIAlertController(title: translatedKeyPhrases?.objectForKey("msgAPIFailureErrorTitle") as? String, message: translatedKeyPhrases?.objectForKey("msgAPIFailureErrorBody")as? String, preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            let alert=UIAlertController(title: "Cannot connect to JW Broadcasting", message: "Make sure you're connected to the internet then try again.", preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func tapped(tap:UIGestureRecognizer){
        keepDown()
    }
    
    func swipe(recognizer:UIGestureRecognizer){
        keepDown()
    }
    
    func swiped(sender:UISwipeGestureRecognizer){
        
        
       /* switch sender.direction {
         
        case UISwipeGestureRecognizerDirection.Right:
            timer?.invalidate()
            
        case UISwipeGestureRecognizerDirection.Left:
            timer?.invalidate()
            
        default:
            break
            
        }*/
        
        keepDown()
        
        //if (sender.direction == UISwipeGestureRecognizerDirection.Right){
            
        //}
    }
    
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?){
        
        keepDown()
        
        super.pressesBegan(presses, withEvent: event)
        
    }
    
    func keepDown(){
        timer?.invalidate()
        timer=NSTimer.scheduledTimerWithTimeInterval(7.5, target: self, selector: "hide", userInfo: nil, repeats: false)
        self.setTabBarVisible(true, animated: true)
    }
    
    var timer:NSTimer?=nil
    
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
        print("set language")
        /*
        Save settings language settings to settings.plist file in library folder.
        */
        
        let libraryDirectory=NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first
        let settingsDirectory=libraryDirectory!+"/settings.plist"
        
        var settings=NSMutableDictionary(contentsOfFile: settingsDirectory)
        if (settings == nil){
            settings=NSMutableDictionary()
        }
        settings?.setObject(newLanguageCode, forKey: "language")
        settings?.writeToFile(settingsDirectory, atomically: true)
        
        /* check for possible direction change*/
        
        if (newTextDirection != textDirection){
            textDirection=UIUserInterfaceLayoutDirection.RightToLeft
            self.setViewControllers(self.viewControllers?.reverse(), animated: true)
        }
        
        /* download new translation */
        translatedKeyPhrases=dictionaryOfPath(base+"/"+version+"/translations/"+languageCode)?.objectForKey("translations")?.objectForKey(languageCode) as? NSDictionary
        print(translatedKeyPhrases?.allKeys)
        if (translatedKeyPhrases != nil){ // if the language file was obtained
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
                //var newTitle=translatedKeyPhrases?.objectForKey(keyForButton[i]) as! String
                switch i {
                /*case 0:
                    newTitle=""
                case 1:
                    newTitle=""
                case 2:
                    newTitle=""
                case 3:
                    newTitle=""*/
                case 4:
                    //newTitle=" "
                    self.tabBar.items?[i].title="    "
                    
                    let fontattributes=[NSFontAttributeName:UIFont(name: "jwtv", size: 36)!,NSForegroundColorAttributeName:UIColor.grayColor()] as Dictionary<String,AnyObject>
                    //NSMutableDictionary(object: UIFont(name: "jwtv", size: 36)!, forKey: NSFontAttributeName)
                    
                    //fontattributes.setObject(<#T##anObject: AnyObject##AnyObject#>, forKey: <#T##NSCopying#>)
                    
                    self.tabBar.items?[i].setTitleTextAttributes(fontattributes, forState: .Normal)
                    //self.tabBar.items?[i].setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.grayColor()], forState: .Normal)
                    //self.tabBar.items?[i].setTitleTextAttributes([UITextAttributeTextColor: UIColor.blackColor()], forState: .Normal)
                default: break
                    //newTitle=""
                    self.tabBar.items?[i].title=((translatedKeyPhrases?.objectForKey(keyForButton[i]))! as! String)
                }
                //self.tabBar.items?[i].title=((translatedKeyPhrases?.objectForKey(keyForButton[i]))! as! String)
                //self.tabBar.items?[i].setTitleTextAttributes(NSDictionary(object: UIFont(name: "jwtv", size: 36)!, forKey: NSFontAttributeName) as? [String : AnyObject], forState: .Normal)
            }
        }
        else {
            self.performSelector("displayUnableToConnect", withObject: self, afterDelay: 1.0)
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
