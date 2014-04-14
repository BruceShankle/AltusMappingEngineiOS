//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <Foundation/Foundation.h>
#import <ME/ME.h>

@interface GeoBoundingBox : NSObject
@property (assign) CLLocationCoordinate2D lowerLeft;
@property (assign) CLLocationCoordinate2D upperRight;
@end

@interface BoundingBoxReader : NSObject
+(NSMutableArray*) loadDataFromFile:(NSString*) filePath;
@end
