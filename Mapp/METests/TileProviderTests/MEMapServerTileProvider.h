//
//  MEMapServerTileProvider.h
//  Mapp
//
//  Created by Bruce Shankle III on 8/21/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ME/ME.h>
@interface MEMapServerTileProvider : METileProvider
@property (nonatomic, retain) NSString* mapDomain;
@property (assign) BOOL returnUIImages;
@property (assign) BOOL returnNSData;
@end
