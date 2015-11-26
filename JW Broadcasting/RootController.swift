//
//  rootController.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/22/15.
//  Copyright © 2015 Austin Zelenka. All rights reserved.
//

import UIKit
import TVMLKit

var disableNavBar=false

extension UITabBarController : TVApplicationControllerDelegate {
    
    /*method to check whether the tab bar is lined up or not*/
    
    func tabBarIsVisible() ->Bool {
        return self.view.frame.origin.y == 0
    }
    
    func setTabBarVisible(visible:Bool, animated:Bool) {
        if (disableNavBar == false || visible == false){
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
        
        let logoImageView=UIImageView(image: UIImage(named: "JW-White-Background-Blue.png"))
        logoImageView.frame=CGRect(x: 90, y: 50, width: 50, height: 50)
        self.tabBar.addSubview(logoImageView)
        
        
        if (Home==false){
            for viewController in self.viewControllers! {
                if (viewController.isKindOfClass(HomeController.self)){
                    self.viewControllers?.removeAtIndex((self.viewControllers?.indexOf(viewController))!)
                }
            }
        }
        if (VOD==false){
            for viewController in self.viewControllers! {
                if (viewController.isKindOfClass(VideoOnDemandController.self)){
                    self.viewControllers?.removeAtIndex((self.viewControllers?.indexOf(viewController))!)
                }
            }
        }
        if (Audio==false){
            for viewController in self.viewControllers! {
                if (viewController.isKindOfClass(AudioController.self)){
                    self.viewControllers?.removeAtIndex((self.viewControllers?.indexOf(viewController))!)
                }
            }
        }
        if (Language==false){
            for viewController in self.viewControllers! {
                if (viewController.isKindOfClass(LanguageSelector.self)){
                    self.viewControllers?.removeAtIndex((self.viewControllers?.indexOf(viewController))!)
                }
            }
        }
        if (Search==false){
            for viewController in self.viewControllers! {
                if (viewController.isKindOfClass(SearchController.self)){
                    self.viewControllers?.removeAtIndex((self.viewControllers?.indexOf(viewController))!)
                }
            }
        }
        if (BETAMedia==false){
            for viewController in self.viewControllers! {
                if (viewController.isKindOfClass(MediaOnDemandController.self)){
                    self.viewControllers?.removeAtIndex((self.viewControllers?.indexOf(viewController))!)
                }
            }
        }
        
        if (textDirection == .RightToLeft){
            self.selectedIndex=(self.viewControllers?.count)!-1
        }
        else {
            self.selectedIndex=0
        }
        
        let imageView=UIImageView(image: UIImage(contentsOfFile: "LaunchScreenEarth.png"))
        
        
        self.view.addSubview(imageView)
        
        
        
        /*self delegating :D*/
        self.delegate=self
        
        
        /* make the tab bar on top match the rest of the app*/
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.blackColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Selected)
        
        
        fetchDataUsingCache(base+"/"+version+"/languages/"+languageCode+"/web", downloaded: {
            dispatch_async(dispatch_get_main_queue()) {
            let download=dictionaryOfPath(base+"/"+version+"/languages/"+languageCode+"/web")
            languageList=download?.objectForKey("languages") as? Array<NSDictionary>
            
            
            //dispatch_async(dispatch_get_main_queue()) {
            
            
            if (languageList?.count==0){
                
                self.performSelector("displayUnableToConnect", withObject: self, afterDelay: 1.0)
                
            }
            else {
                
                
                let settings=NSUserDefaults.standardUserDefaults()
                
                var language:NSDictionary?
                
                if ((settings.objectForKey("language")) != nil){
                    language=languageFromCode(settings.objectForKey("language") as! String) //Attempt using language from settings file
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
                    //textDirection=UIUserInterfaceLayoutDirection.RightToLeft
                }
                
            }
            }
        })
        
        
        
        
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
        alert.addAction(UIAlertAction(title: "Okay", style: .Default , handler: nil))
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
            alert.addAction(UIAlertAction(title: "Okay", style: .Default , handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    /*
    override func shouldUpdateFocusInContext(context: UIFocusUpdateContext) -> Bool {
        keepDown()
        return super.shouldUpdateFocusInContext(context)
    }*/

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
        if (newLanguageCode != languageCode){
            print("[Translation] Setting new language \(newLanguageCode)")
        
        fileDownloadedClosures.removeAll()
        languageCode=newLanguageCode
        /*
        Save settings language settings to settings.plist file in library folder.
        */
        
        let settings=NSUserDefaults.standardUserDefaults()
        //.setObject("", forKey: "")
        
        settings.setObject(newLanguageCode, forKey: "language")
        
        /* check for possible direction change*/
        
        if (newTextDirection != textDirection){
            textDirection=newTextDirection
            self.setViewControllers(self.viewControllers?.reverse(), animated: true)
        }
        
        /* download new translation */
        translatedKeyPhrases=dictionaryOfPath(base+"/"+version+"/translations/"+languageCode)?.objectForKey("translations")?.objectForKey(languageCode) as? NSDictionary
        if (translatedKeyPhrases != nil){ // if the language file was obtained
            /*These keys are what I found correspond to the navigation buttons on tv.jw.org*/
            
            var keyForButton:Array<String>=[]
            
            if (Home){
                keyForButton.append("lnkHomeView")
            }
            if (VOD){
                keyForButton.append("homepageVODBlockTitle")
            }
            if (Audio){
                keyForButton.append("homepageAudioBlockTitle")
            }
            if (Language){
                keyForButton.append("lnkLanguage")
            }
            if (Search){
                keyForButton.append("Search")
            }
            if (BETAMedia){
                keyForButton.append("Media On Demand")
            }
            
            let startIndex=0
            let endIndex=keyForButton.count
            
            /* replace titles */
            for var i=startIndex ; i<endIndex ; i++ {
                //var newTitle=translatedKeyPhrases?.objectForKey(keyForButton[i]) as! String
                var keyI=i
                if (textDirection==UIUserInterfaceLayoutDirection.RightToLeft){
                    keyI=endIndex-1-i
                }
                switch keyI {
                /*case 0:
                    newTitle=""
                case 1:
                    newTitle=""
                case 2:
                    newTitle=""
                case 3:
                    newTitle=""*/
                case 3:
                    //newTitle=" "
                    self.tabBar.items?[i].title="    "
                    
                    let fontattributes=[NSFontAttributeName:UIFont(name: "jwtv", size: 36)!,NSForegroundColorAttributeName:UIColor.grayColor()] as Dictionary<String,AnyObject>
                    self.tabBar.items?[i].setTitleTextAttributes(fontattributes, forState: .Normal)
                    
                default:
                    let newText=translatedKeyPhrases?.objectForKey(keyForButton[keyI]) as? String
                    if (newText != nil){
                        self.tabBar.items?[i].title=newText
                    }
                    else {
                        self.tabBar.items?[i].title=keyForButton[keyI]
                    }
                    
                    let fontattributes=[NSForegroundColorAttributeName:UIColor.grayColor()] as Dictionary<String,AnyObject>
                    self.tabBar.items?[i].setTitleTextAttributes(fontattributes, forState: .Normal)
                    
                    break
                }
            }
            
        }
        else {
            self.performSelector("displayUnableToConnect", withObject: self, afterDelay: 1.0)
        }
        print("completed")
            checkBranchesFor("language")
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
