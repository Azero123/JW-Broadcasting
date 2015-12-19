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

let useLibraryDirectoryInSimulator=true


/*Logging*/
let logConnections = false
let logFolding = testLogSteps

/*Disable View Controllers*/

let Home = true

let BETAMedia = true

let VOD = false

let Audio = false
let NewAudio = true

let Language = true

let Search = false


/*Settings for home page control*/

let HomeFeatured = true
let HomeFeaturedSlide=true
let HomeChannels = true //unimplemented
let HomeLastestVideos = true //unimplemented

/*Settings for language page control*/

let ReturnToHome = true //This has cause a lot of issues and is still being resolved.

/*Settings for Streaming*/

let StreamingLowestQuality=false
var StreamingAdvancedMode=false //This is for testing and shows details about the video currently playing such as url duration current time etc
var StreamingHTTPStitching=false //Not started

