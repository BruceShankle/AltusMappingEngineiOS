//
//  Country.m
//  Mapp
//
//  Created by Bruce Shankle III on 9/14/12.
//  Copyright (c) 2012 BA3, LLC. All rights reserved.
//
//cut -f 2,5,6,15 -d "	" PCLI.txt  > countries.txt
//"ctrl+V then tab key"

#import "Country.h"

@implementation Country
@synthesize name;
@synthesize longitude;
@synthesize latitude;
@synthesize population;

- (void) dealloc
{
    self.name = nil;
    [super dealloc];
}

//Parse the elements of a country from a tab delimited string
-(void) parseData:(NSString*) data
{
    NSArray* components = [data componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t\n"]];
    
    if(components.count<4)
    {
        NSLog(data);
        NSLog(@"Country data is not in correct format. Exiting.");
        exit(-1);
    }
    
    NSString* lat = [components objectAtIndex:1];
    NSString* lon = [components objectAtIndex:2];
    NSString* pop = [components objectAtIndex:3];
    
    
    self.name = [components objectAtIndex:0];
    self.latitude = [lat floatValue];
    self.longitude = [lon floatValue];
    self.population = [pop intValue];
    
    //[components release];
}

@end
