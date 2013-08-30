//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#pragma once
#import <CoreLocation/CoreLocation.h>

static const double US_NORTHMOST = 49.0 + 23.0/60.0 + 4.1/3600.0;	//Lake Woods, Minnesoa
static const double US_SOUTHMOST = 24.0 + 31.0/60.0 + 15.0/3600.0;	//Ballast Key, Florida
static const double US_EASTMOST = -66.0 - 56.0 / 60.0 - 59.2/3600.0;	//West Quoddy Head, Maine
static const double US_WESTMOST = -124.0 - 46.0 / 60.0 - 18.1/3600.0;//Cape Alava, Washington

//Some test locations
static const CLLocationCoordinate2D JFK_COORD = {40.64365972925757, -73.78208504094064};
static const CLLocationCoordinate2D SFO_COORD = {37.61931125933241, -122.3736948394537};
static const CLLocationCoordinate2D HOU_COORD = {29.6465098129107, -95.27900971583961};
static const CLLocationCoordinate2D MIA_COORD = {25.79475488150219, -80.27914615027547};
static const CLLocationCoordinate2D RDU_COORD = {35.882872, -78.790864};
static const CLLocationCoordinate2D MT_RANIER = {46.8533, -121.7604};
static const CLLocationCoordinate2D US_MIN = {US_SOUTHMOST, US_WESTMOST};
static const CLLocationCoordinate2D US_MAX = {US_NORTHMOST, US_EASTMOST};


