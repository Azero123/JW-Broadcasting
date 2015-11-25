//
//  ResourceHandling.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/15/15.
//  Copyright © 2015 xquared. All rights reserved.
//


/*

MAIN POINT

We need this code for hands on control of our caching system because we have to update multiple places from the same file download.


DETAIL

The goal of this code is to create a data fetching system that notifies ALL locations of the app when a file is retrieved. Secondly the goal of this is to be able to EVENTUALLY change a single property for language and have the app update itself when not under heavy load or preoccupied like playing a video or large animations.





METHODS

There are 2 major finished downloading methods:

func fetchDataUsingCache(...) (Relatively completed.)
func addBranchListener(...)/func checkBranchesFor(...) (not finished.)




func fetchDataUsingCache(...)

Is a 1 time return event. The next time we have a usable file with the url in fileURL:Sring a response is sent to the downloaded() closure (block for Objective-C users).

This can optionally have a variable of usingCache:Bool. If usingCache==true then downloaded() can be run immediately if there is a cached version of this file either in ram memory or in file system/drive space. If this file is not cached or usingCache==false then a request for the file is made and downloaded() is fired on completion. ALSO checkBranchesFor(...) is fired to update branches. (See next paragraph)





func addBranchListener(...)

Any time instruction:String is changed/updated (see folding) the serverBonded() closure is triggered (block for Objective-C users) allowing the content to be updated.


NOTE This code is not yet finished but should ultimately replace MOST fetchDataUsingCache(...) calls.

-Why:

The point of branches are to have events and properties/variables that are set on a file update or replacement. Instead of using tons of variables all the content can be updated at 1 time even in collection views that can be sporadic. THIS WOULD BE CALLED MANY TIMES. Thus branches would need to be able to be run multiple times in a row without causing crashes or visual errors.

WARNING Keep code inside branches very clean and repeatable. Branches can be called at ANYTIME even when backgrounded.

-reference:

Branches use the text folding format see below.





func checkBranchesFor(...)

This updates all branches within and including the fold updatedInstruction:String. (see folding)

NOTE 
1. Likely should not be used outside of this file when finished.
2. Right now any subfold of updatedInstruction:String top fold will be called. This will be corrected to be only folds that have changed. (see folding)






func unfold(...) -> AnyObject?

This method uses the folding format to parse through JSON/Dictionary files/objects to prevent code repetition and incorrect handling of items. This means you only need to check the item of use and assign it a dynamicType instead of all its hierarchy elements.

This method is inline so to speed it up and not process the same files repeatedly, which could have a 0.3~ second delay or more, this method stores processed files for later reuse. Stored dictionaries are in cachedBond:Dictionary<String,AnyObject?>.

WARNING This method DOES NOT request new content, it is intended to be used AFTER a fetchDataUsingCache(...) or a branch update to confirm that this file has indeed in memory cache.




FOLDING

(When finished) This is a string that represents a specific item that can be contained within arrays, dictionaries, NSObjects, URLs, etc.

Currently the top item in a fold can only be a file, url, or the item can be a dead-end string exp: "language". The unfold(...) methods parse each sub fold by the character "|" however this may be changed or completely removed up to not be a string at all.


NOTE This is not a finished model


-Why:

There are a lot of JSON files with a lot of vary similar paths or urls with content that is sometimes only updated by one string or added object. Using this system everything is easier to manage, with far less variables and dynamic type handling which is annoying in swift. Lastly the code is a lot safer because unfold(...) can return nil and handle it very well.





func dataUsingCache(...)

This method uses the caching system to or does an inline request for data so this is intended to be used AFTER a fetchDataUsingCache(...) or a branch update to confirm that this file has indeed been downloaded. However this method will request the remote file if needed.




Extension methods
func imageUsingCache(...) -> UIImage?

Uses the result of dataUsingCache(...) to return a UIImage.

func dictionaryOfPath(path: String) -> NSDictionary?

Uses the result of dataUsingCache(...) to return a NSDictionary.

*/




import Foundation
import UIKit

var cachedFiles:Dictionary<String,NSData>=[:] // All files that have been accessed since app launch
var cachedBond:Dictionary<String,AnyObject?>=[:] // All JSON (and later also plist) files after being processed some files have a 0.3~ second interpretation time.
var branchListeners:Dictionary<String, Array< () -> Any >>=[:] // All branches (see addBranchListener(...)/checkBranchesFor(...)
var fileDownloadedClosures:Dictionary<String, Array< () -> Any >>=[:] // Events to be called by fetchDataUsingCache upon file download

