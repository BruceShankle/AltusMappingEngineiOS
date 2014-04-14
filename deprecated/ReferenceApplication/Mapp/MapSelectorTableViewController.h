//
//  MapLayerListViewController.h
//  Mapp
//
//  Created by Edwin B Shankle III on 10/4/11.
//  Copyright 2011 BA3, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ME/ME.h>
#import "RemoteMapCatalog.h"
#import "METests/METestManager.h"
#import "MapManager/MapManager.h"

@class MapViewController;
@interface MapSelectorTableViewController : UITableViewController <UITableViewDataSource>  {
	
}

@property (retain) MEMapViewController* meViewController;
@property (retain) RemoteMapCatalog* remoteMapCatalog;
@property (retain) MapViewController* mapViewController;
@property (retain) METestManager* meTestManager;
@property (retain) MapManager* mapManager;

@end
