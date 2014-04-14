//
//  AirplaneViewController.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/22/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ME/ME.h>
@interface AirplaneViewController : UIViewController <MESymbiote>
@property (assign) MELocationCoordinate2D centerCoordinate;
@property (nonatomic, retain) IBOutlet UILabel* lblMessage;
@end
