//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#pragma once

typedef struct {
	double longitude;
	double latitude;
} MELocationCoordinate2D;

typedef struct {
	MELocationCoordinate2D center;
	double altitude;
} MELocation;

typedef struct {
	MELocationCoordinate2D min;
	MELocationCoordinate2D max;
} MELocationBounds;



