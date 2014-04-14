//
//  ClippingPlaneTest.h
//  Mapp
//
//  Created by Bruce Shankle III on 10/12/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "../MEtest.h"

@interface ClippingPlaneTest : METest
@property (nonatomic, retain) IBOutlet UISlider* slider;
- (IBAction) sliderValueChanged:(UISlider *)sender;
@end
