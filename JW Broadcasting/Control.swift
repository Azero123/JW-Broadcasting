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

let VOD = true

let Audio = true

let Language = true

let Search = false

let BETAMedia = false


/*Settings for home page control*/

let HomeFeatured = true
let HomeFeaturedSlide=true
let HomeChannels = true //unimplemented
let HomeLastestVideos = true //unimplemented

/*Settings for language page control*/

let ReturnToHome = true //This has cause a lot of issues and is still being resolved.





