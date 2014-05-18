//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "METest.h"
#import "METestManager.h"
#import "METestCategory.h"

@implementation METest

- (id) init{
    if(self = [super init]){
        self.name=@"Some Test";
        self.label = @"";
        self.interval = 1;
        self.isRunning = NO;
        self.repeats = YES;
		self.bestFontSize = 18.0f;
        self.isEnabled = YES;
    }
    return self;
}

- (void) userTapped{
    if(!self.isRunning){
        [self start];
    }
    else{
        [self stop];
	}
}



- (void) startTimer{
	self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval
                                                  target:self
                                                selector:@selector(timerTick)
                                                userInfo:nil
                                                 repeats:YES];
	NSRunLoop *runloop = [NSRunLoop currentRunLoop];
	[runloop addTimer:self.timer forMode:NSRunLoopCommonModes];
	[runloop addTimer:self.timer forMode:UITrackingRunLoopMode];
}

- (void) start{
	if(self.isRunning){
		return;
    }
    self.isRunning = YES;
}

- (void) stopTimer{
	if(self.timer!=nil){
        [self.timer invalidate];
		self.timer = nil;
    }
}

- (void) stop{
	if(!self.isRunning){
		return;
    }
    [self stopTimer];
    self.isRunning = NO;
}

- (void) timerTick{
    NSLog(@"METest timer ticked.");
}

- (NSString*) uiLabel{
    if(self.label.length==0){
        return self.name;
    }
    else{
        return [NSString stringWithFormat:@"%@ (%@)", self.name, self.label];
    }
}


-(void) lookAtUnitedStates{
    [self.meMapViewController.meMapView lookAtCoordinate:CLLocationCoordinate2DMake(37.246798, -126.554263)
                                           andCoordinate:CLLocationCoordinate2DMake(34.648367, -72.814862)
                                    withHorizontalBuffer:0
                                      withVerticalBuffer:0
                                       animationDuration:1.0];
}

-(void) lookAtSanFrancisco{
    [self.meMapViewController.meMapView lookAtCoordinate:CLLocationCoordinate2DMake(37.75, -122.6)
                                           andCoordinate:CLLocationCoordinate2DMake(37.75, -122.3)
                                    withHorizontalBuffer:0
                                      withVerticalBuffer:0
                                       animationDuration:1.0];
}

+ (NSString*) getDocumentsPath{
    NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                 NSUserDomainMask,
                                                                 YES);
    NSString* documentPath = [documentPaths objectAtIndex:0];
    return documentPath;
}

+ (NSString*) getCachePath{
    NSArray*  cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                               NSUserDomainMask,
                                                               YES);
    NSString* cachePath = [cachePaths objectAtIndex:0];
    return cachePath;
}

+(double)randomDouble:(double)min
				  max:(double)max{
    
    double drange = (double)arc4random()/((double)4294967296);
	return min + drange*(max-min);
}



@end
