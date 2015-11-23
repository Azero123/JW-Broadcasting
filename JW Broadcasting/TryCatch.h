//
//  TryCatch.h
//  JW Broadcasting
//
//  Created by Austin Zelenka on 11/22/15.
//  Copyright © 2015 xquared. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TryCatch : NSObject

//+(void)try:void (^)())try catch:void (^)(NSException *))catch finally:void (^)())finally;

+(void)realTry:(void (^)())try withCatch:(void (^)())catch;


@end
