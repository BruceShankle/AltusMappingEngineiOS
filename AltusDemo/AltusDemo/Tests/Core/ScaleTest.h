//
//  ScaleTest.h
//  AltusDemo
//
//  Created by Bruce Shankle on 9/23/14.
//  Copyright (c) 2014 BA3, LLC. All rights reserved.
//
#pragma once
#import "../METest.h"

@interface ScaleTest : METest <MEMarkerMapDelegate, MEDynamicMarkerMapDelegate, MEMapViewDelegate, MEVectorMapDelegate>
@property (nonatomic, retain) UISwitch* markerAutoScaleSwitch;
@property (nonatomic, retain) UISlider* scaleSlider;
@property (retain) UILabel* lblStats;
@property (retain) UILabel* lblScaleSlider;
@property (retain) UISegmentedControl* imageType;
@property (retain) UISegmentedControl* tileSize;
@property (assign) int markerId;
@property (assign) NSString* rasterMapName;
@property (assign) NSString* dynamicMarkerMapName;
@property (assign) NSString* clusteredMarkerMapName;
@property (assign) NSString* vectorMapName;
@property (assign) NSString* vectorCircleName;
@property (assign) NSString* mapUrlTemplate;
@property (assign) CGPoint blueCircleAnchor;
@end
