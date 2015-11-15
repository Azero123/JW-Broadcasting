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


let base="http://mediator.jw.org"
let version="v1"
var languageCode="E"

var languageList:Array<NSDictionary>?=nil
var textDirection=UIUserInterfaceLayoutDirection.LeftToRight


var cachedFiles:Dictionary<String,NSData>=[:]
var cachedBond:Dictionary<String,AnyObject?>=[:]

let simulateOffline=false
let offlineStorage=true
let offlineStorageSaving=true

var branchListeners:Dictionary<String, Array< () -> Any >>=[:]

func addBranchListener(instruction:String, serverBonded: () -> Void){
    if (branchListeners[instruction] == nil){
        branchListeners.updateValue([], forKey: instruction)
    }
    branchListeners[instruction]?.append(serverBonded)
    
    if (cachedFiles[instruction.componentsSeparatedByString("|").first!] != nil){
        print("[Bonding] using cache... \(instruction.componentsSeparatedByString("|").first!)")
        serverBonded()
    }
    else {
        fetchDataUsingCache(instruction, downloaded: nil, usingCache: true)
        
        print("[Bonding] using download... \(instruction.componentsSeparatedByString("|").first!)")
        /*

        
        
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath: myFilePath error:&error];
        
        if (attributes != nil) {
        NSDate *date = (NSDate*)[attributes objectForKey: NSFileModificationDate];
        NSLog(@"Date modiifed: %@", [date description]);
        }
        else {
        NSLog(@"Not found");
        }
        */
        //NSURLRequest(URL: NSURL(string: instruction.componentsSeparatedByString("|").first!)!
        let trueURL=NSURL(string: instruction.componentsSeparatedByString("|").first!)!
        
        let modificationDateRequest=NSURLRequest(URL: trueURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 20)
        
        let task=NSURLSession.sharedSession().dataTaskWithRequest(modificationDateRequest, completionHandler: { (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            
            let libraryDirectory=NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first
            let storedPath=libraryDirectory!+"/"+trueURL.path!.stringByReplacingOccurrencesOfString("/", withString: "-")
            
            do {
                let formatter=NSDateFormatter()
                formatter.dateFormat = "EEE, d MMM yyyy H:mm:ss v"
                //NSLog("online:\(formatter.dateFromString((response as! NSHTTPURLResponse).allHeaderFields["Last-Modified"] as! String))")
                //formatter.dateFromString(
                if (NSFileManager.defaultManager().fileExistsAtPath(storedPath)){
                let onlineDate=formatter.dateFromString((response as! NSHTTPURLResponse).allHeaderFields["Last-Modified"] as! String)
                let offlineDate=try NSFileManager.defaultManager().attributesOfItemAtPath(storedPath)[NSFileModificationDate] as! NSDate
                    if ((onlineDate?.timeIntervalSince1970)!-offlineDate.timeIntervalSince1970>60){
                        print("renew \(trueURL)")
                        fetchDataUsingCache(instruction, downloaded: nil, usingCache: false)
                    }
                }
                else {
                    
                    fetchDataUsingCache(instruction, downloaded: nil, usingCache: false)
                }
                
            }
            catch {
                print(error)
            }
            
            
        })
        
        task.resume()

    }
    //"\(pathForSliderData)|settings|WebHomeSlider|slides|\(indexPath.row)|item|images|pnr|lg"
}

func checkBranchesFor(updatedInstruction:String){
    let updatedFile=updatedInstruction.componentsSeparatedByString("|").first
    for branch in branchListeners.keys {
        if (branch.componentsSeparatedByString("|").first == updatedFile){
            for responder in branchListeners[branch]! {
                responder()
            }
        }
    }
}

func unfold(instruction:String)-> AnyObject?{
    let instructions=NSString(string: instruction).componentsSeparatedByString("|")
    return unfold(nil, instructions: instructions)
}

func unfold(from:AnyObject?, var instructions:[AnyObject]) -> AnyObject?{
    var source:AnyObject?=nil
    if (from?.isKindOfClass(NSDictionary.self) == true){
        source=(from as! NSDictionary).objectForKey(instructions[0])
    }
    else if (from?.isKindOfClass(NSArray.self) == true){
        let stringval=instructions[0] as! String
        source=(from as! NSArray).objectAtIndex(Int((stringval as NSString).intValue))
    }
    else if (from==nil){
        let sourceURL=NSURL(string: (instructions[0]) as! String)
        if (cachedBond[instructions[0] as! String] != nil){
            source=cachedBond[instructions[0] as! String]!
        }
        else if (sourceURL != nil && sourceURL?.scheme != nil && sourceURL?.host != nil){
            source=sourceURL
            var sourceData=cachedFiles[instructions[0] as! String]
            if (sourceData != nil){
                source=sourceData
                
                do {
                    
                    
                    let sourceString=try NSMutableAttributedString(data:sourceData!,
                        options:[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding],
                        documentAttributes:nil).string
                    
                    sourceData=sourceString.dataUsingEncoding(NSUTF8StringEncoding)
                    
                    /* Just double check real quick that the class is truly available */
                    
                    
                    if (NSClassFromString("NSJSONSerialization") != nil){
                        
                        /*attempt serialization*/
                        
                        let object=try NSJSONSerialization.JSONObjectWithData(sourceData!, options: NSJSONReadingOptions.MutableContainers)
                        /*if it returned an actual NSDictionary then return it*/
                        
                        if (object.isKindOfClass(NSDictionary.self)){
                            source=object as? NSDictionary
                        }
                    }
                    
                }
                catch {
                    
                    /*log out any errors that might have occured*/
                    
                    print(error)
                }
               cachedBond[instructions[0] as! String]=source
            }
            else {
                return nil
            }
        }
    }
    
    if (source == nil){
        return nil
    }
    
    instructions.removeFirst()
    if (instructions.count>0){
        return unfold(source, instructions:  instructions)
    }
    return source
}

func imageUsingCache(imageURL:String) -> UIImage?{
    /*
    This method opens an image from memory if already loaded otherwise it performs a normal data fetch operation.
    
    Read comments in:
    func dataUsingCache(fileURL:String) -> NSData
    For more details
    
    */
    let data=dataUsingCache(imageURL)
    if (data != nil){
    return UIImage(data:data!)!
    }
    return nil
}

var fileDownloadedClosures:Dictionary<String, Array< () -> Any >>=[:]


func fetchDataUsingCache(fileURL:String, downloaded: (() -> Void)?){
    fetchDataUsingCache(fileURL, downloaded: downloaded, usingCache: true)
}

func fetchDataUsingCache(fileURL:String, downloaded: (() -> Void)?, usingCache:Bool){
    
    
    if (fileDownloadedClosures[fileURL] == nil ){
        fileDownloadedClosures.updateValue([], forKey: fileURL)
    }
    if (downloaded != nil){
        fileDownloadedClosures[fileURL]?.append(downloaded!)//.insert(downloaded, atIndex: fileDownloadedClosures.count)
    }
        
    var data:NSData? = nil
    
    let trueURL=NSURL(string: fileURL)!
    let libraryDirectory=NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first
    let storedPath=libraryDirectory!+"/"+trueURL.path!.stringByReplacingOccurrencesOfString("/", withString: "-")
    
    
        if (usingCache){
            if ((cachedFiles[fileURL]) != nil){ //STEP 1
                data=cachedFiles[fileURL]!
            }
            else { //STEP 2
                
                if (offlineStorage){
                    let stored=NSData(contentsOfFile: storedPath)
                    
                    cachedFiles[fileURL]=stored
                    data=stored
                    if (fileDownloadedClosures[fileURL] != nil){
                        for closure in fileDownloadedClosures[fileURL]! {
                            closure()
                        }
                    }
                    checkBranchesFor(fileURL)
                    
                    return
                }
            }
        }
        //STEP 3
        if (data == nil){
            
            var cachePolicy=NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
            if (usingCache){
                cachePolicy=NSURLRequestCachePolicy.ReturnCacheDataDontLoad
            }
            
            let request=NSURLRequest(URL: trueURL, cachePolicy: cachePolicy, timeoutInterval: 20)
            
            let task=NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data:NSData?, padawan: NSURLResponse?, error:NSError?) -> Void in
                if (data != nil && simulateOffline == false){ //File successfully downloaded
                    if (offlineStorageSaving){
                        data?.writeToFile(storedPath, atomically: true) //Save file locally for use later
                    }
                    cachedFiles[fileURL]=data //Save file to memory
                    // data=cachedFiles[fileURL!]! //Use as local variable
                    
                    for closure in fileDownloadedClosures[fileURL]! {
                        closure()
                    }
                    checkBranchesFor(fileURL)
                    
                    return
                }
                else {
                    print("[ERROR] Failed to download resource \(fileURL) \(error)")
                }
            })
            task.resume()
        }
        else {
            
            if (downloaded != nil){
                downloaded!()
            }
        }
    
}