func addBranchListener(instruction:String, serverBonded: () -> Void){
    
    /*
    
    Adds serverBonded() to the list of closures (blocks in Objective-C) to be called when file is updated.
    
    */
    
    let sourceURL=NSURL(string: (instruction.componentsSeparatedByString("|").first!) ) //Get the url of the branch to verify
    
    
    if (branchListeners[instruction] == nil){ // Create an array for the file
        branchListeners.updateValue([], forKey: instruction)
    }
    branchListeners[instruction]?.append(serverBonded) // Add closure to array
    
    
    /*
    
    If the file already is in memory then call an initial branch to get some content or data for the app to work with.
    And check for file updates
    
    */
    
    
    if (cachedFiles[instruction.componentsSeparatedByString("|").first!] != nil){ // if in memory
        
        serverBonded() // call update content methods
        if (sourceURL != nil && sourceURL?.scheme != nil && sourceURL?.host != nil){ // make sure this is a url
            
            refreshFileIfNeeded(sourceURL!) // check if the file needs to be updated

        }
    }
        
    /*
    
    The cached files failed to respond so let's see if this is a url at all and if it is fetch some data to update the branch.
        
    */
        
    else if (sourceURL != nil && sourceURL?.scheme != nil && sourceURL?.host != nil){
        fetchDataUsingCache(instruction, downloaded: nil, usingCache: true) // download file
    }
}
func checkBranchesFor(updatedInstruction:String){
    
    /*
    Update all branches that have been added by addBranchListener(...)
    
    NOTE
    This is not finished it needs to only update content when changed
    */
    
    let updatedFile=updatedInstruction.componentsSeparatedByString("|").first // get the file that changed
    for branch in branchListeners.keys { // get all branches
        if (branch.componentsSeparatedByString("|").first == updatedFile){ // compare the branches to see if it is the same file
            for responder in branchListeners[branch]! { // if there are things to be done in this branch do them
                responder()
            }
        }
    }
}

