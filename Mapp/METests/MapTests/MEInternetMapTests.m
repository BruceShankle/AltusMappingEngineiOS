//
//  InternetMaps.m
//  Mapp
//
//  Created by Bruce Shankle III on 9/27/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import "../METestManager.h"
#import "MEInternetMapTests.h"
#import "../TileProviderTests/MEInternetTileProvider.h"

@implementation MEInternetMapLoadInvisible : METest
- (id) init
{
    if(self = [super init])
    {
        self.name=@"Invisible Loading";
    }
    return self;
}
-(void) start{}
-(void) stop{}
-(void) userTapped
{
	self.isRunning = !self.isRunning;
}
@end

////////////////////////////////////////////////////////////////////////
@implementation MEInternetMapClearCacheTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Clear Cache";
    }
    return self;
}

+ (NSString*) cachePath
{
	return [NSString stringWithFormat:@"%@/%@",
			[[DirectoryInfo sharedDirectoryInfo] GetCacheDirectory],
			[MEInternetMapTest tileCacheRoot]];
}

- (BOOL) isEnabled
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:[MEInternetMapClearCacheTest cachePath]];
}

- (void) clearCache
{
	//Stop all running tests
	//[self.meTestManager stopEntireCategory:self.meTestCategory];
	
	__block UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"Deleting cached tiles.\nPlease Wait..."
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
	__block METestManager* testManager=self.meTestManager;
	[testManager retain];
	dispatch_async(backgroundQ, ^{
		
		//Delete files on the background thread
		NSError *error;
		NSFileManager* fileManager = [NSFileManager defaultManager];
		[fileManager removeItemAtPath:[MEInternetMapClearCacheTest cachePath] error:&error];
		
		//Close dialog on main thread and clean up other resources
		dispatch_sync(dispatch_get_main_queue(), ^{
			[alert dismissWithClickedButtonIndex:0 animated:YES];
			[alert release];
			
			//Tell the test manager a test is updated
			[testManager testUpdated:nil];
			[testManager release];
		});
	});

}

- (void)confirmClearCache
{
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"Clear Cache"];
	[alert setMessage:@"Are you sure you want to clear the cache?"];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		[self clearCache];
	}
	else if (buttonIndex == 1)
	{
		// No
	}
}

- (void) userTapped
{
	if([self isEnabled])
	{
		[self confirmClearCache];
	}
}
- (void) start
{}

- (void) stop
{}

@end

////////////////////////////////////////////////////////////////////////
@implementation MEInternetMapAnalyzeCacheTest
@synthesize fileCount;
@synthesize byteCount;

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Analyze Cache";
		self.fileCount = 0;
		self.byteCount = 0;
		self.bestFontSize = 14.0f;
    }
    return self;
}

- (BOOL) isEnabled
{
	if(![super isEnabled])
	{
		self.fileCount = 0;
		self.byteCount = 0;
	}
	return [super isEnabled];
}