func dataUsingCache(fileURL:String) -> NSData?{
    /*
    Refer to:
    func dataUsingCache(fileURL:String, usingCache:Bool) -> NSData?
    Always uses cache if available.
    */
    return dataUsingCache(fileURL, usingCache: true)
}

func dataUsingCache(fileURL:String, usingCache:Bool) -> NSData?{
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
    
    if (usingCache){
        if ((cachedFiles[fileURL]) != nil){ //STEP 1
            data=cachedFiles[fileURL]!
        }
        else { //STEP 2
            if (offlineStorage){
                let stored=NSData(contentsOfFile: storedPath)
                cachedFiles[fileURL]=stored
                data=stored
                
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    dispatch_async(dispatch_get_main_queue()) {
                        checkBranchesFor(fileURL)
                    }
                }
            }
            
        }
    }
    
    //STEP 3
    
    
    var attempts=0 //Amount of attempts to download the file
    let maxAttempts=10//Amount of possible attempts
    var badConnection=false
    
    while (data == nil){ //If the file is not downloaded download it
        if (attempts>maxAttempts){ //But if we have tried 10 times then give up
            print("Failed to download \(fileURL)")
            return nil //give up
        }
        else {
            do {
            let downloadedData=try NSData(contentsOfURL: trueURL, options: .UncachedRead) //Download
                if (simulateOffline == false){ //File successfully downloaded
                    if (offlineStorageSaving){
                        downloadedData.writeToFile(storedPath, atomically: true) //Save file locally for use later
                    }
                    cachedFiles[fileURL]=downloadedData //Save file to memory
                    data=cachedFiles[fileURL]! //Use as local variable
                    
                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                        dispatch_async(dispatch_get_global_queue(priority, 0)) {
                            dispatch_async(dispatch_get_main_queue()) {
                                checkBranchesFor(fileURL)
                            }
                    }
                    return data! //Return file
                }
            }
            catch {
                print(error)
            }
        }
            
        attempts++ //Count another attempt to download the file
        if (badConnection==false){
            print("Bad connection \(fileURL)")
            badConnection=true
        }
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
        var sliderData=dataUsingCache(path, usingCache: usingCache)
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
                cachedBond[path]=object
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

    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        cachedFiles=[:]
    }

}

