//
//  MapSelectorViewController_iPhone.h
//  Mapp
//
//  Created by Edwin B Shankle III on 11/2/11.
//  Copyright (c) 2011 BA3, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ME/ME.h>
#import "../Protocols.h"
#import "../MapSelectorTableViewController.h"
#import "../METests/METestManager.h"
#import "../MapManager/MapManager.h"

@interface MapSelectorViewController_iPhone : UIViewController{
	id<ModalViewPresenter> presenter;
}

@property (retain) MEMapViewController* meViewController;
@property (retain) METestManager* meTestManager;
@property (retain) MapManager* mapManager;
@property (retain) IBOutlet UIBarButtonItem* btnDone;
@property (nonatomic, assign) id<ModalViewPresenter> presenter;
@property (retain) IBOutlet MapSelectorTableViewController* mapSelectorTableViewController;
@property (retain) IBOutlet UITableView* tblMapList;

- (IBAction) didClickDone:(id)sender;

@end
