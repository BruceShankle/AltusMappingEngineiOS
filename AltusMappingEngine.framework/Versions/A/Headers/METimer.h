//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>

@interface METimer : NSObject
+(long) getMillis;
-(id) initWithMessage:(NSString*) message;
-(void) start;
-(long) stop;
-(void) reset;
-(long) getElapsed;
@end
