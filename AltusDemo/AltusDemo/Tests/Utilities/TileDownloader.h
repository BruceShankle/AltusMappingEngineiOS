//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#pragma once
#import <Foundation/Foundation.h>
#import "TileWorker.h"

/**A tile worker that downloads tiles from the internet.*/
@interface TileDownloader : TileWorker
/** Initialize instance.
 @param urlTemplate Template for downloads. For example:
 If you have multiple subdomains you would use a url string like this:
 http://{s}.tiles.mapbox.com/v3/mymap/{z}/{x}/{y}.jpg
 {s} is not required, but if you do use it, make sure the subDomains parameter
 contains a comma delimited list of subdomains, i.e.: a,b,c,d
 @param subDomains Comma separate list of subdomains
 @param enableAlpha Set to NO for base maps tha cover the planet. Set to yes for maps that have sparse coverage, i.e. wather.*/
-(id) initWithURLTemplate:(NSString*) urlTemplate
               subDomains:(NSString*) subDomains
              enableAlpha:(BOOL) enableAlpha
                 useCache:(BOOL) useCache;
@property (retain) NSString* urlTemplate;
@property (retain) NSArray* subDomains;
@property (assign) BOOL useCache;
@property (assign) int currentSubdomain;
@property (assign) bool enableAlpha;
@property (assign) int timeOutInterval;
@end
