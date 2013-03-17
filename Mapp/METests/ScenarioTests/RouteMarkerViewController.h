//
//  RouteMarkerViewController.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/31/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteMarkerViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextField* routeLabel;
-(void) updateRouteLabelText:(NSString*) newLabelText;
@end
