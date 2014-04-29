//  Copyright (c) 2014 BA3, LLC. All rights reserved.
//Demonstrates how to programatically create a marker image
//that that is derived from a dynamically created view with sub-views.
//Feel free to use this code or portions of it as you wish your applications.
#import "WayPointMarkerImage.h"
#import <AltusMappingEngine/AltusMappingEngine.h>

@implementation WayPointMarkerImage

//Creates a text label with a custom font
+ (UILabel*) createCustomLabel:(NSString*) labelText{
    
    //Create a font
    UIFont * customFont = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    //Create a label
    UILabel *customLabel = [[UILabel alloc] init];
    
    //Set font
    customLabel.font = customFont;
    
    //Set text and attributes
    customLabel.text = labelText;
    customLabel.textColor = [UIColor whiteColor];
    customLabel.numberOfLines = 1;
    customLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    // or UIBaselineAdjustmentAlignBaselines, or UIBaselineAdjustmentNone
    customLabel.textAlignment = NSTextAlignmentCenter;
    
    //Set size now (because it depends on text)
    CGSize maximumLabelSize = CGSizeMake(400, 50);
    CGSize labelSize = [customLabel sizeThatFits:maximumLabelSize];
    
    //Set frame (because it depends on size) with padding
    float padding = 4;
    customLabel.frame = CGRectMake(0, 0, labelSize.width+padding, labelSize.height+padding);
    
    //Set background to 'see-through'
    customLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
    
    //Add rounded corners
    customLabel.layer.cornerRadius = 5;
    
    customLabel.clipsToBounds = YES;
    
    return customLabel;
}

//Creates a stylize marker image, computes anchor point
+ (UIImage*) createCustomMarkerImage: (NSString*) labelText
                         anchorPoint: (CGPoint*) anchorPoint{
    
    //Load the star image and create a view to contain it.
    UIImage* starImage = [UIImage imageNamed:@"WayPointStar"];
    UIImageView* starImageView = [[UIImageView alloc]initWithImage:starImage];
    
    //Create a custom UILabel with our text in it
    UILabel* customLabel = [WayPointMarkerImage createCustomLabel: labelText];
    
    //Compute the frame for the star image (left, centered vertically)
    CGRect starImageFrame = CGRectMake(0,
                                       customLabel.frame.size.height / 2 - starImage.size.height / 2,
                                       starImage.size.width,
                                       starImage.size.width);
    starImageView.frame = starImageFrame;
    
    //Compute a frame rectangle that can contain both the star image and the label
    //with a bit of space between them
    float padding = 5;
    float width = starImage.size.width + padding + customLabel.frame.size.width;
    float height = customLabel.frame.size.height;
    CGRect viewFrame = CGRectMake(0, 0, width, height);
    
    //Move the custom label over to the right a bit
    CGRect customLabelFrame = customLabel.frame;
    customLabelFrame.origin.x += starImage.size.width + padding;
    customLabel.frame = customLabelFrame;
    
    //Create the view we will be returning
    UIView* customLabelView = [[UIView alloc]initWithFrame:viewFrame];
    
    //Set background color
    customLabelView.backgroundColor = [UIColor clearColor];
    
    //Add the sub views
    [customLabelView addSubview:starImageView];
    [customLabelView addSubview:customLabel];
    
    //Use the mapping engine utility to convert our view to an image
    UIImage* customMarkerImage = [MEImageUtil createImageFromView:customLabelView];
    
    //Compute the anchor point (center of star)
    anchorPoint->x = starImage.size.width / 2.0;
    anchorPoint->y = height / 2.0;
    
    //Return the custom marker image
    return customMarkerImage;
}


@end
