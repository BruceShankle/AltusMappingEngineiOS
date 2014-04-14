//
//  MEFileDownloader.h
//  Mapp
//
//  Created by Bruce Shankle III on 10/16/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEFileDownloader : NSObject

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *fileConnection;
@property (nonatomic, copy) NSString* destFileName;


+ (BOOL) downloadSync:(NSString*) urlString toFile:(NSString*) fileName;
+ (NSData*) downloadSync:(NSString*) urlString;

+ (unsigned int) activeDownloadCount;
+ (void) incrementDownloadCount;
+ (void) decrementDownloadCount;

@end
