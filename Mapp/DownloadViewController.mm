//
//  DownloadViewController.m
//  Mapp
//
//  Created by Edwin B Shankle III on 11/3/11.
//  Copyright (c) 2011 BA3, LLC. All rights reserved.
//

#import "DownloadViewController.h"
#import "Libraries/ZipArchive/ZipArchive.h"
#import "MapManager/MEMapCategory.h"
#import "MapManager/MEMapObjectBase.h"

//NStrings used in download system
#define MAPDOWNLOADURL @"http://mapserver.ba3.us/Drop24Maps/maps.json"

#import "JSONKit.h"

@implementation DownloadViewController
@synthesize btnDone;
@synthesize presenter;
@synthesize lblStatus;
@synthesize httpRequest;
@synthesize asiNetworkQueue;
@synthesize mapCategories;
@synthesize tblViewMapList;
@synthesize lblMapsToDownload;
@synthesize btnDownload;
@synthesize btnCancel;
@synthesize progressDownload;
@synthesize downloadRequestsDidFail;
@synthesize downloadInProgress;
@synthesize btnSelectAll;
@synthesize selectAll;
@synthesize downloadedMapsNames;
@synthesize downloadCancelled;
@synthesize meViewController1;
@synthesize meViewController2;
@synthesize mustRestart;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mapCategories=[[NSMutableDictionary alloc]init];
		downloadInProgress=NO;
		downloadRequestsDidFail=NO;
		[self.btnCancel setAlpha:0.5];
		[self.btnCancel setEnabled:NO];
		self.mustRestart=NO;
    }
    return self;
}

- (void) dealloc
{
    self.httpRequest = nil;
	self.mapCategories = nil;
	if(self.asiNetworkQueue!=nil)
	{
		[self.asiNetworkQueue cancelAllOperations];
        self.asiNetworkQueue = nil;
	}
    self.downloadedMapsNames = nil;
	self.meViewController1 = nil;
	self.meViewController2 = nil;
	[super dealloc];
}

- (IBAction) didClickDone:(id)sender
{
	if(self.mustRestart)
		exit(0);
	[presenter dismissModalViewController:@"DownloadViewController"];
}

- (void) downloadAsyncFromURL:(NSString*) url toFilename:(NSString*) filename withBlock: (void (^)())block
{
    NSURL *nsurl = [NSURL URLWithString:url];
	[self.httpRequest release];
	self.httpRequest = [ASIHTTPRequest requestWithURL:nsurl];
	[self.httpRequest setTimeOutSeconds:10];
    [self.httpRequest setDownloadDestinationPath:filename];
    [self.httpRequest setCompletionBlock:block];
	[self.httpRequest setShouldContinueWhenAppEntersBackground:YES];
    [self.httpRequest setFailedBlock:^{
        NSError *error = [self.httpRequest error];
        [self.lblStatus setText:error.localizedDescription];
		[self.btnDone setEnabled:YES];
    }];
    [self.httpRequest startAsynchronous];
}


- (void) downloadCategories
{
	__block NSString* destFile=[[DirectoryInfo sharedDirectoryInfo] GetCacheFilePath:@"maps.json"];
	[self.btnDone setEnabled:NO];
	NSString* url=MAPDOWNLOADURL;
	__block DownloadViewController *blocksafeSelf = self;
	[self downloadAsyncFromURL:url toFilename:destFile withBlock:^{
		[blocksafeSelf parseMapJSON:destFile];
	}];
}

