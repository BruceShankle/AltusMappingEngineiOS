//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "../Utilities/TileWorker.h"
#import "TileDownloader.h"

/**A tile worker that downloads tiles from a WMS server on the internet.*/
@interface WMSTileDownloader: TileDownloader
@property (retain) NSString* wmsURL;
@property (retain) NSString* wmsVersion;
@property (retain) NSString* wmsLayers;
@property (retain) NSString* wmsSRS;
@property (retain) NSString* wmsCRS;
@property (retain) NSString* wmsFormat;
@property (assign) BOOL useWMSStyle;
@property (assign) NSString* wmsStyleString;
@property (assign) BOOL convertTo3857;
@end
