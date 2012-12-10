//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import "METileProvider.h"
/**
 A tile provider which serves up tiles from a MB tiles-style map.
 */
@interface MEMBTileProvider : METileProvider
/**
 Initialize with full path to a sqlite database file.
 @param databaseFile Full path to the database file.
 @param tileImageType either kImageDataTypePNG or kImageDataTypeJPG
 */
-(id) initWithDatabaseFile:(NSString*) databaseFile
			 tileImageType:(MEImageDataType) tileImageType;
@end
