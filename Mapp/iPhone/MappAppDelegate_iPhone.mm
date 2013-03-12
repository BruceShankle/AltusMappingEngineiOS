//
//  MappAppDelegate_iPhone.m
//  Mapp
//
//  Created by Edwin B Shankle III on 10/3/11.
//  Copyright 2011 BA3, LLC. All rights reserved.
//

#import "MappAppDelegate_iPhone.h"

@implementation MappAppDelegate_iPhone
@synthesize mapViewController;


- (void) awakeFromNib
{
	self.mapViewController=[[MapViewController_iPhone alloc] init];
	[super awakeFromNib];
}

@end
