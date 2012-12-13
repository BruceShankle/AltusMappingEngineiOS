//
//  MEInternetTileProvider.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/17/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ME/ME.h>
@interface MEInternetTileProvider : METileProvider
@property (nonatomic, retain) NSString* mapDomain;
@property (nonatomic, retain) NSString* shortName;
@property (nonatomic, retain) NSString* tileCacheRoot;
@property (assign) BOOL returnUIImages;
@property (nonatomic, retain) NSString* copyrightNotice;
- (NSString*) tileURLForX:(int) X Y:(int) Y Zoom:(int) Zoom;
- (NSString*) cacheFileNameForX:(int) X Y:(int) Y Zoom:(int) Zoom;
- (NSString*) tileFileExtension;
- (BOOL) downloadTileFromURL:(NSString*) url toFileName:(NSString*) fileName;
@end

@interface MEMapBoxTileProvider : MEInternetTileProvider
@end

@interface MEAsyncInternetTileProvider : MEMapBoxTileProvider
@end

@interface MEMapBoxMarsTileProvider : MEMapBoxTileProvider
@end

@interface MEMapBoxLandCoverTileProvider : MEMapBoxTileProvider
@end

@interface MEOpenStreetMapsTileProvider : MEMapBoxTileProvider
@end

@interface MEMapQuestTileProvider : MEMapBoxTileProvider
@end

@interface MEMapQuestAerialTileProvider : MEMapBoxTileProvider
@end

@interface MEStamenTerrainTileProvider : MEMapBoxTileProvider
@end

@interface MEArgyleTileProvider : MEMapBoxTileProvider
@end

@interface MEMapBoxLandSatTileProvider : MEMapBoxTileProvider
@end