func refreshFileIfNeeded(trueURL:NSURL){
    
    /*
    
    If the file does not exist update the file.
    Otherwise ask the server for the modification date.
    If the date is too old then download the new file.
    
    */
    
    let cacheDirectory=NSSearchPathForDirectoriesInDomains(.CachesDirectory , .UserDomainMask, true).first // folder that we have read/write privileges
    let storedPath=cacheDirectory!+"/"+trueURL.path!.stringByReplacingOccurrencesOfString("/", withString: "-") // the desired stored file path
    
    if (NSFileManager.defaultManager().fileExistsAtPath(storedPath) == false){ // there is no file here
        fetchDataUsingCache(trueURL.absoluteString, downloaded: nil, usingCache: true) // download the file
    }
    else { // there is a file here.
        let modificationDateRequest=NSMutableURLRequest(URL: trueURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: requestTimeout)
        modificationDateRequest.HTTPMethod="HEAD" // make a request for only the header information to get the modification date
        let task=NSURLSession.sharedSession().dataTaskWithRequest(modificationDateRequest, completionHandler: { (data:NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            // return response closure
            if ((response as! NSHTTPURLResponse).allHeaderFields["Last-Modified"] != nil){ // YES! we have a modification date!
                do {
                    let offlineDate=try NSFileManager.defaultManager().attributesOfItemAtPath(storedPath)[NSFileModificationDate] as! NSDate
                    //The date that we got the file last, let's hope that we don't have any issues here
                    
                    let formatter=NSDateFormatter()
                    formatter.dateFormat = "EEE, d MMM yyyy H:mm:ss v"
                    //This is to make a date interpreter because the format is not familiar to NSDateFormatter
                    
                    let onlineDate=formatter.dateFromString((response as! NSHTTPURLResponse).allHeaderFields["Last-Modified"] as! String)
                    //The date we just recieved from the server
                    
                    if ((onlineDate?.timeIntervalSince1970)!-offlineDate.timeIntervalSince1970>60){ // file is too old
                        fetchDataUsingCache(trueURL.absoluteString, downloaded: nil, usingCache: false) // update file
                    }
                }
                catch { // Haven't had a problem with this in testing so far
                    print("[ERROR] Failed to check modification date")
                }
            }
        })
        
        task.resume() // call request above
    }

    
    
}



func fetchDataUsingCache(fileURL:String, downloaded: (() -> Void)?){
    /*
    Refer to func fetchDataUsingCache(fileURL:String, downloaded: (() -> Void)?, usingCache:Bool).
    Simply passes in usingCache:Bool as true.
    */
    fetchDataUsingCache(fileURL, downloaded: downloaded, usingCache: true)
}
func fetchDataUsingCache(fileURL:String, downloaded: (() -> Void)?, usingCache:Bool){
    /*
    
    This is the current primary method for collective updating.
    It makes a list of all things that needs done once the file is downloaded.
    It ensures the download of the file appropriately with or without using the cache system (depending on usingCache:Bool).
    Once the file has been downloaded it completes all the tasks that needed that file.
    
    */
    
    
    
    
    /*
    Completion actions
    Updates all closures that were waiting for file finish.
    Checks all branches since there is new updated content to let them know of any changes.
    */
    let retrievedAction={ (data:NSData?) in
        if (data != nil){ // make sure we have some data in the first place
            
            
            if (fileDownloadedClosures[fileURL] != nil){ // If we have closures at all
                for closure in fileDownloadedClosures[fileURL]! { // cycle through closures
                    closure() // call closure
                }
                fileDownloadedClosures[fileURL]?.removeAll() // These closures are only called once so dump them now
                fileDownloadedClosures.removeValueForKey(fileURL) // These closures are only called once so dump them now
            }
            
            
            checkBranchesFor(fileURL) // Inform branches
        }
        else {
            print("[ERROR] data is nil")
        }
    }
    
    
    
    
    
    if (fileURL != ""){ // If we actually have a file fetch
        if (logConnections){
            print("[Fetcher] \(fileURL)")
        }
        
        /*
        
        Add tasks to list to go over once file is downloaded.
        
        */
        
        if (fileDownloadedClosures[fileURL] == nil && downloaded != nil){ // If list of closures is not created yet
            fileDownloadedClosures.updateValue([], forKey: fileURL) // Create new closure list
        }
        if (downloaded != nil){
            fileDownloadedClosures[fileURL]?.append(downloaded!) // add closure to list
        }
        
        var data:NSData? = nil // data of file
        
        let trueURL=NSURL(string: fileURL)! // NSURL version of url
        let cacheDirectory=NSSearchPathForDirectoriesInDomains(.CachesDirectory , .UserDomainMask, true).first // cache directory which is the only thing we really have read and write permissions too
        let storedPath=cacheDirectory!+"/"+trueURL.path!.stringByReplacingOccurrencesOfString("/", withString: "-") // make this a writable file path
        
        
        if (usingCache){ // If we can use the cache system do so
            if (logConnections){
                print("[Fetcher] Using cache")
            }
            if ((cachedFiles[fileURL]) != nil){ // If the file is in memory just use that
                data=cachedFiles[fileURL]! // use file in memory
                retrievedAction(data) // now do any tasks that need to be done (Completion actions)
            }
            else if (offlineStorage){ // (used in control file for testing)
                let stored=NSData(contentsOfFile: storedPath) //Try using a local file
                if (stored != nil){ //Yay! we have a local file
                    cachedFiles[fileURL]=stored // Add local file to memory
                    data=stored // Assign to variable
                    
                    retrievedAction(data) // now do any tasks that need to be done (Completion actions)
                    refreshFileIfNeeded(trueURL) //Check for any updates on the file
                }
                else {
                    print("[Fetcher] Failed to recover file \(fileURL)")
                }
            }
        }
        
        
        /*
        
        This file has either never been used before or it was deleted.
        Let's try requesting the data from the web.
        
        */
        
        if (data == nil){ // make sure we still don't have the file
            
            if (logConnections){
                print("[Fetcher] Attempt request")
            }
            
            /*
            This really doesn't matter because if our cache doesn't have the file apples probably doesn't either but let's try using Apple's cache if we can.
            */
            
            var cachePolicy=NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
            if (usingCache){
                cachePolicy=NSURLRequestCachePolicy.ReloadRevalidatingCacheData
            }
            
            /*
            Make a new request for the file.
            Control file contain timeout control.
            
            */
            
            let request=NSURLRequest(URL: trueURL, cachePolicy: cachePolicy, timeoutInterval: requestTimeout)
            let task=NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data:NSData?, padawan: NSURLResponse?, error:NSError?) -> Void in
                
                if (logConnections){
                    print("[Fetcher] Successful request")
                }
                if (data != nil && simulateOffline == false){ //File successfully downloaded
                    if (offlineStorageSaving){ // Control file determines whether to save files (Mostly for testing)
                        data?.writeToFile(storedPath, atomically: true)
                    }
                    cachedFiles[fileURL]=data //Save file to memory
                    cachedBond[fileURL]=nil //let branch/unfold system have to reprocess this file for changes
                    retrievedAction(data) // now do any tasks that need to be done (Completion actions)
                    
                    return
                }
                else {
                    print("[ERROR] Failed to download resource \(fileURL) \(error)")
                }
            })
            
            task.resume() // Make above request
        }
    }
}


