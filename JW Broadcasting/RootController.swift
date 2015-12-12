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
let logoImageView=UIImageView(image: UIImage(named: "JW-White-Background-Blue.png"))
let logoLabelView=UILabel()

class rootController: UITabBarController, UITabBarControllerDelegate{
    
    
    var _disableNavBarTimeOut=false
    var disableNavBarTimeOut:Bool {
        set (newValue){
            _disableNavBarTimeOut=newValue
            if (newValue == true){
                timer?.invalidate()
            }
            else {
                timer=NSTimer.scheduledTimerWithTimeInterval(12, target: self, selector: "hide", userInfo: nil, repeats: false)
            }
        }
        get {
            return _disableNavBarTimeOut
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        Create a JW.org logo on the left side of the tab bar.
        */
        
        if (JWLogo){
            
            logoLabelView.font=UIFont(name: "jwtv", size: self.tabBar.frame.size.height+60) // Use the font from jw.org to display the jw logo
            logoLabelView.frame=CGRect(x: 110, y: 10+10, width: self.tabBar.frame.size.height+60, height: self.tabBar.frame.size.height+60)//initial logo position and size
            logoLabelView.text=""//The unique key code for the JW.org logo
            logoLabelView.textAlignment = .Left
            logoLabelView.lineBreakMode = .ByClipping
            
            logoLabelView.frame=CGRect(x: 110, y: 10+10, width: logoLabelView.intrinsicContentSize().width, height: self.tabBar.frame.size.height+60)//corrected position
            
            logoLabelView.textColor=UIColor(colorLiteralRed: 0.3, green: 0.44, blue: 0.64, alpha: 1.0) // JW blue color
            self.tabBar.addSubview(logoLabelView)
        
        }
        
        
        /*
        This loop cycles through all the view controllers and their corresponding tab bar items.
        All the tab bar items are set to grey text.
        If the view controller is disabled in the control file then it is removed.
        The Language view controllers text is made to be the language icon found in the jwtv.tff font file.
        
        */
        for viewController in self.viewControllers! {
            let fontattributes=[NSForegroundColorAttributeName:UIColor.grayColor()] as Dictionary<String,AnyObject>
            let tabBarItem=self.tabBar.items?[(self.viewControllers?.indexOf(viewController))!]
            if (tabBarItem != nil){
                tabBarItem!.setTitleTextAttributes(fontattributes, forState: .Normal)
            }
            if (viewController.isKindOfClass(HomeController.self)){//Remove home page if disabled
                if (Home==false){
                    self.viewControllers?.removeAtIndex((self.viewControllers?.indexOf(viewController))!)
                }
            }
            else if (viewController.isKindOfClass(VideoOnDemandController.self)){//Remove VOD page if disabled
                if (VOD==false){
                    self.viewControllers?.removeAtIndex((self.viewControllers?.indexOf(viewController))!)
                }
            }
            else if (viewController.isKindOfClass(AudioController.self)){//Remove Audio page if disabled
                if (Audio==false){
                    self.viewControllers?.removeAtIndex((self.viewControllers?.indexOf(viewController))!)
                }
            }
            else if (viewController.isKindOfClass(LanguageSelector.self)){//Remove Language page if disabled
                if (Language==false){
                    self.viewControllers?.removeAtIndex((self.viewControllers?.indexOf(viewController))!)
                }
                else {//Set language page to language icon
                    self.tabBar.items?[(self.viewControllers?.indexOf(viewController))!].title="    "
                    let fontattributes=[NSFontAttributeName:UIFont(name: "jwtv", size: 36)!,NSForegroundColorAttributeName:UIColor.grayColor()] as Dictionary<String,AnyObject>
                    self.tabBar.items?[(self.viewControllers?.indexOf(viewController))!].setTitleTextAttributes(fontattributes, forState: .Normal)
                }
            }
            else if (viewController.isKindOfClass(SearchController.self)){//Remove Search page if disabled
                if (Search==false){
                    self.viewControllers?.removeAtIndex((self.viewControllers?.indexOf(viewController))!)
                }
            }
            else if (viewController.isKindOfClass(MediaOnDemandController.self)){//Remove MOD page if disabled
                if (BETAMedia==false){
                    self.viewControllers?.removeAtIndex((self.viewControllers?.indexOf(viewController))!)
                }
                else {
                    self.tabBar.items?[(self.viewControllers?.indexOf(viewController))!].title="Video on Demand"
                }
            }
        }
        
        if (textDirection == .RightToLeft){ // select the far right page if language is right to left
            self.selectedIndex=(self.viewControllers?.count)!-1
        }
        else {
            self.selectedIndex=0
        }
        
        
        
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
        
        
        
        if (disableNavBarTimeOut == false){
            timer=NSTimer.scheduledTimerWithTimeInterval(12, target: self, selector: "hide", userInfo: nil, repeats: false)
        }
            
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swiped:")
        swipeRecognizer.direction = .Right //|| .Up || .Left || .Right
        self.view.addGestureRecognizer(swipeRecognizer)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)];
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    func displayFailedToFindLanguage(){
        //Alert the user that we do not know what language they are using
        let alert=UIAlertController(title: "Language Unknown", message: "Unable to find a language for you.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .Default , handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayUnableToConnect(){
        
        //Let the user know that we were not able to connect to JW.org
        if (translatedKeyPhrases != nil){
            //alert the user translated text that connection failed
            let alert=UIAlertController(title: translatedKeyPhrases?.objectForKey("msgAPIFailureErrorTitle") as? String, message: translatedKeyPhrases?.objectForKey("msgAPIFailureErrorBody")as? String, preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            //alert the user without translated text that the connection failed.
            let alert=UIAlertController(title: "Cannot connect to JW Broadcasting", message: "Make sure you're connected to the internet then try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default , handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func tapped(tap:UIGestureRecognizer){
        //upon tap of the remote we bring the tab bar down
        keepDown()
    }
    
    func swipe(recognizer:UIGestureRecognizer){
        //upon swipe of the remote we bring the tab bar down
        keepDown()
    }
    
    func swiped(sender:UISwipeGestureRecognizer){
        //upon swipe of the remote we bring the tab bar down
        keepDown()
    }
    
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?){
        //upon press of the remote we bring the tab bar down
        keepDown()
        
        super.pressesBegan(presses, withEvent: event)
        
    }
    var timer:NSTimer?=nil
    
    func keepDown(){
        /*
        This method restarts thte timer for how long the tab bar can be seen.
        */
        
        timer?.invalidate()
        if (disableNavBarTimeOut == false){
            timer=NSTimer.scheduledTimerWithTimeInterval(12, target: self, selector: "hide", userInfo: nil, repeats: false)
        }
        self.setTabBarVisible(true, animated: true)
    }
    
    func hide(){
        //Hides tab bar
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
            if (JWLogo){
                if (textDirection == .RightToLeft){
                    logoLabelView.textAlignment = .Right
                    logoLabelView.frame=CGRect(x: self.tabBar.frame.size.width-logoLabelView.frame.size.width, y: -40+10, width: self.tabBar.frame.size.height+60, height: self.tabBar.frame.size.height+60)
                    
                    //logoLabelView.frame=CGRect(x: self.tabBar.frame.size.width-110-logoLabelView.frame.size.width, y: 10, width: logoLabelView.intrinsicContentSize().width+200, height: self.tabBar.frame.size.height+60)
                }
                else {
                    logoLabelView.textAlignment = .Left
                    
                    logoLabelView.frame=CGRect(x: 110, y: logoLabelView.frame.origin.y+10, width: logoLabelView.intrinsicContentSize().width+200, height: self.tabBar.frame.size.height+60)
                    //logoLabelView.frame=CGRect(x: 110, y: 10, width: self.tabBar.frame.size.height+60, height: self.tabBar.frame.size.height+60)
                }
            }
        }
        
        /* download new translation */
        translatedKeyPhrases=dictionaryOfPath(base+"/"+version+"/translations/"+languageCode)?.objectForKey("translations")?.objectForKey(languageCode) as? NSDictionary
            
        if (translatedKeyPhrases != nil){ // if the language file was obtained
            /*These keys are what I found correspond to the navigation buttons on tv.jw.org*/
            
            let startIndex=0
            let endIndex=self.viewControllers!.count
            
            /* replace titles */
            for var i=startIndex ; i<endIndex ; i++ {
                
                var keyForButton=""
                
                let viewController = self.viewControllers![i]
                
                if (viewController.isKindOfClass(HomeController.self)){
                    keyForButton="lnkHomeView"
                }
                else if (viewController.isKindOfClass(MediaOnDemandController.self)){
                    keyForButton="homepageVODBlockTitle"//
                }
                else if (viewController.isKindOfClass(VideoOnDemandController.self)){
                    keyForButton="homepageVODBlockTitle"//
                }
                else if (viewController.isKindOfClass(AudioController.self)){
                    keyForButton="homepageAudioBlockTitle"//
                }
                else if (viewController.isKindOfClass(LanguageSelector.self)){
                    //"lnkLanguage"//
                    keyForButton="    "
                    /*self.tabBar.items?[(self.viewControllers?.indexOf(viewController))!].title="    "
                    let fontattributes=[NSFontAttributeName:UIFont(name: "jwtv", size: 36)!,NSForegroundColorAttributeName:UIColor.grayColor()] as Dictionary<String,AnyObject>
                    self.tabBar.items?[(self.viewControllers?.indexOf(viewController))!].setTitleTextAttributes(fontattributes, forState: .Normal)*/
                }
                else if (viewController.isKindOfClass(SearchController.self)){
                    keyForButton="Search"
                }
                
                
                let newText=translatedKeyPhrases?.objectForKey(keyForButton) as? String
                if (newText != nil){
                    self.tabBar.items?[i].title=newText
                }
                else {
                    self.tabBar.items?[i].title=keyForButton
                }
                
                if (viewController.isKindOfClass(LanguageSelector.self)){
                    let fontattributes=[NSFontAttributeName:UIFont(name: "jwtv", size: 36)!,NSForegroundColorAttributeName:UIColor.grayColor()] as Dictionary<String,AnyObject>
                    self.tabBar.items?[(self.viewControllers?.indexOf(viewController))!].setTitleTextAttributes(fontattributes, forState: .Normal)
                }
                else {
                    let fontattributes=[NSForegroundColorAttributeName:UIColor.grayColor()] as Dictionary<String,AnyObject>
                    self.tabBar.items?[i].setTitleTextAttributes(fontattributes, forState: .Normal)
                }
            }
            
        }
        else {
            self.performSelector("displayUnableToConnect", withObject: self, afterDelay: 1.0)
        }
        print("completed")
            checkBranchesFor("language")
        }
        
        
        if (false){
            var subviews:Array<UIView>=self.tabBar.subviews
            logoLabelView.hidden=false
            while subviews.first != nil {
                let subview = subviews.first
                subviews.removeFirst()
                subviews.appendContentsOf(subview!.subviews)
                if (subview!.isKindOfClass(NSClassFromString("UITabBarButton")!)){
                    if (CGRectIntersectsRect((subview?.frame)!, logoLabelView.frame)){
                        logoLabelView.hidden=true
                    }
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
