//
//  AppDelegate.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/13/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import UIKit



/*

known resources

List of translations

http://mediator.jw.org/v1/translations/E
http://mediator.jw.org/v1/categories/E
settings/E?keys=WebHomeSlider

http://mediator.jw.org/v1/categories/E/LatestVideos?detailed=1

http://mediator.jw.org/v1/languages/E/web

*/


let base="http://mediator.jw.org"
let version="v1"
var languageCode="E"

var languageList:Array<NSDictionary>?=nil
var textDirection=UIUserInterfaceLayoutDirection.LeftToRight


var cachedFiles:Dictionary<String,NSData>=[:]

let offlineStorage=false
let offlineStorageSaving=false

func imageUsingCache(imageURL:String) -> UIImage{
    /*
    This method opens an image from memory if already loaded otherwise it performs a normal data fetch operation.
    
    WARNING plossibly unsafe on poor or no connection
    
    Read comments in:
    func dataUsingCache(fileURL:String) -> NSData
    For more details
    
    */
    return UIImage(data: dataUsingCache(imageURL)!)!
}

func dataUsingCache(fileURL:String) -> NSData?{
    /*
    This method is used to speed up reopening the same file.
    The file is repeatedly requested until it is found
    
    
    WARNING
    
    Need to add a break so when under bad connection it doesn't continue for forever and finally notifies the user that the connection is too poor or that something is blocking the connection.
    */
    var data:NSData? = nil
    if ((cachedFiles[fileURL]) != nil){
        data=cachedFiles[fileURL]!
    }
    
    
    var attempts=0
    while (data == nil){
        if (attempts>10){
            return nil
        }
        else {
            let imageTrueURL=NSURL(string: fileURL)!
            let imageData=NSData(contentsOfURL: imageTrueURL)
            
            if (imageData != nil){
                cachedFiles[fileURL]=imageData
                data=cachedFiles[fileURL]!
                let cacheCopy=cachedFiles
                saveCache(cacheCopy)
                print("attempts \(attempts)")
                return data!
            }
        }
        attempts++
    }
    return data!
}

var saving=false
var nextSave:Dictionary<String,NSData>?=nil

func saveCache(cache: Dictionary<String,NSData>){
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    if (saving == false){
        saving=true
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            /*
            save dictionary to library folder
            
            This is currently unimplemented!
            */
            saving=false
        }
    }
    else {
        nextSave=cache
    }
}

func dictionaryOfPath(path: String) -> NSDictionary?{
    /*
    This method breaks down JSON files converting them to NSDictionaries.
    
    Firstly grabs data from the path parameter.
    Second strips away all HTML entities (E.g. &amp; = &)
    Finally using NSJSONSerialization the data is converted into a usable NSDictionary class.


    WARNING
    
    This method is failable depending on what data is passed in.
    
    
    Things to add:
    
    Caching system
    
    */
    
    
    
    do {
        var sliderData=dataUsingCache(path)
        
        if (sliderData == nil){
            return nil
        }
        
        
        let sliderString=try NSMutableAttributedString(data:sliderData!,
            options:[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding],
            documentAttributes:nil).string
        
        sliderData=sliderString.dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Just double check real quick that the class is truly available */
        
        
        if (NSClassFromString("NSJSONSerialization") != nil){
            
            /*attempt serialization*/
            
            let object=try NSJSONSerialization.JSONObjectWithData(sliderData!, options: NSJSONReadingOptions.MutableContainers)
            
            /*if it returned an actual NSDictionary then return it*/
            
            if (object.isKindOfClass(NSDictionary.self)){
                return object as? NSDictionary
            }
        }
        
    }
    catch {
        
        /*log out any errors that might have occured*/
        
        print(error)
    }
    return nil
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