- (void)parseMapJSON:(NSString *)fileName; 
{
	if ([[self httpRequest] responseStatusCode] != 200) 
	{
		[self.lblStatus setText:@"Error contacting map server."];
		[self.btnDone setEnabled:YES];
		return;
	}
	NSError* error;
	NSString* fileString=[NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:&error];
	
    if ( nil == fileString )
	{
		[self.lblStatus setText:@"Error parsing map information."];
		[self.btnDone setEnabled:YES];
		return;
	}

	NSArray *mapsFromJSON = [fileString objectFromJSONString];
	for (NSDictionary *mapDict in mapsFromJSON) 
	{
		NSString *categoryName = [mapDict objectForKey:@"category"];
		NSMutableArray *maps = [[self mapCategories] objectForKey:categoryName];
		if (maps == nil) 
		{
			maps = [[NSMutableArray alloc] init];
			[self.mapCategories setObject:maps forKey:categoryName];
		}
		[maps addObject:[NSMutableDictionary dictionaryWithDictionary:mapDict]];
	}
	
	[self.tblViewMapList reloadData];
	[self.lblStatus setText:@"Select maps. Tap Download."];
	[self.btnDone setEnabled:YES];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.mapCategories count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSEnumerator *enumerator = [self.mapCategories keyEnumerator];
	id key;
	int index=0;
	while ((key = [enumerator nextObject])) {
		if(index==section)
		{
			return (NSString*)key;
		}
		index++;
	}
	return @"";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSEnumerator *enumerator = [self.mapCategories objectEnumerator];
	id key;
	int index=0;
	while ((key = [enumerator nextObject])) {
		if(index==section)
		{
			NSMutableArray* maps=(NSMutableArray*)key;
			return maps.count;
		}
		index++;
	}
	return 0;
}

