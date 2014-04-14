//
//  MarkerDatabaseSwap.m
//  Mapp
//
//  Created by Bruce Shankle on 12/12/13.
//  Copyright (c) 2013 BA3, LLC. All rights reserved.
//

//Demonstrates swapping the marker database out
//from under the engine while markers are being displayed
#import "MarkerDatabaseSwap.h"

@implementation MarkerDatabaseSwap

- (id) init{
    if(self=[super init]){
        self.name = @"Marker DB Swap";
        self.interval = 1;
        self.markerFile1 = [NSString stringWithFormat:@"%@/markerFile1.sqlite",[self getCachePath]];
        self.markerFile2 = [NSString stringWithFormat:@"%@/markerFile2.sqlite",[self getCachePath]];
        self.mapName1 = [NSString stringWithFormat:@"%@ Map 1", self.name];
        self.mapName2 = [NSString stringWithFormat:@"%@ Map 2", self.name];
        self.isTimerRunning = NO;
        self.newMapReady = NO;
    }
    return self;
}

- (void) dealloc{
    self.markerFile1 = nil;
    self.markerFile2 = nil;
    self.mapName1 = nil;
    self.mapName2 = nil;
    [super dealloc];
}

- (void) start{
    if(self.isRunning){
        return;
    }
    self.isRunning = YES;
    
    //Hook up delegate
    self.oldDelegate = self.meMapViewController.meMapView.meMapViewDelegate;
    self.meMapViewController.meMapView.meMapViewDelegate = self;
    
    //Cache red pin image
    [self.meMapViewController addCachedMarkerImage:[UIImage imageNamed:@"pinRed"]
                                          withName:@"pinRed"
                                   compressTexture:NO
                    nearestNeighborTextureSampling:NO];
    
    //Generate a clustered marker maps to show.
    [self generateMarkerMap:self.markerFile1 mapName:self.mapName1];
}

- (void) stop{
    if(!self.isRunning){
        return;
    }
    self.isRunning = NO;
    self.meMapViewController.meMapView.meMapViewDelegate = self.oldDelegate;
    [self stopTimer];
    self.isTimerRunning = NO;
}

- (void) timerTick{
    //Move the camera to the east
    CLLocationCoordinate2D coord = self.meMapViewController.meMapView.centerCoordinate;
    coord.longitude+=10.0;
    if(coord.longitude>180){
        coord.longitude-=360;
    }
    [self.meMapViewController.meMapView setCenterCoordinate:coord animationDuration:1.0];
}

- (NSString*) getCachePath{
    NSArray*  cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                               NSUserDomainMask,
                                                               YES);
    NSString* cachePath = [cachePaths objectAtIndex:0];
    return cachePath;
}

- (CLLocationCoordinate2D) randomLocation{
    return CLLocationCoordinate2DMake([self randomDouble:-90 max:90], [self randomDouble:-180 max:180]);
}

- (NSMutableArray*) generateRandomMarkers:(int) count{
    NSMutableArray* markers = [[[NSMutableArray alloc]init]autorelease];
    for(int i=0; i<count; i++){
        MEMarkerAnnotation * marker = [[MEMarkerAnnotation alloc]init];
        marker.coordinate = [self randomLocation];
        marker.metaData = [NSString stringWithFormat:@"%d",i];
        marker.weight = 10;
        marker.minimumLevel = 0;
        [markers addObject:marker];
        [marker release];
    }
    return markers;
}

- (void) generateMarkerMap:(NSString*) fileName mapName:(NSString*) mapName{
	MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = mapName;
	mapInfo.mapType = kMapTypeFileMarkerCreate;
	mapInfo.sqliteFileName = fileName;
	mapInfo.zOrder = 200;
	mapInfo.meMarkerMapDelegate = self;
	mapInfo.markers = [self generateRandomMarkers:1000];
	mapInfo.clusterDistance = 20;
	mapInfo.maxLevel = 18;
    mapInfo.isVisible = NO;
	[self.meMapViewController addMapUsingMapInfo:mapInfo];
}

- (void) addMarkerMap:(NSString*) fileName mapName:(NSString*) mapName{
    MEMarkerMapInfo* mapInfo = [[[MEMarkerMapInfo alloc]init]autorelease];
	mapInfo.name = mapName;
	mapInfo.mapType = kMapTypeFileMarker;
	mapInfo.sqliteFileName = fileName;
	mapInfo.zOrder = 200;
	mapInfo.meMarkerMapDelegate = self;
    [self.meMapViewController addMapUsingMapInfo:mapInfo];
}

- (void) mapView:(MEMapView *)mapView willStartLoadingMap:(NSString*) mapName{
    NSLog(@"%@ has started loading.", mapName);
}

- (void) copyFile:(NSString*) sourceFile destFile:(NSString*) destFile{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager copyItemAtPath:sourceFile toPath:destFile error:&error];
//    if(error){
//        NSLog(@"Error copying file:%@",[error debugDescription]);
//    }
}

- (void) deleteFile:(NSString*) fileName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:fileName error:&error];
//    if(error.code!=0){
//        NSLog(@"Error copying file:%@",[error debugDescription]);
//    }
}

- (void) mapView:(MEMapView *)mapView didFinishLoadingMap:(NSString*) mapName{
    
    NSLog(@"%@ has finished loading.", mapName);
    
    if([mapName isEqualToString:self.mapName1]){
        
        if(!self.isTimerRunning){
            //Start generating another map
            [self generateMarkerMap:self.markerFile2 mapName:self.mapName2];
            
            //Make the current one visible
            [self.meMapViewController setMapIsVisible:self.mapName1 isVisible:YES];
            
            //Start the timer
            [self startTimer];
            self.isTimerRunning = YES;
        }
        
        //If a new map is ready, swap maps.
        if(self.newMapReady){
            
            //Remove current marker map
            [self.meMapViewController removeMap:self.mapName1 clearCache:YES];
            
            //Overwrite sqlite file with new one
            [self deleteFile:self.markerFile1]; //Delete old map
            [self copyFile:self.markerFile2 destFile:self.markerFile1]; //Copy new map over it
            [self deleteFile:self.markerFile2]; //Delete new map
            
            //Add the new map.
            [self addMarkerMap:self.markerFile1 mapName:self.mapName1];
            
            //Start generating a new marker map.
            self.newMapReady = NO;
            [self generateMarkerMap:self.markerFile2 mapName:self.mapName2];
        }
        
    }
    
    //When map 2 is done, always just remove it and indicate a swap is ready
    if([mapName isEqualToString:self.mapName2]){
        [self.meMapViewController removeMap:self.mapName2 clearCache:YES];
        self.newMapReady = YES;
    }
    
    
}

- (void) mapView:(MEMapView*)mapView
updateMarkerInfo:(MEMarkerInfo*) markerInfo
		 mapName:(NSString*) mapName{
    markerInfo.cachedImageName = @"pinRed";
    markerInfo.anchorPoint = CGPointMake(7,35);
}

@end
