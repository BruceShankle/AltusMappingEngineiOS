//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "WMSTileDownloader.h"

@implementation WMSTileDownloader

- (id) init {
	if(self=[super init]){
        self.useCache = YES;
		self.wmsURL = @"";
		self.wmsVersion = @"1.3.0";
		self.wmsLayers =  @"";
		self.wmsSRS = @"EPSG:3857";
		self.wmsFormat = @"image/png";
		self.wmsStyleString = @"0";
        self.enableAlpha=YES; //default to PNG
        self.convertTo3857 = YES;
	}
	return self;
}

- (NSString*) urlForTile:(METileProviderRequest*) meTileProviderRequest {
    
	NSMutableArray* requestParams = [[NSMutableArray alloc]init];
	
    [requestParams addObject:@"SERVICE=WMS"];
    [requestParams addObject:@"REQUEST=GetMap"];
	[requestParams addObject:[NSString stringWithFormat:@"VERSION=%@",
							  self.wmsVersion]];
    
	[requestParams addObject:[NSString stringWithFormat:@"LAYERS=%@",
							  self.wmsLayers]];
    
    [requestParams addObject:[NSString stringWithFormat:@"FORMAT=%@",
							  self.wmsFormat]];
    
    if([self.wmsVersion isEqualToString:@"1.3.0"]){
        [requestParams addObject:[NSString stringWithFormat:@"CRS=%@",
                                  self.wmsCRS]];
    }
    else{
        [requestParams addObject:[NSString stringWithFormat:@"SRS=%@",
                                  self.wmsSRS]];
    }
	
	
	
	if(self.useWMSStyle){
		NSString* styleString = [NSString stringWithFormat:@"STYLES=%@",
								 self.wmsStyleString];
		[requestParams addObject:styleString];
	}
	[requestParams addObject:@"WIDTH=256"];
	[requestParams addObject:@"HEIGHT=256"];
	
    if(self.enableAlpha){
        [requestParams addObject:@"TRANSPARENT=True"];
    }
	//[requestParams addObject:@"BGCOLOR=0xFFFFFF"];
	
	NSMutableString* urlString = [[NSMutableString alloc]init];
	[urlString appendString:self.wmsURL];
	[urlString appendString:@"?"];
	for(NSString* param in requestParams) {
		[urlString appendString:param];
		[urlString appendString:@"&"];
	}
	
    
    //http://gis.srh.noaa.gov/arcgis/services/RIDGERadar/MapServer/WMSServer?Service=WMS&REQUEST=GETMAP&Version=1.3.0&Layers=0&Format=image/bmp&CRS=CRS:84&BBOX=-165,18,-70,70&Height=300&WIDTH=300&Styles=default&
    
    CGPoint bboxMin = CGPointMake(meTileProviderRequest.minX, meTileProviderRequest.minY);
    CGPoint bboxMax = CGPointMake(meTileProviderRequest.maxX, meTileProviderRequest.maxY);
    
	//Convert coordinates to EPSG:3857's crazy format?
    if(self.convertTo3857){
        bboxMin = [MEMath transformCoordinateToSphericalMercator:
                   bboxMin];
        
        bboxMax = [MEMath transformCoordinateToSphericalMercator:
                   bboxMax];
    }
	
	[urlString appendString:@"BBOX="];
	[urlString appendFormat:@"%f,%f,%f,%f",
	 bboxMin.x,
	 bboxMin.y,
	 bboxMax.x,
	 bboxMax.y];
	return urlString;
}

@end
