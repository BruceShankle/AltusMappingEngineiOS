//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef enum {
	kPackageTypeUnknown=0,
    kPackageTypeRaster=1,
    kPackageTypeTerrain=4,
    kPackageTypeVector=6
} MEPackageType;

/**Utility class for accessing Altus map packages.*/
@interface MEPackage : NSObject

/**Initialize a package for reading.
 @param fileName Name of Altus map package sqlie file.
 */
-(id) initWithFileName:(NSString*) fileName;

/**Filename of the package.*/
@property (readonly, retain) NSString* fileName;

/**Package type.*/
@property (readonly) MEPackageType packageType;

/**West-most boundary of map data.*/
@property (readonly) double minX;

/**Southern-most boundary of map data.*/
@property (readonly) double minY;

/**East-most boundary of map data.*/
@property (readonly) double maxX;

/**Northern-most boundary of map data.*/
@property (readonly) double maxY;

/**The minimimum spherical mercator tile level in the map data.*/
@property (readonly) unsigned int minLevel;

/**The maximum spherical mercator tile level in the map data.*/
@property (readonly) unsigned int maxLevel;

/**Return a tile from the package.
 @param tileId The unique 64-bit tile identifier for the tile.*/
-(NSData*) getTileUsingId:(uint64_t) tileId;

-(NSArray*) getParents:(uint64_t) tileId;

-(CGRect) getBoundsUsingId:(uint64_t) tileId;

@end
