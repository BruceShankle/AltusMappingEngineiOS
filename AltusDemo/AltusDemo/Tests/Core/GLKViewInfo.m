//
//  GLKViewInfo.m
//  AltusDemo
//
//  Created by Bruce Shankle on 9/21/14.
//  Copyright (c) 2014 BA3, LLC. All rights reserved.
//

#import "GLKViewInfo.h"

@implementation GLKViewInfo

- (id) init {
	if(self=[super init]){
        self.name=@"GLKView Info";
        self.interval = 0.1;
	}
	return self;
}

-(void) timerTick{
    float contentScaleFactor = self.meMapViewController.meMapView.contentScaleFactor;
    int renderTargetWidth = self.meMapViewController.meMapView.drawableWidth;
    int renderTargetHeight = self.meMapViewController.meMapView.drawableHeight;
    NSString* message = [NSString stringWithFormat:@"contentScaleFactor = %f\ndrawableWidth=%d\ndrawableHeight=%d",
                         contentScaleFactor,
                         renderTargetWidth,
                         renderTargetHeight];
    [self setMessageText:message];
}

-(void) beginTest{
    [self startTimer];
}

-(void) endTest{
    [self stopTimer];
}
@end
