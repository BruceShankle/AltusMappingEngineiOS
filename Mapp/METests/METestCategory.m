//
//  METestCategory.m
//  Mapp
//
//  Created by Bruce Shankle III on 8/16/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "METestCategory.h"

@implementation METestCategory
@synthesize meTestManager;
@synthesize name;
@synthesize meTests;
@synthesize meMapViewController;
@synthesize lastTestStarted;
@synthesize containsDynamicTestArray;

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Some Test Category";
        self.meTests = [[[NSMutableArray alloc]init]autorelease];
		self.containsDynamicTestArray = NO;
    }
    return self;
}

- (void) dealloc
{
	self.lastTestStarted = nil;
    self.meTestManager = nil;
    self.name = nil;
    self.meTests = nil;
    self.meMapViewController = nil;
    [super dealloc];
}

- (void) stopAllTests
{
	for(METest* test in meTests)
	{
		if(test.isRunning)
			[test stop];
	}
}

- (void) updateTestArray
{
	
}

- (void) addTest:(METest*) newTest
{
    newTest.meMapViewController = self.meMapViewController;
    newTest.meTestManager = self.meTestManager;
	newTest.meTestCategory = self;
    [self.meTests addObject:newTest];
}

- (void) addTestClass:(Class) testClass
{
	METest* newTest = [[[testClass alloc]init]autorelease];
	[self addTest:newTest];
}

- (METest*) testFromIndex:(int)testIndex
{
	NSMutableArray* testArray = self.meTests;
	
    return (METest*) [testArray objectAtIndex:testIndex];
}

- (METest*) testWithName:(NSString *)testName
{
	for(METest* meTest in self.meTests)
	{
		if([meTest.name isEqualToString:testName])
			return meTest;
	}
	return nil;
}

- (void) startTestWithName:(NSString*) testName
{
	METest* test = [self testWithName:testName];
	if(test)
	{
		[test start];
	}
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    // Proxy all unimplemented method calls to currently running tests
    
    bool invocationProcessed = NO;
    
    for(METest* test in self.meTests)
    {
        if( test.isRunning )
        {
            if ([test respondsToSelector:[anInvocation selector]])
            {
                [anInvocation invokeWithTarget:test];
                invocationProcessed = YES;
            }
        }
    }
    
    if( !invocationProcessed )
    {
        [super forwardInvocation:anInvocation];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    for(METest* test in self.meTests)
    {
        if( test.isRunning )
        {
            if( [test respondsToSelector:aSelector] )
            {
                return YES;
            }
        }
    }
    
    return [super respondsToSelector:aSelector];
}

@end
