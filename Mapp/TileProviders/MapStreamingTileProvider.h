//
//  MapStreamingTileProvider.h
//  Mapp
//
//  Created by Edwin B Shankle III on 7/4/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ME/ME.h>
#import "ASIHTTPRequest.h"

@interface MapStreamingTileProvider : METileProvider <ASIHTTPRequestDelegate>

@property (nonatomic, retain) NSString* mapDomain;

@end
