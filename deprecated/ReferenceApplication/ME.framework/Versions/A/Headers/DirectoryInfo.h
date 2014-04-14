//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>


@interface DirectoryInfo : NSObject {
}

//Singleton-access
+ (DirectoryInfo *) sharedDirectoryInfo;

//Methods
-(NSString*) GetDocumentsDirectory;
-(NSString*) GetDocumentFilePath: (NSString*) fileName;
-(NSString*) GetCacheDirectory;
-(NSString*) GetCacheFilePath: (NSString*) fileName;
-(NSString*) GetBundleFilePath: (NSString*) fileName ofType:(NSString *) fileType;
-(BOOL) addSkipBackupAttributeToItemAtPath:(NSString *)path;

@end