- (NSMutableDictionary*) getMapWithCategoryIndex:(int)categoryIndex andMapIndex:(int) mapIndex
{
	//Find the category and get the map array
	NSMutableArray* maps;
	NSEnumerator *enumerator = [self.mapCategories objectEnumerator];
	id key;
	int index=0;
	while ((key = [enumerator nextObject])) {
		if(index==categoryIndex)
		{
			maps=(NSMutableArray*)key;
			break;
		}
		index++;
	}
	
	if(maps==nil)
	{
		return nil;
	}
	
	return (NSMutableDictionary*) [maps objectAtIndex:mapIndex];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell;
	cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"]autorelease];
    
	NSMutableDictionary* map=[self getMapWithCategoryIndex:indexPath.section andMapIndex:indexPath.row];
	if(map!=nil)
	{
		NSString *mapname;
		mapname=[map objectForKey:@"mapname"];
		if(mapname==nil)
			mapname=[map objectForKey:@"zipname"];
			
		[[cell textLabel] setText:mapname];
	}
	
	//If enabled, add a check
	if(((NSNumber*)[map objectForKey:@"download"]).boolValue)
	{
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.downloadInProgress) return;
	if(self.selectAll)
	{
		self.selectAll=NO;
		[self.btnSelectAll setHighlighted:NO];
	}
	
	NSMutableDictionary* map=[self getMapWithCategoryIndex:indexPath.section andMapIndex:indexPath.row];
	if(map==nil)
		return;
	
	NSNumber* download=(NSNumber*)[map objectForKey:@"download"];
	NSNumber* toggledownload=[NSNumber numberWithBool:!download.boolValue];
	[map setObject:toggledownload forKey:@"download"];
	
	UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
	if(toggledownload.boolValue)
	{
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
	}
	else
	{
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
	
	//Update download label
	
	[self updateMapsToDownloadLabel];

}


- (void) setHighlight:(UIButton*)b
{
    [b setHighlighted:YES];
}


- (IBAction) didClickSelectAll:(id)sender
{
	self.selectAll=!self.selectAll;
	NSNumber* nsnDownload=[NSNumber numberWithBool:self.selectAll];
	
	NSEnumerator *enumerator = [self.mapCategories keyEnumerator];
	id key;
	NSString* categoryName;
	while ((key = [enumerator nextObject])) {
		categoryName=(NSString*) key;
		NSMutableArray* maps=[self.mapCategories objectForKey:categoryName];
		NSEnumerator * enumerator = [maps objectEnumerator];
		id mapelement;
		while(mapelement = [enumerator nextObject])
		{
			NSMutableDictionary* map=(NSMutableDictionary*)mapelement;
			[map setObject:nsnDownload forKey:@"download"];
		}
	}
	
	//Reload table view (set checks on things)
	[self.tblViewMapList reloadData];
	
	//Update label
	[self updateMapsToDownloadLabel];
	
	
}

- (IBAction) touchUpOnSelectAll:(id) sender
{
	if(self.selectAll)
		[self performSelector:@selector(setHighlight:) withObject:sender afterDelay:0];
}

- (IBAction) didClickCancel:(id)sender
{
	self.downloadCancelled=YES;
	[self.asiNetworkQueue cancelAllOperations];	
}

- (IBAction) didClickDownload:(id)sender
{
	
	[self.btnDone setEnabled:NO];
	[self.btnDownload setEnabled:NO];
	[self.btnDownload setAlpha:0.5];
	[self.btnCancel setEnabled:YES];
	[self.btnCancel setAlpha:1.0];
	[self.btnSelectAll setEnabled:NO];
	[self.btnSelectAll setAlpha:0.5];
	self.downloadInProgress=YES;
	self.downloadCancelled=NO;
	self.downloadRequestsDidFail=NO;
	
	
	if(self.asiNetworkQueue==nil)
	{
		self.asiNetworkQueue=[[ASINetworkQueue alloc]init];
		[self.asiNetworkQueue setShowAccurateProgress:YES];
		[self.asiNetworkQueue setDelegate:self];
		[self.progressDownload setProgress:0];
		[self.asiNetworkQueue setDownloadProgressDelegate:self.progressDownload];
		[self.asiNetworkQueue setQueueDidFinishSelector:@selector(queueDidFinish:)];
		[self.asiNetworkQueue setRequestDidReceiveResponseHeadersSelector:@selector(receivedRequestHeaders:headers:)];
		[self.asiNetworkQueue setRequestDidFinishSelector:@selector(requestDidFinish:)];
		[self.asiNetworkQueue setMaxConcurrentOperationCount:1];
	}
	
	[self.asiNetworkQueue cancelAllOperations];
	
	NSEnumerator *enumerator = [self.mapCategories keyEnumerator];
	id key;
	NSString* categoryName;
	while ((key = [enumerator nextObject])) {
		categoryName=(NSString*) key;
		NSMutableArray* maps=[self.mapCategories objectForKey:categoryName];
		NSEnumerator * enumerator = [maps objectEnumerator];
		id mapelement;
		while(mapelement = [enumerator nextObject])
		{
			NSMutableDictionary* map=(NSMutableDictionary*)mapelement;
			NSNumber* download=(NSNumber*)[map objectForKey:@"download"];
			bool doDownload=download.boolValue;
			if(doDownload)
			{
				//Create category folder for the download
				[MEMapObjectBase createMapCategory:categoryName];
				
				//Get map information
				NSString* mapName;
				
				BOOL isZipFile;
				
				mapName=[map objectForKey:@"mapname"];
				if(mapName!=nil)
				{
					isZipFile=NO;
				}
				else
				{
					mapName=[map objectForKey:@"zipname"];
					if(mapName!=nil)
					{
						isZipFile=YES;
					}
				}
	
				//Store the fact that this map is being downloaded so it can be enabled later
				NSString* mapPath=[MEMapObjectBase mapPathForCategory:categoryName mapName:mapName];
				[self.downloadedMapsNames addObject:mapPath];
				
				//Create all download reqeusts for the download queue
				if(isZipFile)
				{
					NSString* zipFileName;
					NSString* zipFileURL;
					zipFileURL=[map objectForKey:@"zipfileurl"];
					zipFileName=[NSString stringWithFormat:@"%@.zip",[MEMapObjectBase GetMapPath:categoryName map:mapName]];
					ASIHTTPRequest* requestZipFile=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:zipFileURL]];
					requestZipFile.downloadDestinationPath=zipFileName;
					[self.asiNetworkQueue addOperation:requestZipFile];
					[requestZipFile release];
				}
				else
				{
					NSString* mapFileURL;
					NSString* mapIndexFileURL;
					NSString* mapFileName;
					NSString* mapIndexFileName;
					mapFileURL=[map objectForKey:@"mapfileurl"];
					mapIndexFileURL=[map objectForKey:@"mapindexfileurl"];
					mapFileName = [MEMapObjectBase mapFileNameForCategory:categoryName map:mapName];
					mapIndexFileName = [MEMapObjectBase mapIndexFileNameForCategory:categoryName map:mapName];
					ASIHTTPRequest* requestMapFile=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:mapFileURL]];
					[requestMapFile setDownloadDestinationPath:mapFileName];
					ASIHTTPRequest* requestMapFileIndex=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:mapIndexFileURL]];
					[requestMapFileIndex setDownloadDestinationPath:mapIndexFileName];
					[self.asiNetworkQueue addOperation:requestMapFile];
					[self.asiNetworkQueue addOperation:requestMapFileIndex];
					[requestMapFile release];
					[requestMapFileIndex release];
				}
			}
		}
	}
	
	[self.asiNetworkQueue go];
}

