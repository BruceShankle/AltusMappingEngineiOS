//
//  MBTilesTileProvider.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/22/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../../Libraries/fmdb/FMDatabase.h"

#import <ME/ME.h>
@interface MBTilesTileProvider : METileProvider

-(id) initWithDatabaseName:(NSString*) databaseName;
@property (retain) NSString* databaseName;
@property (retain) FMDatabase* database;
@end