- (NSArray *) allImagesInPath:(NSString *)directoryPath
{
	
    NSMutableArray *filePaths = [[[NSMutableArray alloc] init] retain];
	
    // Enumerators are recursive
    NSDirectoryEnumerator *enumerator = [[[NSFileManager defaultManager] enumeratorAtPath:directoryPath] retain] ;
	
    NSString *filePath;
	
    while ( (filePath = [enumerator nextObject] ) != nil )
	{
		
        // If we have the right type of file, add it to the list
        // Make sure to prepend the directory path
        if(
		   [[filePath pathExtension] isEqualToString:@"png"] ||
		   [[filePath pathExtension] isEqualToString:@"jpg"]
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

- (long) getFileSize:(NSString*) filePath
{
	
	NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath
																					error:nil];
	NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
	return [fileSizeNumber longValue];
}

- (NSString*) label
{
	if(self.fileCount==0) return @"";
	return [NSString stringWithFormat:@"%lu files %.02f MB",
					   self.fileCount,
					   (double)(self.byteCount / (1024*1024))];
	self.fileCount = 0;
	self.byteCount = 0;
}

- (void) analyzeCache
{
	__block UIAlertView *alert;
	alert = [[UIAlertView alloc] initWithTitle:@"Analyzing internet tile cache.\nPlease Wait..."
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
	__block METestManager* testManager=self.meTestManager;
	__block MEInternetMapAnalyzeCacheTest* blockSelf=self;
	[testManager retain];
	[blockSelf retain];
	dispatch_async(backgroundQ, ^{
		
		//Analyze on the background thread
		NSArray* allImages = [self allImagesInPath:[MEInternetMapClearCacheTest cachePath]];
		
		//Update file count
		blockSelf.fileCount = allImages.count;
		
		//Update byte count
		blockSelf.byteCount = 0;
		for(NSString* fileName in allImages)
		{
			blockSelf.byteCount+=[self getFileSize:fileName];
		}
		
		
		[allImages release];
		
		//Close dialog on main thread and clean up other resources
		dispatch_sync(dispatch_get_main_queue(), ^{
			[alert dismissWithClickedButtonIndex:0 animated:YES];
			[alert release];
			
			//Tell the test manager a test is updated
			[testManager testUpdated:nil];
			
			//Clean up
			[testManager release];
			[blockSelf release];
		});
	});
	
}

- (void) userTapped
{
	if([self isEnabled])
	{
		[self analyzeCache];
	}
}
- (void) start
{}

- (void) stop
{}

@end

////////////////////////////////////////////////////////////////////////
@implementation MEInternetMapTest

@synthesize maxLevel;
@synthesize compressTextures;

- (id) init
{
    if(self = [super init])
    {
		self.maxLevel=17;
		self.zoomIndependent = NO;
        self.name=@"ME Internet Map Test";
		self.zOrder = 3;
		self.compressTextures = NO;
		self.loadingStrategy = kHighestDetailOnly;
    }
    return self;
}

+(NSString*) tileCacheRoot
{
	return @"MEInternetMapTests";
}

-(METileProvider*) createTileProvider
{
	NSLog(@"MEInternetMapTest:createTileProvider:You should override this");
	exit(0);
}

- (void) start
{
	METest* invisibleLoadTest = [self.meTestCategory testWithName:@"Invisible Loading"];
	self.loadInvisible = invisibleLoadTest.isRunning;
	
	//Stop all other tests in this category
	//[self.meTestManager stopEntireCategory:self.meTestCategory];
	
	//Create the tile provider (overridden by sub-classes)
	MEInternetTileProvider* tileProvider = [self createTileProvider];
	
	[self.meTestManager setCopyrightNotice:tileProvider.copyrightNotice];
	
	tileProvider.tileCacheRoot = [MEInternetMapTest tileCacheRoot];
    tileProvider.meMapViewController = self.meMapViewController;
	tileProvider.isAsynchronous = YES;
	
	//Add a non-spherical mercator grid below.
	MEVirtualMapInfo* gridMapInfo = [[[MEVirtualMapInfo alloc]init]autorelease];
	gridMapInfo.name = @"basegrid";
	gridMapInfo.isSphericalMercator = NO;
	gridMapInfo.zOrder = 2;
	gridMapInfo.maxLevel = 12;
	gridMapInfo.defaultTileName = @"grayGrid";
	gridMapInfo.meTileProvider = [[[MEBaseMapTileProvider alloc]initWithCachedImageName:@"grayGrid"]autorelease];
	[self.meMapViewController addMapUsingMapInfo:gridMapInfo];
	
	//Add a virtual map using the tile provider
	MEVirtualMapInfo* vMapInfo = [[[MEVirtualMapInfo alloc]init]autorelease];
	vMapInfo.name = self.name;
	vMapInfo.meTileProvider = tileProvider;
	vMapInfo.zOrder = self.zOrder;
	vMapInfo.maxLevel = self.maxLevel;
	vMapInfo.defaultTileName = @"grayGrid";
	vMapInfo.loadingStrategy = self.loadingStrategy;
	if(self.zoomIndependent)
		vMapInfo.contentType = kZoomIndependent;
	else
		vMapInfo.contentType = kZoomDependent;
	vMapInfo.compressTextures = self.compressTextures;
	[self.meMapViewController addMapUsingMapInfo:vMapInfo];
	
	//Load invisibly?
	[self.meMapViewController setMapIsVisible:self.name
									isVisible:!self.loadInvisible];
	
	[tileProvider release];
    
    self.isRunning = YES;
}

- (void) mapView:(MEMapView *)mapView didFinishLoadingMap:(NSString *)mapName
{
	if(self.loadInvisible)
	{
		NSLog(@"Setting map to visible after loading is complete.");
		[self.meMapViewController setMapIsVisible:self.name isVisible:YES];
		self.loadInvisible = NO;
	}
}

- (void) stop
{
    [self.meMapViewController removeMap:self.name
                                    clearCache:NO];
	
	[self.meMapViewController removeMap:@"basegrid"
							 clearCache:NO];
	
	[self.meTestManager setCopyrightNotice:@""];
    self.isRunning = NO;
}

@end

////////////////////////////////////////////////////////////////////////
@implementation MEMapBoxMarsMapTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Mars";
    }
    return self;
}

-(MEInternetTileProvider*) createTileProvider
{
	return [[MEMapBoxMarsTileProvider alloc]init];
}
@end

////////////////////////////////////////////////////////////////////////
@implementation MERefreshMarsTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Refresh Mars";
    }
    return self;
}


