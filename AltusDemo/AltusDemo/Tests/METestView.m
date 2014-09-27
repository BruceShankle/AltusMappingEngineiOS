//  Copyright (c) 2014 BA3, LLC. All rights reserved.

#import "METestView.h"

@implementation METestView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

// make it pass through events to things behind it and subviews
-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self) return nil;
    else return hitView;
}

@end
