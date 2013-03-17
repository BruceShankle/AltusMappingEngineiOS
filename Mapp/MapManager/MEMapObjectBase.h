//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>

@interface MEMapObjectBase : NSObject

@property (retain) NSString* Name;
@property (retain) NSString* Path;
@property (retain) NSString* Category;
@property (retain) NSString* MapFileName;
@property (retain) NSString* MapIndexFileName;

@property bool Enabled;
@property bool NoDisable;

-(id) initWithName:(NSString*) name andPath:(NSString*) path;

-(id) initWithName:(NSString*) name andCategory:(NSString*) category andPath:(NSString*) path;

//Map paths and name handling
+(NSString*) GetMapsPath;
+(NSString*) GetCategoryPath:(NSString*) category;
+(NSString*) GetMapPath:(NSString*) category map:(NSString*) map;
+(NSString*) mapPathForCategory:(NSString*) category mapName:(NSString*) map;
+(NSString*) mapFileNameForCategory:(NSString*) category map:(NSString*) map;
+(NSString*) mapIndexFileNameForCategory:(NSString*) category map:(NSString*) map;
+(void) createMapCategory:(NSString*) category;
+(void) createDirectory:(NSString*) path;

@end
