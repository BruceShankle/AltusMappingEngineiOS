//
//  MappAppDelegate.mm
//  Mapp
//
//  Created by Edwin B Shankle III on 10/3/11.
//  Copyright 2011 BA3, LLC. All rights reserved.
//

#import "MappAppDelegate.h"
#import <ME/ME.h>

@implementation MappAppDelegate

@synthesize window = _window;
@synthesize mapViewController;

- (void) awakeFromNib
{
	[self.window addSubview:self.mapViewController.view];
    [self.window setRootViewController:self.mapViewController];
	CGRect r=CGRectMake(self.window.bounds.origin.x, 20, self.window.bounds.size.width, self.window.bounds.size.height);
	[self.mapViewController.view setFrame:r];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef TESTFLIGHT
	[TestFlight takeOff:@"a4501ff7b75c56b5bf4a02cd248ddb84_Mzg4MDkyMDExLTExLTA0IDA1OjU2OjEzLjMwODQ4Ng"];
	[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    [MEMapView forceLink];
    [MEMapViewController forceLink];
    
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[self.mapViewController applicationDidReceiveMemoryWarning:application];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	[self.mapViewController applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
	[self.mapViewController applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
	[self.mapViewController applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	[self.mapViewController applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
	[self.mapViewController applicationWillTerminate:application];
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

@end