/*Inline data requests.*/


func unfold(instruction:String)-> AnyObject?{
    /*
    Refer to unfold(from:AnyObject?, var instructions:[AnyObject]) -> AnyObject?
    
    This simply prepares a string for use in the real unfold(...) -> AnyObject? method
    */
    
    
    let instructions=NSString(string: instruction).componentsSeparatedByString("|")
    return unfold(nil, instructions: instructions)
}
func unfold(from:AnyObject?, var instructions:[AnyObject]) -> AnyObject?{
    /*
    This method is designed to make handling multilayered dictionaries, array or other forms of content much easier.
    This method also speeds up the process by storing to memory previous processing of the same file.
    
    Refer to FOLDING it the upper documentation.
    
    testLogSteps is a control variable used for logging. Turn on to see the steps made by this method.
    
    */
    
    
    
    var source:AnyObject?=nil
    
    if (from?.isKindOfClass(NSDictionary.self) == true){ //The item to process is known already as an NSDictionary
        if (testLogSteps){
            print("from if NSDictionary")
        }
        source=(from as! NSDictionary).objectForKey(instructions[0]) // Unfold the NSDictionary
    }
    else if (from?.isKindOfClass(NSArray.self) == true){ //The item to process is known already as an NSArray
        if (testLogSteps){
            print("from if NSArray")
        }
        let stringval=instructions[0] as! String
        source=(from as! NSArray).objectAtIndex(Int((stringval as NSString).intValue)) // Unfold the NSArray
    }
    else if (from==nil){ // The item to process is empty and we need to discover what the first instruction is and use that as the item for the next unfold
        if (testLogSteps){
            print("from==nil")
        }
        let sourceURL=NSURL(string: (instructions[0]) as! String) // Attempt using the first instruction as a url
        if (cachedBond[instructions[0] as! String] != nil){ // Do we have a cache for this url?
            if (testLogSteps){
                print("cachedbond... \(instructions[0] as! String) \(cachedBond[instructions[0] as! String].dynamicType)")
                
            }
            source=cachedBond[instructions[0] as! String]! // Let's not process this file again we already did that
        }
        if (sourceURL != nil && sourceURL?.scheme != nil && sourceURL?.host != nil && (source?.isKindOfClass(NSURL.self) == true || source == nil)){
            // Alright so this instruction appears to be a url that we can request but we haven't processed it yet.
            if (testLogSteps){
                print("URL is real \(sourceURL) \(instructions[0] as! String)")
            }
            source=sourceURL
            var sourceData=cachedFiles[instructions[0] as! String] // Use the file from memory
            cachedBond[instructions[0] as! String]=source // Save this to process bond to not do this again
            
            
            if (sourceData != nil){ // Alright we have some data to process
                if (testLogSteps){
                    print("data returned as it should")
                }
                source=sourceData
                do {
                    
                    if (testLogSteps){
                        print(sourceURL)
                    }
                    
                    var sourceAttributedString = NSMutableAttributedString(string: NSString(data: sourceData!, encoding: NSUTF8StringEncoding) as! String)
                    // Convert it into the proper string to be processed.
                    
                    
                    if (removeEntitiesSystemLevel){ // Control level toggle incase this appears to keep breaking
                        TryCatch.realTry({ // The contained code can fail and swift can't catch it so we need an Objective-C try/catch implementation ontop of our swift try/catch
                            do {
                                
                                let attributedOptions=[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding]
                                
                                sourceAttributedString = try NSMutableAttributedString(data:sourceData!, options:attributedOptions as! [String : AnyObject], documentAttributes:nil) //The data we get contains strings that are not meant to be seen by the user try removing the HTML entities
                                
                                
                                //raises  NSInternalInconsistencyException
                            }
                            catch { // System level HTML entity removal failed
                                print("[ERROR] Could not remove HTML entities. \(error)")
                            }
                            
                            }, withCatch: { // System level HTML entity removal failed
                                print("[ERROR] Could not remove HTML entities.")
                        })
                    }
                    
                    
                    
                    print("[ERROR] Could not remove HTML entities.")
                    
                    
                    let sourceString=sourceAttributedString.string
                    
                    sourceData=sourceString.dataUsingEncoding(NSUTF8StringEncoding) // Return the string we made for entity removal into data to be JSON processed
                    
                    /* Just double check real quick that the class is truly available */
                    
                    
                    if (NSClassFromString("NSJSONSerialization") != nil){
                        
                        /*attempt serialization*/
                        
                        let object=try NSJSONSerialization.JSONObjectWithData(sourceData!, options: NSJSONReadingOptions.MutableContainers)
                        /*if it returned an actual NSDictionary then return it*/
                        
                        if (object.isKindOfClass(NSDictionary.self)){
                            source=object as? NSDictionary
                            cachedBond[instructions[0] as! String]=source // save this to cache so we don't do it again
                        }
                    }
                    
                }
                catch {
                    
                    /*log out any errors that might have occured*/
                    
                    print(error)
                }
            }
            
            
        }
    }
    
    /* This method failed to return an NSObject but we have to return something and hopefully not cause an error. */
    
    if (source == nil){
        return nil
    }
    
    /*Loop through this method until we are out of instructions*/
    
    instructions.removeFirst()
    if (instructions.count>0){
        return unfold(source, instructions:  instructions)
    }
    return source
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
    
    if (logConnections){
        print("[Fetcher-inline] \(fileURL)")
    }
    
    /*
    This method is used to speed up reopening the same file using caching if usingCache is true.
    
    STEP 1
    
    Check if file is already in memory cache. This will only occure if STEP 2/3 have occured successfully for the same fileURL with usingCache == true
    
    STEP 2
    
    Check if file has been stored in library directory. If so save it to active memory and return data.
    
    STEP 3
    
    Attempt online fetch of fileURL.
    
    The file is repeatedly requested up to 100 (maxAttempts) times just in cases of poor connection.
    
    If failed nil is returned
    
    */
    var data:NSData? = nil
    
    let trueURL=NSURL(string: fileURL)!
    let cacheDirectory=NSSearchPathForDirectoriesInDomains(.CachesDirectory , .UserDomainMask, true).first
    let storedPath=cacheDirectory!+"/"+trueURL.path!.stringByReplacingOccurrencesOfString("/", withString: "-")
    
    if (usingCache){
        if (logConnections){
            print("[Fetcher-inline] attempt using cache")
        }
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
    
    if ((data) != nil){
        return data
    }
    
    //STEP 3
    
    
    var attempts=0 //Amount of attempts to download the file
    let maxAttempts=100//Amount of possible attempts
    var badConnection=false
    
    while (data == nil){ //If the file is not downloaded download it
        if (attempts>maxAttempts){ //But if we have tried 100 times then give up
            print("Failed to download \(fileURL)")
            return nil //give up
        }
        else {
            do {
                
                if (logConnections){
                    print("[Fetcher-inline] attempt request")
                }
                let downloadedData=try NSData(contentsOfURL: trueURL, options: .UncachedRead) //Download
                if (simulateOffline == false){ //File successfully downloaded
                    if (offlineStorageSaving){
                        print("[dataUsingCache] write to file... \(storedPath)")
                        //downloadedData.writeToFile(storedPath, atomically: true) //Save file locally for use later
                        data?.writeToFile(storedPath, atomically: true) //Save file locally for use later
                    }
                    cachedFiles[fileURL]=downloadedData //Save file to memory
                    cachedBond[fileURL]=nil
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
    
    
    Read comments in:
    func dataUsingCache(fileURL:String) -> NSData
    For more details
    
    
    WARNING
    
    This method is failable depending on what data is passed in.
    
    */
    
    
    
    do {
        var sourceData=dataUsingCache(path, usingCache: usingCache)
        if (sourceData == nil){
            return nil
        }
        
        var sourceAttributedString = NSMutableAttributedString(string: NSString(data: sourceData!, encoding: NSUTF8StringEncoding) as! String)
        TryCatch.realTry({
            if (removeEntitiesSystemLevel){
                do {
                    
                    let attributedOptions=[NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding]
                    //sourceAttributedString=try NSMutableAttributedString(data:sourceData!, options:attributedOptions as! [String : AnyObject] ,documentAttributes:nil)
                    //print("attributes passed")
                    sourceAttributedString = try NSMutableAttributedString(data:sourceData!, options:attributedOptions as! [String : AnyObject], documentAttributes:nil)
                    
                    //raises  NSInternalInconsistencyException
                }
                catch {
                    print("[ERROR] Could not remove HTML entities. \(error)")
                }
            }
            
            }, withCatch: {
                print("[ERROR] Could not remove HTML entities.")
        })
        
        
        let sourceString=sourceAttributedString.string.stringByReplacingOccurrencesOfString("&amp;", withString: "&")
        
        sourceData=sourceString.dataUsingEncoding(NSUTF8StringEncoding)
        
        /* Just double check real quick that the class is truly available */
        
        
        if (NSClassFromString("NSJSONSerialization") != nil){
            
            /*attempt serialization*/
            
            let object=try NSJSONSerialization.JSONObjectWithData(sourceData!, options: NSJSONReadingOptions.MutableContainers)
            
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


