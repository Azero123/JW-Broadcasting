//
//  AppDelegate.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 9/13/15.
//  Copyright © 2015 Austin Zelenka. All rights reserved.
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


/*

Communication with tv.jw.org (some speculation)

v1 appears to be a version number 

*/


let base="http://mediator.jw.org" // Current content distribution domain name
let version="v1" // Version folder?
var languageCode="E" // Initial language is English

var languageList:Array<NSDictionary>?=nil // Languages variable, if this doesn't recieve content then the app doesn't work
var textDirection=UIUserInterfaceLayoutDirection.LeftToRight // This specifies whether the current language direction is right to left or left to right
var cacheDirectory=NSSearchPathForDirectoriesInDomains(.CachesDirectory , .UserDomainMask, true).first


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
            //If in simulator use library directory as it will not delete our precious files.
            cacheDirectory=NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first
            
        #endif
        
        
        
        let pathForSliderData=base+"/"+version+"/settings/"+languageCode+"?keys=WebHomeSlider"
        let streamingScheduleURL=base+"/"+version+"/schedules/"+languageCode+"/Streaming?utcOffset=0"
        let latestVideosPath=base+"/"+version+"/categories/"+languageCode+"/LatestVideos?detailed=1"
        dictionaryOfPath(pathForSliderData)
        dictionaryOfPath(streamingScheduleURL)
        dictionaryOfPath(latestVideosPath)
        
        if (unfold(pathForSliderData+"|settings|WebHomeSlider|slides|count") != nil){
            print("[Preload] Featured successful")
            for var i=0; i<unfold(pathForSliderData+"|settings|WebHomeSlider|slides|count") as! Int ; i++ {
                imageUsingCache(unfold(pathForSliderData+"|settings|WebHomeSlider|slides|\(i)|item|images|pnr|lg") as! String)
            }
        }
        
        if (unfold("\(streamingScheduleURL)|category|subcategories|count") != nil){
            print("[Preload] Streaming successful")
            for var i=0; i<unfold("\(streamingScheduleURL)|category|subcategories|count") as! Int ; i++ {
                imageUsingCache(unfold("\(streamingScheduleURL)|category|subcategories|\(i)|images|wss|sm") as! String)
            }
        }
        
        
        if (unfold("\(latestVideosPath)|category|media|count") != nil){
            print("[Preload] Latest videos successful")
            for var i=0; i<unfold("\(latestVideosPath)|category|media|count") as! Int ; i++ {
                imageUsingCache(unfold("\(latestVideosPath)|category|media|\(i)|images|lsr|md") as! String)
            }
        }
        
        
        /*
        code for caching every file in VOD
        This is togglable in control.swift
        */
        
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        
        let categoriesDirectory=base+"/"+version+"/categories/"+languageCode
        let VODURL=categoriesDirectory+"/VideoOnDemand?detailed=1"
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            fetchDataUsingCache(VODURL, downloaded: {
                print("[PREDOWNLOAD] Video On Demand")
                
                if (aggressivePreload){
                    let videoOnDemandData=dictionaryOfPath(VODURL, usingCache: false)
                    if (videoOnDemandData != nil){
                        for (var index=0; index<(videoOnDemandData!["category"]!["subcategories"]! as! NSArray).count ; index++){
                            
                            let subcat=(((videoOnDemandData!["category"] as! NSDictionary)["subcategories"] as! NSArray)[index] as! NSDictionary)
                            let subcategoryDirectory=categoriesDirectory+"/"+(subcat["key"] as! String)+"?detailed=1"
                            
                            
                            fetchDataUsingCache(subcategoryDirectory, downloaded: {
                                
                                var subsubcats:Array<NSDictionary>=[]
                                print("[PREDOWNLOAD] \(subcat["key"])")
                                //let subcategoryData:Array<NSDictionary>=[]
                                
                                let downloadedJSON=dictionaryOfPath(subcategoryDirectory, usingCache: false)
                                if (downloadedJSON?["category"]!["media"] != nil){
                                    subsubcats.append(downloadedJSON!["category"] as! NSDictionary)
                                }
                                else if (downloadedJSON!["category"]!["subcategories"] != nil){
                                    subsubcats=downloadedJSON!["category"]!["subcategories"] as! Array<NSDictionary>
                                }
                                print("[COMPILED] \(subcat["key"]) \(subcategoryDirectory)")
                                
                                let priorityRatios=["pns","pss","wsr","lss","wss"]
                                for (var index=0; index<(subsubcats).count ; index++){
                                    
                                    
                                    for (var indexB=0; indexB<(subsubcats[index]["subcategories"] as! NSArray).count ; indexB++){
                                        for (var indexC=0; indexC<(subsubcats[index]["subcategories"]![indexB]["media"] as! NSArray).count ; indexC++){
                                            //print("subsub: \(index) \(indexB) \(indexC) = \(subsubcats[index]["subcategories"]![indexB]["media"])")
                                            let imageRatios=(subsubcats[index]["subcategories"]![indexB]["media"] as! NSArray)[indexC]["images"]
                                            
                                            var imageURL:String?=""
                                            
                                            for ratio in imageRatios!!.allKeys {
                                                for priorityRatio in priorityRatios.reverse() {
                                                    if (ratio as? String == priorityRatio){
                                                        
                                                        if (unfold(imageRatios, instructions: ["\(ratio)","lg"]) != nil){
                                                            imageURL = unfold(imageRatios, instructions: ["\(ratio)","lg"]) as? String
                                                        }
                                                        else if (unfold(imageRatios, instructions: ["\(ratio)","md"]) != nil){
                                                            imageURL = unfold(imageRatios, instructions: ["\(ratio)","md"]) as? String
                                                        }
                                                        else if (unfold(imageRatios, instructions: ["\(ratio)","sm"]) != nil){
                                                            imageURL = unfold(imageRatios, instructions: ["\(ratio)","sm"]) as? String
                                                        }
                                                    }
                                                }
                                            }
                                            if (imageURL == ""){
                                                let sizes=unfold(imageRatios, instructions: [imageRatios!!.allKeys.first!]) as? NSDictionary
                                                imageURL=unfold(sizes, instructions: [sizes!.allKeys.first!]) as? String
                                            }
                                            
                                            
                                            //print("[PREDOWNLOAD] \(imageURL)")
                                            imageUsingCache(imageURL!)
                                            
                                        }
                                    }
                                }
                                
                            })
                        }
                    }
                    
                }
                print("[VOD] preload")
                
            })
            let AudioURL=categoriesDirectory+"/Audio?detailed=1"
            fetchDataUsingCache(AudioURL, downloaded: {
                print("[Audio] preloaded")
            })
        }
        

        
        
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

    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        cachedFiles=[:]
    }

}

