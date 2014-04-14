//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "METestCategory.h"

@implementation METestCategory

- (id) init{
    if(self = [super init]){
        self.name=@"Some Test Category";
        self.meTests = [[NSMutableArray alloc]init];
    }
    return self;
}


- (void) stopAllTests{
	for(METest* test in self.meTests)
	{
		if(test.isRunning){
			[test stop];
        }
	}
}

- (void) addTest:(METest*) newTest{
    newTest.meMapViewController = self.meMapViewController;
    newTest.meTestManager = self.meTestManager;
	newTest.meTestCategory = self;
    [self.meTests addObject:newTest];
}

- (void) addTestClass:(Class) testClass{
	METest* newTest = [[testClass alloc]init];
	[self addTest:newTest];
}

- (METest*) testWithName:(NSString *)testName{
	for(METest* meTest in self.meTests){
		if([meTest.name isEqualToString:testName]){
			return meTest;
        }
	}
	//Error
    NSLog(@"Test %@ not found. Exiting.", testName);
    exit(0);
}

- (void) startTestWithName:(NSString*) testName{
	METest* test = [self testWithName:testName];
    if(test==nil){
        NSLog(@"Test %@ not found. Exiting.", testName);
        exit(0);
    }
    [test start];
}

@end
