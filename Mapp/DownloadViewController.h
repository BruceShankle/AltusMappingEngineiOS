//
//  DownloadViewController.h
//  Mapp
//
//  Created by Edwin B Shankle III on 11/3/11.
//  Copyright (c) 2011 BA3, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ME/ME.h>

#import "Protocols.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"



@interface DownloadViewController : UIViewController <UITableViewDataSource>
{
	id<ModalViewPresenter> presenter;
}


@property (retain) IBOutlet UIBarButtonItem* btnDone;
@property (nonatomic, assign) id<ModalViewPresenter> presenter;
@property (retain) IBOutlet UILabel* lblStatus;
@property (retain) IBOutlet UILabel* lblMapsToDownload;
@property (retain) IBOutlet UITableView* tblViewMapList;
@property (retain) ASIHTTPRequest* httpRequest;
@property (retain) ASINetworkQueue* asiNetworkQueue;
@property (retain) NSMutableDictionary* mapCategories;
@property (retain) IBOutlet UIButton* btnDownload;
@property (retain) IBOutlet UIButton* btnCancel;
@property (retain) IBOutlet UIProgressView* progressDownload;
@property BOOL downloadRequestsDidFail;
@property BOOL downloadInProgress;
@property BOOL selectAll;
@property BOOL downloadCancelled;
@property BOOL mustRestart;
@property (retain) IBOutlet UIButton* btnSelectAll;
@property (retain) NSMutableArray* downloadedMapsNames;
@property (nonatomic, retain) MEMapViewController* meViewController1;
@property (nonatomic, retain) MEMapViewController* meViewController2;

- (IBAction) didClickDone:(id)sender;

- (void) downloadAsyncFromURL:(NSString*) url toFilename:(NSString*) filename withBlock: (void (^)())block;
- (void) downloadCategories;
- (void) parseMapJSON:(NSString *)fileName; 
- (NSMutableDictionary*) getMapWithCategoryIndex:(int)categoryIndex andMapIndex:(int) mapIndex;
- (void) updateMapsToDownloadLabel;
- (void) requestDidFinish:(ASIHTTPRequest*)request;
- (void) requestDidFail:(ASIHTTPRequest*) request;
- (void) queueDidFinish:(ASINetworkQueue*) queue;
- (void) receivedRequestHeaders:(ASIHTTPRequest*)request headers:(NSDictionary*) headers;
+ (NSArray *) allZipFilesInPath:(NSString *)directoryPath;

- (IBAction) didClickDownload:(id)sender;
- (IBAction) didClickCancel:(id)sender;
- (IBAction) didClickSelectAll:(id) sender;
- (IBAction) touchUpOnSelectAll:(id) sender;

- (void) setHighlight:(UIButton*)b;

@end
