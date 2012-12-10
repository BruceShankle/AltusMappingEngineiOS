//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "MEProtocols.h"
#import "METileInfo.h"

//////////////////////////////////////////////////
//Forward declarations
@class MEMapViewController;
@class METileProvider;

//////////////////////////////////////////////////
/**Enumeration of different map types.*/
typedef enum {
	kMapTypeUnknown,
    kMapTypeFileTerrain,
	kMapTypeFileTerrainTAWS,
	kMapTypeFileRaster,
	kMapTypeFileRasterPVR,
	kMapTypeFileRasterPVR_RAW,
    kMapTypeVirtualRaster,
	kMapTypeVirtualRasterAnimated,
	kMapTypeFileVector,
	kMapTypeDynamicVector,
    kMapTypeFileMarker,
	kMapTypeFileMarkerCreate,
	kMapTypeMemoryMarker,
	kMapTypeDynamicMarker,
	kMapTypeFileMBTiles
} MEMapType;

//////////////////////////////////////////////////
/**Enumeration of different map content types.*/
typedef enum {
	kZoomDependent,
	kZoomIndependent
} MEMapContentType;

//////////////////////////////////////////////////
/**Enumeration of different map loading strategies.*/
typedef enum {
	kLowestDetailFirst,
	kHighestDetailOnly
} MEMapLoadingStrategy;


/////////////////////////////////////////////////////////////
/**Enumeration of different marker map loading strategies.*/
typedef enum {
	kMarkerImageLoadingAsynchronous,
	kMarkerImageLoadingSynchronous
} MEMarkerImageLoadingStrategy;



//////////////////////////////////////////////////
/**Describes a map layer and options for it. Used when adding a map or inquiring about map.*/
@interface MEMapInfo : NSObject

/**Map type.*/
@property (assign) MEMapType mapType;

/**Map loading strategy type.*/
@property (assign) MEMapLoadingStrategy mapLoadingStrategy;

/**Unique name of map.*/
@property (retain) NSString* name;

/**Physical path of index sqlite file for the map.*/
@property (retain) NSString* sqliteFileName;

/**Table name prefix in cases where sqlite file contains data for multiple maps.*/
@property (retain) NSString* tableNamePrefix;

/**Physical path of data file for the map.*/
@property (retain) NSString* dataFileName;

/**The view controller that is managing this map.*/
@property (retain) MEMapViewController* meMapViewController;

/**They layer order of this map, higher means higher in the stack.*/
@property (assign) unsigned int zOrder;

/**Maximum detail level of the map. (Specified for in-memory marker maps and virtual maps).*/
@property (assign) unsigned int maxLevel;

/**0 to 1 value for the map alpha. 0 is invisible, 1 is opaque.*/
@property (assign) double alpha;

/**Whether or not the map is vibile.*/
@property (assign) BOOL isVisible;

/**Whether or not to compress textures for this map to 2 byte formats.*/
@property (assign) BOOL compressTextures;

/**The minimum longitude for this map.*/
@property (assign) double minX;

/**The minimum latitude for this map.*/
@property (assign) double minY;

/**The maximum longitude for this map.*/
@property (assign) double maxX;

/**The maximum latitude for this map.*/
@property (assign) double maxY;

/**Specifies number of pixels that border each tile.*/
@property (assign) unsigned int borderPixelCount;

/**Specifies the name of the pre-loaded default tile to render while tiles are being loaded or to use when a tile is not available. */
@property (retain) NSString* defaultTileName;

@end

//////////////////////////////////////////////////
/**Describes an MBTiles map.*/
@interface MEMBTilesMapInfo : MEMapInfo

/**The type of image tiles in the map.*/
@property (assign) MEImageDataType imageDataType;

@end

//////////////////////////////////////////////////
/**Describes a marker map.*/
@interface MEMarkerMapInfo : MEMapInfo

/**For marker maps, the marker map delegate that will provide marker images.*/
@property (retain) id<MEMarkerMapDelegate> meMarkerMapDelegate;

/**For marker maps, the array of markers to add.*/
@property (retain) NSArray* markers;

/**Cluster distance to use for markers.*/
@property (assign) CGFloat clusterDistance;

/**Controls how the engine requests marker images. Defaults to kAsynchronousMarkerImageLoading. Note: frame hitching can occur if you use kMarkerImageLoadingAsynchronous for a large set of markers. Use asynchronous loading when possible.*/
@property (assign) MEMarkerImageLoadingStrategy markerImageLoadingStrategy;

/**Controls whether the engine performs touch-point hit testing against the markers. Defaults to YES.*/
@property (assign) BOOL hitTestingEnabled;

@end

/**Describes a vector map.*/
@interface MEVectorMapInfo : MEMapInfo

/**Optional delegate that will receive touch events on dynamic vector geometry objects.*/
@property (retain) id<MEVectorMapDelegate> meVectorMapDelegate;

@end

//////////////////////////////////////////////////
/**Describes a virtual map.*/
@interface MEVirtualMapInfo : MEMapInfo

/**Tile provider that will serve up tiles for this virtual map.*/
@property (retain) METileProvider* meTileProvider;

/**Specifies map content type.*/
@property (assign) MEMapContentType contentType;

/**Specifies map loading strategy.*/
@property (assign) MEMapLoadingStrategy loadingStrategy;

/**Specifies that the tile source is spherical mercator (Google / Slippy style) tiles.*/
@property (assign) BOOL isSlippyMap;

@end

//////////////////////////////////////////////////
/**Describes an animated virtual map.*/
@interface MEAnimatedVirtualMapInfo : MEVirtualMapInfo

/**Specifies number of frames.*/
@property (assign) unsigned int frameCount;

/**Specifies number of frames to play per second.*/
@property (assign) CGFloat frameRate;

/**Specifies the number of seconds to wait before repeating the animation.*/
@property (assign) CGFloat repeatDelay;

/**Specifies whether to apply an inter-frame fade.*/
@property (assign) BOOL fadeEnabled;

@end







