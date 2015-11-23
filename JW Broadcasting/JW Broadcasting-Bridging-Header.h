//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Foundation/Foundation.h>
#import "TryCatch.h"


void reallyTry(void(^try)(),void(^catch)()){
    @try {
        try ? try() : nil;
    }
    @catch (NSException *exception) {
        catch ? catch(exception) : nil;
    }
    @finally {
        //finally ? finally() : nil;
    }
}