- (void) requestDidFail:(ASIHTTPRequest*) request
{
	self.downloadRequestsDidFail=YES;
	[self.asiNetworkQueue cancelAllOperations];
	[self.lblStatus setText:@"Download failed. Online?"];
	[self.btnDone setEnabled:YES];
	self.downloadInProgress=NO;
}

- (void) receivedRequestHeaders:(ASIHTTPRequest*)request headers:(NSDictionary*) headers
{
	if(request.responseStatusCode!=200)
	{
		[self requestDidFail:nil];
		//Delete the file that was downloaded
		NSFileManager *fileMgr = [NSFileManager defaultManager];
		[fileMgr removeItemAtPath:request.downloadDestinationPath error:nil];
	}
}

+ (NSArray *) allZipFilesInPath:(NSString *)directoryPath
{
    NSMutableArray *filePaths = [[[NSMutableArray alloc] init] retain];
	
    NSDirectoryEnumerator *enumerator = [[[NSFileManager defaultManager] enumeratorAtPath:directoryPath] retain] ;
	
    NSString *filePath;
	
    while ( (filePath = [enumerator nextObject] ) != nil )
	{
        if(
		   [[filePath pathExtension] isEqualToString:@"zip"] ||
		   [[filePath pathExtension] isEqualToString:@"ZIP"]
		   )
		{
			NSString* fullFileName = [NSString stringWithFormat:@"%@/%@",
									  directoryPath, filePath];
            [filePaths addObject:fullFileName];
        }
    }
    [enumerator release];
    return filePaths;
}

-(void) unzipAllZipFiles
{
	__block UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"Decompressing downloaded files.\nPlease Wait..."
									   message:nil
									  delegate:self
							 cancelButtonTitle:nil
							 otherButtonTitles: nil];
	[alert show];
	
	UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	// Adjust the indicator so it is up a few pixels from the bottom of the alert
	indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
	[indicator startAnimating];
	[alert addSubview:indicator];
	[indicator release];
	
	dispatch_queue_t backgroundQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	__block DownloadViewController* blockSelf = self;
	[blockSelf retain];
	dispatch_async(backgroundQ, ^{
		
		//Get a list of all zip files.
		NSArray* zipFileNames = [DownloadViewController allZipFilesInPath:
								 [MEMapObjectBase GetMapsPath]];
		
		ZipArchive *zipArchive = [[ZipArchive alloc]init];
		
		for(NSString* zipFileName in zipFileNames)
		{
			NSString* destPath=[zipFileName stringByDeletingLastPathComponent];
			
			//Open zip file and unzip it.
			[zipArchive UnzipOpenFile:zipFileName];
			[zipArchive UnzipFileTo:destPath overWrite:YES];
			[zipArchive UnzipCloseFile];
			
			//Delete the zip file.
			[[NSFileManager defaultManager] removeItemAtPath:zipFileName error:nil];
			
			//Base map update? If so need to restart.
			if([[destPath lastPathComponent]isEqualToString:@"BaseMaps"])
			{
				blockSelf.mustRestart=YES;
			}
		}
		
		//Close dialog on main thread and clean up other resources
		dispatch_sync(dispatch_get_main_queue(), ^{
			[blockSelf release];
			[alert dismissWithClickedButtonIndex:0 animated:YES];
			[alert release];
			[self backGroundWorkFinished];
		});
	});
	
}

