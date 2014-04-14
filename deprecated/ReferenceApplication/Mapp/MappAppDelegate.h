//
//  MappAppDelegate.h
//  Mapp
//
//  Created by Edwin B Shankle III on 10/3/11.
//  Copyright 2011 BA3, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface MappAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (retain) MapViewController* mapViewController;

@end
