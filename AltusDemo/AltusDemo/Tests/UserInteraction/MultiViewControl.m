//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "MultiViewControl.h"
#import "ViewManager.h"

@implementation MultiViewControl

- (id) init {
	if(self=[super init]){
		self.name = @"Mult-View Control";
	}
	return self;
}

-(BOOL) isEnabled{
    if(!self.meMapViewController.isInitialized){
        return NO;
    }
    if([ViewManager getViewCount]<2){
        return NO;
    }
    if([ViewManager getControllingView]==nil){
        return YES;
    }
    if(self.meMapViewController.meMapView==[ViewManager getControllingView]){
        return YES;
    }
    return NO;
}

-(void) beginTest{
    [ViewManager setControllingView:self.meMapViewController.meMapView];
}

-(void) endTest{
    if(self.meMapViewController.meMapView == [ViewManager getControllingView]){
        [ViewManager setControllingView:nil];
    }
}

@end
