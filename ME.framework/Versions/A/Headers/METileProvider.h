//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#pragma once
#import "METileInfo.h"

#import <UIKit/UIKit.h>

@class MEMapViewController;

/**
 Provides tiles to the mapping engine at run time on an as-needed basis.
 */
@interface METileProvider : NSObject

/**The MEMapViewControllerl that owns this METileProvider.*/
@property (retain) MEMapViewController* meMapViewController;

/**If set to yes, the Engine will call your requestTileAsync function and expect you to call tileLoadComplete.*/
@property (assign) BOOL isAsynchronous;

/**Returns YES if the tile is still needed by a non-animated virtual map being displayed by the mapping engine. Warning: This call is marshalled to the main thread. Use isNeededAnimated for animated maps. */
- (BOOL) isNeeded:(METileProviderRequest*) meTileRequest;

/**Returns YES if the tile is still needed by an animated virtual map being displayed by the mapping engine. Warning: This call makes synchronizes access to the MEMapViewController.*/
- (BOOL) isNeededAnimated:(METileProviderRequest*) meTileRequest;

/**
 Called by the engine to request a tile from a synchronous tile provider. 
 
 For non-spherical mecator maps, the callee should do one of the following to the meTileRequest object:
 a) Get an image from somewhere and either:
	1) set uiImage to a valid UIImage object
	2) set nsImageData to data that is compressed PNG or JPG image data, set imageDataType appropriately
	3) set pImageData to point to memory that is compressed PNG or JPG data, set imageDataSize, set imageDataType
	4) set fileName to a valid PNG or JPG file
 
 -or-
 
 b) Set isNotAvailable = YES
 
 For spherical mercator maps, the callee should:
 a) Iterate over the array of MESphericalMercatorTiles, there may be one or more. For each one:
	1) Get an image from somehwere
	2) set uiImage to a valid UIImage object
	3) set nsImageData to data that is compressed PNG or JPG image data, set imageDataType appropriately
	4) set pImageData to point to memory that is compressed PNG or JPG data, set imageDataSize, set imageDataType
	5) set fileName to a valid PNG or JPG file
 
 -or-
 
 b) set isNotAvailable = YES on the meTileRequest Object
 
 The engine thread that makes this call will block until this function returns.
 
 */
- (void) requestTile:(METileProviderRequest*) meTileRequest;

/**Called by the engine to request an array of tiles from a synchronous tile provider for an animated virtual layer. The callee should do one of the following to each METileRequest objects in the meTileRequests array:
 a)set uiImage to a valid UIImage object
 b)set nsImageData to data that is compressed PNG or JPG image data, set imageDataType appropriately
 b)set pImageData to point to memory that is compressed PNG or JPG data, set imageDataSize, set imageDataType
 c)set fileName to a valid PNG or JPG file
 d)set isNotAvailable = YES
 The engine thread that makes this call will block until this function returns.
 */
- (void) requestTiles:(NSArray*) meTileRequests;

/**Called by the engine to request a tile from an asynchronous tile provider. The callee should do one of the following to the meTileRequest object:
 a)set uiImage to a valid UIImage object
 b)set nsImageData to data that is compressed PNG or JPG image data, set imageDataType appropriately
 b)set pImageData to point to memory that is compressed PNG or JPG data, set imageDataSize, set imageDataType
 c)set fileName to a valid PNG or JPG file
 d)set isNotAvailable = YES
 
 The engine thread that makes this call will not block waiting on this function.
 
 The callee should call tileLoadComplete passing the meTileRequest back to the engine when the tile is loaded.
 */
- (void) requestTileAsync:(METileProviderRequest*) meTileRequest;

/**Called by the engine to request an array of tiles from an asynchronous tile provider for an animated virtual layer. The callee should do one of the following to each meTileRequest object in the meTileRequests array:
 a)set uiImage to a valid UIImage object
 b)set nsImageData to data that is compressed PNG or JPG image data, set imageDataType appropriately
 b)set pImageData to point to memory that is compressed PNG or JPG data, set imageDataSize, set imageDataType
 c)set fileName to a valid PNG or JPG file
 d)set isNotAvailable = YES
 The engine thread that makes this call will block until this function returns.
 */
- (void) requestTilesAsync:(NSArray*) meTileRequests;

/**This is provided as a convenience method and simply calls the MEMapViewController's tileLoadComplete function.*/
- (void) tileLoadComplete:(METileProviderRequest*) meTileRequest;

/** Convenience method for managing an array of URL request objects.*/
- (void) addActiveRequest:(id)request withId:(id)requestId;

/** Convenience method for managing an array of URL request objects.*/
- (void) removeActiveRequestWithId:(id)requestId;

/** Convenience method for managing an array of URL request objects.*/
- (id) getActiveRequestWithId:(id)requestId;

/** Convenience object for managing an array of URL request objects.*/
- (NSArray*) getAllActiveRequests;

@end

/**This tile provider is designed to be used to serve up a default base map consisting of the same, repeated tile for every tile request.*/
@interface MEBaseMapTileProvider : METileProvider

/**The name of the cached image this tile provider will always provide.*/
@property (retain) NSString* cachedImageName;

/**Initalizes the tile provider with the name of a cached image.*/
-(id) initWithCachedImageName:(NSString*) cachedImageName;

@end
