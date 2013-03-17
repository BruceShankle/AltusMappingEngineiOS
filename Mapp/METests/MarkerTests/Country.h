//
//  Country.h
//  Mapp
//
//  Created by Bruce Shankle III on 9/14/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Country : NSObject
@property (retain) NSString* name;
@property (assign) float longitude;
@property (assign) float latitude;
@property (assign) unsigned int population;

-(void) parseData:(NSString*) data;

@end
