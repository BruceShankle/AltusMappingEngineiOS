//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import "TerrainProfileView.h"

@implementation TerrainProfileView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.zeroOffset = -20;
		self.drawTerrainProfile = YES;
		self.maxHeight = 8849; //Highest point on the planet
    }
    return self;
}

- (void) setMaxHeightInFeet:(CGFloat) feet{
	self.maxHeight = [self feetToMeters:feet];
}

- (CGFloat) scaleHeight:(CGFloat) heightValue{
	CGFloat y = heightValue / self.maxHeight;
	y = y * self.frame.size.height;
	y = self.frame.size.height - y + self.zeroOffset;
	return y;
}

- (CGFloat) metersToFeet:(CGFloat) meters{
	return meters * 3.28084;
}

- (CGFloat) feetToMeters:(CGFloat) feet{
	return feet / 3.28084;
}

- (void)drawRect:(CGRect)rect{
	[super drawRect:rect];
	
	//Get and clear context.
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, self.bounds);
	
	short min = SHRT_MAX;
	short max = SHRT_MIN;
	
	
	//Draw obstacle heights along the route.
	if(self.weightSamples != nil){
		CGContextSetLineWidth(context, 2.0);
		//Set up to draw a green line
		CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
		CGFloat x = 0;
		UIBezierPath *path = [[[UIBezierPath alloc] init]autorelease];
		[path moveToPoint:CGPointMake(x, [self scaleHeight:0])];
		for(NSNumber* weight in self.weightSamples){
			//NSLog(@"%d", height.shortValue);
			short weightValue = weight.doubleValue;
			
			if(weightValue<min){
				min=weightValue;
			}
			if(weightValue>max){
				max=weightValue;
			}
			[path addLineToPoint:CGPointMake(x, [self scaleHeight:weightValue])];
			x++;
		}
		[path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
		[path addLineToPoint:CGPointMake(0, self.frame.size.height)];
		[path closePath];
		[path stroke];
		CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0.5 green:0 blue:0 alpha:1] CGColor]);
		[path fill];
	}
	
	//Draw terrain heights
	if(self.heightSamples != nil && self.drawTerrainProfile){
		CGContextSetLineWidth(context, 2.0);
		//Set up to draw a green line
		CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
		CGFloat x = 0;
		UIBezierPath *path = [[[UIBezierPath alloc] init]autorelease];
		[path moveToPoint:CGPointMake(x, [self scaleHeight:0])];
		for(NSNumber* height in self.heightSamples){
			//NSLog(@"%d", height.shortValue);
			short heightValue = height.shortValue;
			
			//Corect for no-data value of 10000
			if(heightValue==10000){
				heightValue = 0;
			}
			
			if(heightValue<min){
				min=heightValue;
			}
			if(heightValue>max){
				max=heightValue;
			}
			[path addLineToPoint:CGPointMake(x, [self scaleHeight:heightValue])];
			x++;
		}
		[path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
		[path addLineToPoint:CGPointMake(0, self.frame.size.height)];
		[path closePath];
		[path stroke];
		CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:0 green:0.5 blue:0 alpha:1] CGColor]);
		[path fill];
	}
	
	//Draw a 0, 5000, 10000, 15000, 20000
	CGFloat w = 60;
	CGFloat fontSize = 15;
	
	
	
	int maxFeet = [self metersToFeet:self.maxHeight];
	int currFeet = 0;
	int increment = [self metersToFeet:self.maxHeight]/5;
	
	while(currFeet<maxFeet){
		CGFloat m = [self feetToMeters:currFeet];
		
		//Draw line
		CGContextSetLineWidth(context, 1.0);
		CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
		CGContextMoveToPoint(context, 0, [self scaleHeight:m]);
		CGContextAddLineToPoint(context, self.frame.size.width, [self scaleHeight:m] );
		CGContextStrokePath(context);
		
		//Draw label
		CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
		CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
		NSString* label = [NSString stringWithFormat:@"%d", currFeet];
		[label drawInRect:CGRectMake(0, [self scaleHeight:m]-fontSize-2, w, fontSize)
				 withFont:[UIFont systemFontOfSize:fontSize]
			lineBreakMode:NSLineBreakByCharWrapping
				alignment:NSTextAlignmentRight];
		currFeet+=increment;
	}
	
	NSString* infoString = [NSString stringWithFormat:@"Min: %0.0f' (%dm) Max: %0.0f' (%dm)",
							[self metersToFeet:min],min,
							[self metersToFeet:max],max];
	
	
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	
	[infoString drawInRect:CGRectMake(0, 0, self.bounds.size.width, fontSize)
				  withFont:[UIFont systemFontOfSize:fontSize]
			 lineBreakMode:NSLineBreakByCharWrapping
				 alignment:NSTextAlignmentCenter];
}

@end
