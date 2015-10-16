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
    
    Read comments in:
    func dataUsingCache(fileURL:String) -> NSData
    For more details
    
    */
    return UIImage(data: dataUsingCache(imageURL)!)!
}

func dataUsingCache(fileURL:String) -> NSData?{
    /*
    Refer to:
    func dataUsingCache(fileURL:String, usingCashe:Bool) -> NSData?
    Always uses cache if available.
    */
    return dataUsingCache(fileURL, usingCashe: true)
}

func dataUsingCache(fileURL:String, usingCashe:Bool) -> NSData?{
    /*
    This method is used to speed up reopening the same file using caching if usingCache is true.
    
    STEP 1
    
    Check if file is already in memory cache. This will only occure if STEP 2/3 have occured successfully for the same fileURL with usingCache == true
    
    STEP 2
    
    Check if file has been stored in library directory. If so save it to active memory and return data.
    
    STEP 3
    
    Attempt online fetch of fileURL.
    
    The file is repeatedly requested up to 10 (maxAttempts) times just in cases of poor connection.
    
    If failed nil is returned
    
    */
    var data:NSData? = nil
    
    let trueURL=NSURL(string: fileURL)!
    let libraryDirectory=NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first
    let storedPath=libraryDirectory!+"/"+trueURL.path!.stringByReplacingOccurrencesOfString("/", withString: "-")
    
    if (usingCashe){
        if ((cachedFiles[fileURL]) != nil){ //STEP 1
            data=cachedFiles[fileURL]!
        }
        else { //STEP 2
        
            do {
                let stored=NSData(contentsOfFile: storedPath)
                cachedFiles[fileURL]=stored
                data=stored
            
            }
            catch {
            
            /*log out any errors that might have occured*/
            
            print(error)
                
            }
        }
    }
    
    //STEP 3
    
    
    var attempts=0 //Amount of attempts to download the file
    let maxAttempts=10//Amount of possible attempts
    
    while (data == nil){ //If the file is not downloaded download it
        if (attempts>maxAttempts){ //But if we have tried 10 times then give up
            return nil //give up
        }
        else {
            let downloadedData=NSData(contentsOfURL: trueURL) //Download
            
            if (downloadedData != nil){ //File successfully downloaded
                
                downloadedData?.writeToFile(storedPath, atomically: true) //Save file locally for use later
                cachedFiles[fileURL]=downloadedData //Save file to memory
                data=cachedFiles[fileURL]! //Use as local variable
                return data! //Return file
            }
        }
        attempts++ //Count another attempt to download the file
        print("Bad connection")
    }
    return data! //THIS CAN NOT BE CALLED this is just for the compiler
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
    Refer to func dictionaryOfPath(path: String, usingCache: Bool) -> NSDictionary?
    
    WARNING
    
    This method is failable depending on what data is passed in.
    */
    
    return dictionaryOfPath(path, usingCache: true)
}


func dictionaryOfPath(path: String, usingCache: Bool) -> NSDictionary?{
    /*
    This method breaks down JSON files converting them to NSDictionaries.
    
    Firstly grabs data from the path parameter.
    Second strips away all HTML entities (E.g. &amp; = &)
    Finally using NSJSONSerialization the data is converted into a usable NSDictionary class.
    
    
    WARNING
    
    This method is failable depending on what data is passed in.
    
    */
    
    
    
    do {
        var sliderData=dataUsingCache(path, usingCashe: usingCache)
        
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

