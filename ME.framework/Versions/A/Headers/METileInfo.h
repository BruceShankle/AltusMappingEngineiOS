//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**Enumeration of data types for tile images used in the METileInfo object*/
typedef enum {
    kImageDataTypeUnknown,
    kImageDataTypePNG,
    kImageDataTypeJPG
} MEImageDataType;

typedef enum {
	kTileResponseUnknown,
	kTileResponseTransparentWithChildren,
	kTileResponseTransparentWithoutChildren,
	kTileResponseNotAvailable,
	kTileResponseRenderUIImage,
	kTileResponseRenderNSData,
	kTileResponseRenderFilename,
	kTileResponseRenderImageData,
	kTileResponseRenderNamedCachedImage,
	kTileResponseWasCancelled
} METileProviderResponse;

/**
 This object is when communicating with METileProvider derived objects that manage getting tiles for virtual map layers. When a virtual layer is added, these objects will be pass to the requestTile function on the delegate in the case of syncrhonous tile providers where the tile provider will populate the uiImage, nsImageData, fileName, or pImageData members to return an image to the engine. In the case of nsImageData or pImageData, the data should point to compressed imaged data and the imageDataType should also be set so the engine can interpret the data correctly. In the case of pImageData, pImageDataLength should also be set.*/
@interface METileInfo : NSObject

/**Tile providers set this value based on how the mapping engine should interpret the tile METileInfo it gets back form the tile provider.
 Valid responses are:

 */
@property (assign) METileProviderResponse tileProviderResponse;

/**The internal 64-bit ID of the tile.*/
@property (assign, readonly) uint64_t uid;

/**The internal map ID of the map that contains this tile.*/
@property (assign) size_t mapid;

/**The slippyX id of the tile.*/
@property (assign, readonly) unsigned int slippyX;

/**The slippy Y id of the tile.*/
@property (assign, readonly) unsigned int slippyY;

/**The slippy Z id of the tile.*/
@property (assign, readonly) unsigned int slippyZ;

/**Expected width of the tile image.*/
@property (assign, readonly) unsigned int width;

/**Expected height of the tile image.*/
@property (assign, readonly) unsigned int height;

/**In the case of animated layers, the frame number*/
@property (assign, readonly) unsigned int frame;

/**In the case of setting pImageData, the lenght in bytes of the data.*/
@property (assign) unsigned int pImageDataLength;

/**If set, a pointer to a UIImage object to use as image data.*/
@property (retain) UIImage* uiImage;

/**If set, a pointer to an NSData object whose bytes represent compressed JPG or PNG image data. If set, you should also set the imageDataType appropriately.*/
@property (retain) NSData* nsImageData;

/**If set, a pointer to memory whose bytes represent compressed JPG or PNG image data. If set, you should also set the imageDataType appropriately.*/
@property (assign) void* pImageData;

/**If set, a pointer to a jpg or png file which the engine will load and decompress. The engine has native support decompressing png and jpg images very quickly.*/
@property (retain) NSString* fileName;

/** If set, specifies the name of a cached image to use. You may cache images by using MEMapViewController addCachedImage.*/
@property (retain) NSString* cachedImageName;

/** If setting nsImageData or pImageData, you should set this to the appropriate image data type.*/
@property (assign) MEImageDataType imageDataType;

/**If set, tells the mapping engine that every pixel of the tile is lit and has no semi-transparenty pixels. This allows the engine to optimize storage and layering of the tile (i.e. no tile underneath this tile will be visible if it is opaque.*/
@property (assign) BOOL isOpaque;

/**If set to YES, this tile can be ejected and re-requested by calling refreshDirtyTiles on the MEMapViewController object.*/
@property (assign) BOOL isDirty;

/** If set to YES, tells the mapping engine to only render the tile if it cannot sample from a parent tile that was previously requested. This response can be used, for example, if you have an intermittent internet connection and cannot download the requested tile, but do not with to show the user a placeholder tile if a parent tile can be sampled from.
 */
@property (assign) BOOL isProxy;

/**The minium geographic longitude of the tile. This is mainly of use with BA3 map tiles where this data is relevant.*/
@property (assign) double minX;

/**The minium geographic latitude of the tile. This is mainly of use with BA3 map tiles where this data is relevant.*/
@property (assign) double minY;

/**The maximum geographic longitude of the tile. This is mainly of use with BA3 map tiles where this data is relevant.*/
@property (assign) double maxX;

/**The maximum geographic latitude of the tile. This is mainly of use with BA3 map tiles where this data is relevant.*/
@property (assign) double maxY;


/**Initializer for METileInfo*/
- (id) initWithUID:(uint64_t) uid
		   slippyX:(int) slippyX
		   slippyY:(int) slippyY
		   slippyZ:(int) slippyZ
			 width:(int) width
			height:(int) height
			 frame:(int) frame;

/**Used by the engine to write a pointer to internal engine data structures.*/
- (void) setPrivateData:(void*) pData;

/**Used by the engine to read internal engine data structures.*/
- (void*) getPrivateData;

@end

/**Represents the data the mapping engine returns when low-level inquiries are made about tiles being displayed or currently being requested.*/
@interface METileRequest : NSObject

/**The internal 64-bit ID of the tile.*/
@property (assign) uint64_t uid;

/**The internal map ID of the map that contains this tile.*/
@property (assign) size_t mapid;

/**The animate frame number of the tile.*/
@property (assign) unsigned int frame;

@end
