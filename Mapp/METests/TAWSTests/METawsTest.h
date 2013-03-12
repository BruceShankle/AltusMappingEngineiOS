//
//  METawsEnableTest.h
//  Mapp
//
//  Created by Nik Donets on 8/23/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "METest.h"

@interface METawsTest : METest
@property (assign) MEMapLoadingStrategy mapLoadingStrategy;
- (void) addMaps;
- (void) removeMaps;

@property (retain) IBOutlet UISlider* slider;
- (IBAction) sliderValueChanged:(UISlider *)sender;

@property (retain) IBOutlet UILabel* lblAltitude;

@end

@interface METawsHighestDetailOnlyTest : METawsTest
@end

@interface METawsColorBarTest : METest
@end
