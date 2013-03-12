//
//  MappAppDelegate_iPad.mm
//  Mapp
//
//  Created by Edwin B Shankle III on 10/3/11.
//  Copyright 2011 BA3, LLC. All rights reserved.
//

#import "MappAppDelegate_iPad.h"
#import "MapViewController_iPad.h"

@implementation MappAppDelegate_iPad
@synthesize mapViewController;

- (void) awakeFromNib
{
	self.mapViewController=[[MapViewController_iPad alloc] init];
    [super awakeFromNib];
}


@end
