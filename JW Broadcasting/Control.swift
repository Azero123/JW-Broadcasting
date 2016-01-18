//
//  Control.swift
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/23/15.
//  Copyright © 2015 xquared. All rights reserved.
//

import Foundation

/*Settings for overall control*/

let preloading = false //unimplemented
let aggressivePreload = false
let simulateOffline=false
let simulatedPoorConnection=false //fails 1/2 of all connections
let offlineStorage=true
let offlineStorageSaving=true

let requestTimeout=NSTimeInterval(20)

var testLogSteps=false

let removeEntitiesSystemLevel = true //Incase other critical bugs arrise from this.

let JWLogo = true
var hidesJWLogoWhenCovered=false

let useLibraryDirectoryInSimulator=true


/*Logging*/
let logConnections = false
let logFolding = testLogSteps

/*Disable View Controllers*/

let defaultViewController=NewAudioController.self //unimplemented

let Home = true

let BETAMedia = true
let VOD = false

let Audio = false
let NewAudio = true

let Language = true

let Search = true


/*Settings for home page control*/

let HomeFeatured = true
let HomeFeaturedSlide=false
let HomeChannels = true //unimplemented
let HomeLastestVideos = true //unimplemented

/*Settings for language page control*/

let ReturnToHome = true //This has cause a lot of issues and is still being resolved.

/*Settings for Streaming*/

let StreamingLowestQuality=false
var StreamingAdvancedMode=false //This is for testing and shows details about the video currently playing such as url duration current time etc
var StreamingHTTPStitching=false //Not started
let timeToShow=10


/*
var Home = {
    var enabled=true
}
*/

func titleExtractor(var oldTitle:String) -> Dictionary< String,String >{
    
    var extraction:Dictionary<String,String>=[:]
    
    var visualNumber:Int?=nil
    
    
    
    let replacementStrings=["JW Broadcasting —","JW Broadcasting—"]
    
    for replacement in replacementStrings {
        
        if (oldTitle.containsString(replacement)){
            
            oldTitle=oldTitle.stringByReplacingOccurrencesOfString(replacement, withString: "")
            oldTitle=oldTitle.stringByAppendingString(" Broadcast")
            /* replace " Broadcast" with a key from:
            base+"/"+version+"/languages/"+languageCode+"/web"
            so that this works with foreign languages*/
        }
        
    }
    
    if ((oldTitle.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))>3){
        visualNumber=Int(oldTitle.substringToIndex(oldTitle.startIndex.advancedBy(3)))
    }
    if (visualNumber != nil) {
        extraction["visualNumber"]="\(visualNumber!)"
    }
    
    var correctedTitle=titleCorrection(oldTitle)
    if (correctedTitle != "") {
        extraction["correctedTitle"]="\(correctedTitle)"
    }
    else {
        correctedTitle=oldTitle
        extraction["correctedTitle"]=oldTitle
    }
    
    if (languageCode == "E"){
        correctedTitle=correctedTitle.stringByReplacingOccurrencesOfString("Vocal", withString: "Vocal Renditions")
        correctedTitle=correctedTitle.stringByReplacingOccurrencesOfString("Piano", withString: "Piano Accompaniment")
    }
    if (correctedTitle.containsString("(") && correctedTitle.containsString(")")){
        let startIndex=correctedTitle.rangeOfString("(")?.startIndex
        let endIndex=correctedTitle.rangeOfString(")")?.startIndex
        
        let rangeOfParentheses=Range<String.Index>(
            start: startIndex!.advancedBy(-1),
            end: endIndex!.advancedBy(1)
        )
        
        
        extraction["parentheses"]=correctedTitle.substringWithRange(rangeOfParentheses).stringByReplacingOccurrencesOfString("(", withString: "").stringByReplacingOccurrencesOfString(")", withString: "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        correctedTitle.removeRange(rangeOfParentheses)
        extraction["correctedTitle"]="\(correctedTitle)"
        
    }
    if (correctedTitle.containsString("-") || correctedTitle.containsString("—")){
        let subTitle=correctedTitle.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "-—")).last!
        extraction["subTitle"]=subTitle.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        extraction["correctedTitle"]=correctedTitle.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "-—")).first!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    //print(oldTitle)
    
    
    
    return extraction
}

func titleCorrection(var oldTitle:String) -> String{
    let characters=oldTitle.characters.map{String($0)}
    if (characters.count<7){
        return oldTitle
    }
    
    if ((characters[3] == "-" || characters[3] == "—") && characters[5] == " " && characterIsNumber(characters[0])&&characterIsNumber(characters[1])&&characterIsNumber(characters[2])){
        oldTitle.removeRange(  Range<String.Index>(start: oldTitle.startIndex, end: oldTitle.startIndex.advancedBy(6))  )
    }
    return oldTitle
}

func characterIsNumber(string:String) -> Bool{
    if ((string == "0" || string == "1" || string == "2" || string == "3" || string == "4" || string == "5" || string == "6" || string == "7" || string == "8" || string == "9" || string == "0")){
        return true
    }
    return false
}

func categoryTitleCorrection(var oldTitle:String) -> String{
    
    if (languageCode == "E"){
        /*if (oldTitle.containsString("Vocal") && oldTitle.containsString("Vocal Renditions") == false ){
        
        }*/
        
        oldTitle=oldTitle.stringByReplacingOccurrencesOfString("Vocal", withString: "Vocal Renditions")
        oldTitle=oldTitle.stringByReplacingOccurrencesOfString("Piano", withString: "Piano Accompaniment")
    }
    
    return oldTitle
}

