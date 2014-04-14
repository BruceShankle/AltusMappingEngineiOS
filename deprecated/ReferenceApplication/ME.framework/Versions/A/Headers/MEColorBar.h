//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

///////////////////////////////////////////////////////////////
/**
 Pairs a UIColor with a height. Used in arrays in color bar classes.
 */
@interface MEHeightColor : NSObject

/**Height in meters of terrain.*/
@property (nonatomic, assign) double height;

/**Color terrain at height should be.*/
@property (nonatomic, retain) UIColor* color;

/**Initialize with height and color.*/
-(id) initWithHeight:(double) height color:(UIColor*) color;
@end

///////////////////////////////////////////////////////////////
/**Holds an array of height color objects. Used for specifyin color bars for heigh-sensitive data.*/
@interface MEHeightColorBar : NSObject

/**An array of MEHeightColor objects.*/
@property (nonatomic, retain) NSMutableArray* heightColors;

/**Add a height and color the color bar.*/
-(void) addColor:(UIColor*) color atHeight:(double) height;

@end


///////////////////////////////////////////////////////////////
/**Holds an array of terrain color objects as well as a UIColor object for water color. Used for controlling how terrain data is rendered.*/
@interface METerrainColorBar : MEHeightColorBar
/**Color to use for water. Defaults to UIColor blueColor.*/
@property (nonatomic, retain) UIColor* waterColor;
@end