-(BOOL) isEnabled
{
	return [self.meMapViewController containsMap:@"Mars"];
}

- (void) start
{
	[self.meMapViewController refreshMap:@"Mars"];
}

- (void) stop
{	
}

@end

////////////////////////////////////////////////////////////////////////
@implementation MEMapBoxLandCoverMapTest
- (id) init{
    if(self = [super init]){
        self.name=@"MapBox LandCover";
    }
    return self;
}
-(MEInternetTileProvider*) createTileProvider{
	return [[MEMapBoxLandCoverTileProvider alloc]init];
}
@end

////////////////////////////////////////////////////////////////////////
@implementation MEMapBoxSatelliteMapTest
- (id) init{
    if(self = [super init]){
        self.name=@"MapBox Satellite";
    }
    return self;
}
-(MEInternetTileProvider*) createTileProvider{
	return [[MEMapBoxSatelliteTileProvider alloc]init];
}
@end


////////////////////////////////////////////////////////////////////////
@implementation MEMapQuestMapTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"MapQuest";
    }
    return self;
}

-(MEInternetTileProvider*) createTileProvider
{
	return [[MEMapQuestTileProvider alloc]init];
}
@end

////////////////////////////////////////////////////////////////////////
@implementation MEMapQuestAerialMapTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"MapQuest Aerial";
		self.maxLevel = 18;
    }
    return self;
}

-(MEInternetTileProvider*) createTileProvider
{
	return [[MEMapQuestAerialTileProvider alloc]init];
}
@end

////////////////////////////////////////////////////////////////////////
@implementation MEMapQuestAerialMapTest2

- (id) init
{
    if(self = [super init])
    {
        self.name=@"MapQuest Aerial - LDF";
		self.loadingStrategy = kLowestDetailFirst;
    }
    return self;
}

-(MEInternetTileProvider*) createTileProvider
{
	MEInternetTileProvider* tp = [super createTileProvider];
	return tp;
}

@end

////////////////////////////////////////////////////////////////////////
@implementation MEOpenStreetMapsMapTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Open Street Maps";
    }
    return self;
}

-(MEInternetTileProvider*) createTileProvider
{
	return [[MEOpenStreetMapsTileProvider alloc]init];
}
@end


////////////////////////////////////////////////////////////////////////
@implementation MEStamenTerrainMapTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Stamen Terrain";
    }
    return self;
}

-(MEInternetTileProvider*) createTileProvider
{
	return [[MEStamenTerrainTileProvider alloc]init];
}
@end

////////////////////////////////////////////////////////////////////////
@implementation MEStamenWaerColorMapTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Stamen Watercolor";
    }
    return self;
}

-(MEInternetTileProvider*) createTileProvider
{
	return [[MEStamenWaterColorTileProvider alloc]init];
}
@end


////////////////////////////////////////////////////////////////////////
@implementation MEIOMHaitiMapTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"IOM Haiti";
		self.maxLevel=18;
    }
    return self;
}

-(MEInternetTileProvider*) createTileProvider
{
	return [[MEIOMHaitiTileProvider alloc]init];
}
@end


/////////////////////////////////////////////////////////////////////////
//Compressed texture version of above tests...
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
@implementation cMEMapBoxLandCoverMapTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"MapBox LandCover - 2 Byte";
		self.compressTextures = YES;
		self.zOrder = 4;
    }
    return self;
}
@end

////////////////////////////////////////////////////////////////////////
@implementation cMEMapQuestMapTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"MapQuest - 2 Byte";
		self.compressTextures=YES;
		self.zOrder = 4;
    }
    return self;
}

@end

////////////////////////////////////////////////////////////////////////
@implementation cMEMapQuestAerialMapTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"MapQuest Aerial - 2 Byte";
		self.compressTextures=YES;
		self.zOrder = 4;
    }
    return self;
}
@end

////////////////////////////////////////////////////////////////////////
@implementation cMEOpenStreetMapsMapTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Open Street Maps - 2 Byte";
		self.compressTextures=YES;
		self.zOrder = 4;
    }
    return self;
}
@end


////////////////////////////////////////////////////////////////////////
@implementation cMEStamenTerrainMapTest

- (id) init
{
    if(self = [super init])
    {
        self.name=@"Stamen Terrain - 2 Byte";
		self.compressTextures=YES;
		self.zOrder = 4;
    }
    return self;
}

@end