- (void)requestDidFinish:(ASIHTTPRequest *)request
{
}

- (void) backGroundWorkFinished
{
	if(self.mustRestart)
	{
		[self.lblMapsToDownload setText:@"Download complete. Restart Required."];
		[self.btnDone setTitle:@"Restart"];
	}
	[self.btnDone setEnabled:YES];
	[self.btnDownload setEnabled:YES];
	[self.btnDownload setAlpha:1.0];
	[self.btnCancel setEnabled:NO];
	[self.btnCancel setAlpha:0.5];
	[self.btnSelectAll setEnabled:YES];
	[self.btnSelectAll setAlpha:1.0];
	self.downloadInProgress=NO;
	[self.asiNetworkQueue release];
	self.asiNetworkQueue=nil;
}

- (void) queueDidFinish:(ASINetworkQueue*) queue
{
	//Display message
	if(self.downloadCancelled)
	{
		[self.lblMapsToDownload setText:@"Download cancelled."];
		[self.progressDownload setProgress:0];
	}
	else if(self.downloadRequestsDidFail)
	{
		[self.lblMapsToDownload setText:@"Download failed. Online?"];
		[self.progressDownload setProgress:0];
	}
	else
	{
		[self.lblMapsToDownload setText:@"Download complete."];
		
#ifdef TESTFLIGHT
		[TestFlight passCheckpoint:@"Downloaded maps."];
#endif
		//Get a list of all zip files.
		NSArray* zipFileNames = [DownloadViewController allZipFilesInPath:
								 [MEMapObjectBase GetMapsPath]];
		if(zipFileNames.count>0)
		{
			[self unzipAllZipFiles];
			return;
		}
	}
	[self backGroundWorkFinished];
}

- (void) updateMapsToDownloadLabel
{
	unsigned int mapcount=0;
	unsigned long bytestodownload=0;
	NSEnumerator *enumerator = [self.mapCategories objectEnumerator];
	id key;
	while ((key = [enumerator nextObject])) {
		NSMutableArray* maps=(NSMutableArray*) key;
		NSEnumerator * enumerator = [maps objectEnumerator];
		id mapelement;
		while(mapelement = [enumerator nextObject])
		{
			NSMutableDictionary* map=(NSMutableDictionary*)mapelement;
			NSNumber* download=(NSNumber*)[map objectForKey:@"download"];
			if(download.boolValue)
			{
				mapcount++;
				NSNumber* mapsize=[map objectForKey:@"mapfilesize"];
				if(mapsize.intValue==0)
				{
					mapsize=[map objectForKey:@"zipfilesize"];
					bytestodownload+=mapsize.intValue;
				}
				else
				{
					bytestodownload+=mapsize.intValue;
					NSNumber* indexsize=[map objectForKey:@"mapindexfilesize"];
					bytestodownload+=indexsize.intValue;
				}
				
				
			}
		}
	}
	
	if(mapcount==0)
	{
		[btnDownload setEnabled:NO];
		[lblMapsToDownload setText:@"No Maps Selected"];
		return;
	}
	else
	{
		//compute time in seconds
		float seconds = ((float)bytestodownload / 1048576.0) * 6.0;
		float minutes = seconds / 60.0;
		//float hours = minutes / 60;
		//seconds = seconds - (60 * minutes);
		//minutes = minutes-(60 * hours);
		
		[lblMapsToDownload setText:[NSString stringWithFormat:@"%d Selected. %d MB @  %d minutes",
									mapcount,
									(int)bytestodownload/1048576,
									(int)minutes]];
	}
	[btnDownload setEnabled:YES];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
	[self downloadCategories];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
