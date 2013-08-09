//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../METest.h"

@interface TowersWithHeightColorBarTest : METest <MEDynamicMarkerMapDelegate>
@property (retain) IBOutlet UILabel* lblAltitude;
@property (retain) IBOutlet UISlider* slider;
- (IBAction) sliderValueChanged:(UISlider *)sender;
@property (assign) int currentIndex;
@property (assign) int towerCount;

@end
