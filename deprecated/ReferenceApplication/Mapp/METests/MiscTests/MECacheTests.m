//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "MECacheTests.h"

@implementation MESmallCacheTest

- (id) init {
	if(self=[super init])
	{
		self.name=@"Small Cache Test";
		self.smallCacheSize = 1000 * 1000;
	}
	return self;
}

- (NSString*) label {
	return [NSString stringWithFormat:@"%ld MB", self.smallCacheSize/1000];
}

- (void) start {
	if(self.isRunning)
		return;
	self.oldCacheSize = self.meMapViewController.coreCacheSize;
	
	[self.meMapViewController shutdown];
	self.meMapViewController.coreCacheSize = self.smallCacheSize;
	[self.meMapViewController initialize];
	
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"grayGrid"]
									withName:@"grayGrid"
							 compressTexture:YES];
	
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"noData"]
									withName:@"noData"
							 compressTexture:YES];
	
	
	
	self.isRunning = YES;
}

- (void) stop {
	if(!self.isRunning)
		return;
	
	[self.meMapViewController shutdown];
	self.meMapViewController.coreCacheSize = self.oldCacheSize;
	
	[self.meMapViewController initialize];
	
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"grayGrid"]
									withName:@"grayGrid"
							 compressTexture:YES];
	
	[self.meMapViewController addCachedImage:[UIImage imageNamed:@"noData"]
									withName:@"noData"
							 compressTexture:YES];
	
	
}

@end

///////////////////////////////////////////////////////////////////
@implementation MECacheImageOnBackgroundThreadTest

- (id) init {
	if(self=[super init]){
		self.name=@"Cache Image on Background Thread";
	}
	return self;
}

- (void) start {
	if(self.isRunning)
		return;
	self.isRunning = YES;
	self.interval = 1;
	[self startTimer];
}

- (void) timerTick {
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		NSLog(@"Cacheing image on DISPATCH_QUEUE_PRIORITY_HIGH...");
		for(int i=0; i<100; i++){
			[self.meMapViewController addCachedImage:[UIImage imageNamed:@"redarrow"]
											withName:@"foo"
									 compressTexture:NO];
		}
		NSLog(@"Finished cacheing image on DISPATCH_QUEUE_PRIORITY_HIGH...");
	});
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		NSLog(@"Cacheing image on DISPATCH_QUEUE_PRIORITY_LOW...");
		for(int i=0; i<100; i++){
			[self.meMapViewController addCachedImage:[UIImage imageNamed:@"redarrow"]
											withName:@"foo"
									 compressTexture:NO];
		}
		NSLog(@"Finished cacheing image on DISPATCH_QUEUE_PRIORITY_LOW...");
	});
}

- (void) stop {
	if(!self.isRunning)
		return;
	[self stopTimer];
	self.isRunning = NO;
}

@end
