//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <ME/ME.h>

@interface MEWMSTileProvider : METileProvider

@property (retain) NSString* wmsURL;
@property (retain) NSString* shortName;
@property (retain) NSString* tileCacheRoot;
@property (retain) NSString* tileFileExtension;
@property (retain) NSString* wmsVersion;
@property (retain) NSString* wmsLayers;
@property (retain) NSString* wmsSRS;
@property (retain) NSString* wmsFormat;
@property (assign) BOOL useWMSStyle;
@property (assign) NSString* wmsStyleString;

//Functions
- (NSString*) cacheFileNameForRequest:(METileProviderRequest*) meTileProviderRequest;
- (NSString*) tileURLForRequest:(METileProviderRequest*) meTileProviderRequest;
- (BOOL) downloadTileFromURL:(NSString*) url toFileName:(NSString*) fileName;

@end
