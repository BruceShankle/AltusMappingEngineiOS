//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "MapLoadingStats.h"

@interface MapInfoLabel () {
    long _cumulativeTime;
}
@end

@implementation MapInfoLabel

-(id) init{
    if(self==[super init]){
        self.timer = [[METimer alloc]init];
        _cumulativeTime = 0;
        self.showCumulativeTime = YES;
    }
    return self;
}

- (void) updateLabelText{
    if(self.showCumulativeTime){
    self.label.text = [NSString stringWithFormat:@"%.1f s %@",
                       (_cumulativeTime / 1000.0),
                       self.mapName];
    }
    else{
        self.label.text = self.mapName;
    }
}

-(void) willStartLoading{
    [self.label setTextColor:[UIColor redColor]];
    [self updateLabelText];
    [self.timer start];
}

-(void) didFinishLoading{
    
    
    [self.timer stop];
    _cumulativeTime += [self.timer getElapsed];
    [self.timer reset];
    
    [self.label setTextColor:[UIColor greenColor]];
    [self updateLabelText];
}

-(void) disable{
    if(!self.showCumulativeTime){
        return;
    }
    self.label.alpha = 0.25;
}

-(void) enable{
    self.label.alpha = 1.0;
}

-(void) remove{
    [self.label removeFromSuperview];
}

@end


@implementation MapLoadingStats

- (id) init {
	if(self=[super init]){
        self.name=@"Map Loading Stats";
	}
	return self;
}

-(UILabel*) createLabel:(int) index{
    
    CGFloat width = 380;
    CGFloat height = 30;
    CGFloat x = self.meMapViewController.meMapView.frame.size.width - width - 10;
    CGFloat y = index * height + 5;
    
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width,height)];
    
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset=CGSizeMake(2.0,2.0);
    label.layer.shadowColor = [[UIColor blackColor] CGColor];
    label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    label.layer.shadowRadius = 1.0;
    label.layer.shadowOpacity = 1.0;
    label.adjustsFontSizeToFitWidth=NO;
    [label setFont:[UIFont boldSystemFontOfSize:15.0f]];
    label.numberOfLines = 1;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentRight;
    [self.meMapViewController.meMapView addSubview:label];
    [self.meMapViewController.meMapView bringSubviewToFront:label];
    return label;
}

-(MapInfoLabel*) addMapInfoLabel:(NSString*) mapName{
    if([mapName hasPrefix:@"_"]){
        return nil;
    }
    MapInfoLabel* mapInfo = [[MapInfoLabel alloc]init];
    mapInfo.mapName = mapName;
    mapInfo.label = [self createLabel:self.mapInfoLabelDictionary.count];
    [mapInfo updateLabelText];
    [self.mapInfoLabelDictionary setObject:mapInfo forKey:mapInfo.mapName];
    return mapInfo;
}

- (void) updateUI{
    NSArray* loadedMaps = self.meMapViewController.loadedMaps;
    NSMutableDictionary* loadMapsDictionary = [[NSMutableDictionary alloc]init];
    for(MEMapInfo* meMapInfo in loadedMaps){
        MapInfoLabel* mapInfoLabel = [self.mapInfoLabelDictionary objectForKey:meMapInfo.name];
        if(mapInfoLabel == nil){
            mapInfoLabel = [self addMapInfoLabel:meMapInfo.name];
        }
        if(mapInfoLabel){
            [loadMapsDictionary setObject:meMapInfo forKey:meMapInfo.name];
        }
    }
    
    for(MapInfoLabel* mapInfoLabel in self.mapInfoLabelDictionary.allValues){
        if(![loadMapsDictionary objectForKey:mapInfoLabel.mapName]){
            [mapInfoLabel disable];
        }
        else{
            [mapInfoLabel enable];
        }
    }
}

-(void) addUI{
    self.mapInfoLabelDictionary = [[NSMutableDictionary alloc]init];
    MapInfoLabel* headerLabel = [self addMapInfoLabel:@"Cumulative Map Loading Time"];
    headerLabel.showCumulativeTime = NO;
    [headerLabel updateLabelText];
    
    NSArray* loadedMaps = self.meMapViewController.loadedMaps;
    for(MEMapInfo* meMapInfo in loadedMaps){
        [self addMapInfoLabel:meMapInfo.name];
    }
}

-(void) removeUI{
    for(MapInfoLabel* mapInfoLabel in self.mapInfoLabelDictionary.allValues){
        [mapInfoLabel remove];
    }
}

-(void) beginTest{
    [self addUI];
    self.oldMapViewDelegate = self.meMapViewController.meMapView.meMapViewDelegate;
    self.meMapViewController.meMapView.meMapViewDelegate = self;
}

-(void) endTest{
    self.meMapViewController.meMapView.meMapViewDelegate = self.oldMapViewDelegate;
    [self removeUI];
}

- (void) mapView:(MEMapView *)mapView willStartLoadingMap:(NSString*) mapName{
    
    if(self.oldMapViewDelegate){
        [self.oldMapViewDelegate mapView:mapView willStartLoadingMap:mapName];
    }
    [self updateUI];
    MapInfoLabel* mapInfoLabel = [self.mapInfoLabelDictionary objectForKey:mapName];
    if(mapInfoLabel){
        [mapInfoLabel willStartLoading];
    }

}


- (void) mapView:(MEMapView *)mapView didFinishLoadingMap:(NSString*) mapName{
    
    if(self.oldMapViewDelegate){
        [self.oldMapViewDelegate mapView:mapView didFinishLoadingMap:mapName];
    }
    [self updateUI];
    MapInfoLabel* mapInfoLabel = [self.mapInfoLabelDictionary objectForKey:mapName];
    if(mapInfoLabel){
        [mapInfoLabel didFinishLoading];
    }
    
}
@end
