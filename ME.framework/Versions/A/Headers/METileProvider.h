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

/**Called by the engine to request a tile from a synchronous tile provider. The callee should do one of the following to the tileInfo object:
 a)set uiImage to a valid UIImage object
 b)set nsImageData to data that is compressed PNG or JPG image data, set imageDataType appropriately
 b)set pImageData to point to memory that is compressed PNG or JPG data, set imageDataSize, set imageDataType
 c)set fileName to a valid PNG or JPG file
 d)set isNotAvailable = YES
 The engine thread that makes this call will block until this function returns.
 */
- (void) requestTile:(METileInfo*) tileInfo;

/**Called by the engine to request an array of tiles from a synchronous tile provider for an animated virtual layer. The callee should do one of the following to each tileInfo object in the tileInfos array:
 a)set uiImage to a valid UIImage object
 b)set nsImageData to data that is compressed PNG or JPG image data, set imageDataType appropriately
 b)set pImageData to point to memory that is compressed PNG or JPG data, set imageDataSize, set imageDataType
 c)set fileName to a valid PNG or JPG file
 d)set isNotAvailable = YES
 The engine thread that makes this call will block until this function returns.
 */
- (void) requestTiles:(NSArray*) tileInfos;

/**Called by the engine to request a tile from an asynchronous tile provider. The callee should do one of the following to the tileInfo object:
 a)set uiImage to a valid UIImage object
 b)set nsImageData to data that is compressed PNG or JPG image data, set imageDataType appropriately
 b)set pImageData to point to memory that is compressed PNG or JPG data, set imageDataSize, set imageDataType
 c)set fileName to a valid PNG or JPG file
 d)set isNotAvailable = YES
 
 The engine thread that makes this call will not block waiting on this function.
 
 The callee should call tileLoadComplete passing the tileInfo back to the engine when the tile is loaded.
 */
- (void) requestTileAsync:(METileInfo*) tileInfo;

/**Called by the engine to request an array of tiles from an asynchronous tile provider for an animated virtual layer. The callee should do one of the following to each tileInfo object in the tileInfos array:
 a)set uiImage to a valid UIImage object
 b)set nsImageData to data that is compressed PNG or JPG image data, set imageDataType appropriately
 b)set pImageData to point to memory that is compressed PNG or JPG data, set imageDataSize, set imageDataType
 c)set fileName to a valid PNG or JPG file
 d)set isNotAvailable = YES
 The engine thread that makes this call will block until this function returns.
 */
- (void) requestTilesAsync:(NSArray*) tileInfos;

/**
 In the case of asynchronous tile providers, this function is called by the engine when a tile that has not completed loading is no longer needed. For example, the user has panned away from the relevant area.
 */
- (void) cancelTileRequest:(METileInfo*) tileInfo;

/**This is provided as a convenience method and simply calls the MEMapViewController's tileLoadComplete function.*/
- (void) tileLoadComplete:(METileInfo*) tileInfo;


/** Convenience method for managing an array of URL request objects.*/
- (void) addActiveRequest:(id)request withId:(id)requestId;

/** Convenience method for managing an array of URL request objects.*/
- (void) removeActiveRequestWithId:(id)requestId;

/** Convenience method for managing an array of URL request objects.*/
- (id) getActiveRequestWithId:(id)requestId;

/** Convenience object for managing an array of URL request objects.*/
- (NSArray*) getAllActiveRequests;


@end