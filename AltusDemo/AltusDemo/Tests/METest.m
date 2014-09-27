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

- (void) startBenchmarkTimer{
    if(self.benchMarkTimer==nil){
        NSString* timerMessage=[NSString stringWithFormat:@"%@ benchmark:", self.name];
        self.benchMarkTimer = [[METimer alloc]initWithMessage:timerMessage];
    }
    [self.benchMarkTimer start];
}

-(long) stopBenchMarkTimer{
    if(self.benchMarkTimer==nil){
        return 0;
    }
    return [self.benchMarkTimer stop];
}

- (void) tickInternal{
    NSDate *currentTime = [NSDate date];
    self.elapsedTime = [currentTime timeIntervalSinceDate:self.lastTickTime];
    self.lastTickTime = currentTime;
    [self timerTick];
}

- (void) startTimer{
    self.lastTickTime = [NSDate date];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:self.interval
                                                  target:self
                                                selector:@selector(tickInternal)
                                                userInfo:nil
                                                 repeats:YES];
	NSRunLoop *runloop = [NSRunLoop currentRunLoop];
	[runloop addTimer:self.timer forMode:NSRunLoopCommonModes];
	[runloop addTimer:self.timer forMode:UITrackingRunLoopMode];
}

-(void) addUI{
    if(self.lblMessage!=nil){
        return;
    }
    float maxWidth = self.meMapViewController.meMapView.bounds.size.width;
    self.lblMessage = [[UILabel alloc]initWithFrame:CGRectMake(0,20,maxWidth,100)];
    self.lblMessage.numberOfLines=0;
    self.lblMessage.alpha=0.7;
    [self.lblMessage setTextColor:[UIColor greenColor]];
    [self.lblMessage setBackgroundColor:[UIColor blackColor]];
    //[self.lblMessage.layer setCornerRadius:10];
    [self.lblMessage setFont:[UIFont fontWithName: @"Arial-BoldMT" size: 15.0f]];
    [self.meMapViewController.meMapView addSubview:self.lblMessage];
    [self.meMapViewController.meMapView bringSubviewToFront:self.lblMessage];
}

-(void) createView {
    // create a local view to add stuff to.  that way no test has to handle removing UI
    self.view = [[METestView alloc] initWithFrame:self.meMapViewController.meMapView.bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.meMapViewController.meMapView addSubview:self.view];
}

-(void) removeUI{
    if(self.view != nil) {
        [self.view removeFromSuperview];
        self.view = nil;
    }
    if(self.lblMessage!=nil){
        [self.lblMessage removeFromSuperview];
        self.lblMessage = nil;
    }
}

-(void) setMessageText:(NSString *)msgText{
    if(self.lblMessage==nil){
        [self addUI];
    }
    self.lblMessage.text = msgText;
    [self.lblMessage sizeToFit];
}

- (void) beginTest{
#ifdef DEBUG
    NSLog(@"beginTest not implemented.");
#endif
}

- (void) endTest{
#ifdef DEBUG
    NSLog(@"endTest not implemented.");
#endif
}

- (void) start{
	if(self.isRunning){
		return;
    }
    [self beginTest];
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
    [self hideAlert];
    [self endTest];
    [self removeUI];
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

- (void) stopAllOtherTests{
    self.isRunning = NO;
    [self.meTestManager stopAllTests];
    self.isRunning = YES;
}

- (void) stopTestsInThisCategory{
    self.isRunning = NO;
    [self.meTestManager stopAllTests];
    self.isRunning = YES;
}

-(void) hideAlert{
    if(self.alertView!=nil){
        [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
        self.alertView=nil;
    }
}

- (void)alertTimeOut:(NSTimer *)timer {
    [self hideAlert];
}

- (void)showAlert:(NSString *)message
          timeout:(double)timeout {
    
    [self hideAlert];
    
    NSString* alertMessage = [NSString stringWithFormat:@"%@\n%@", self.name, message];
    
    self.alertView = [[UIAlertView alloc] initWithTitle:nil
                                                message:alertMessage
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
    [self.alertView show];
    if(timeout>0){
        [NSTimer scheduledTimerWithTimeInterval:timeout
                                         target:self
                                       selector:@selector(alertTimeOut:)
                                       userInfo:nil
                                        repeats:NO];
    }
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

+(float)randomFloat:(float)min
                max:(float)max{
    return (float)[METest randomDouble:min max:max];
}


+ (CLLocationCoordinate2D) randomLocation{
    return CLLocationCoordinate2DMake([METest randomDouble:-90 max:90],
                                      [METest randomDouble:-180 max:180]);
}

+ (float) randomHeading{
    return (float)[METest randomDouble:0 max:360];
}

@end
