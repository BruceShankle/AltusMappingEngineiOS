//  Copyright (c) 2014 BA3, LLC. All rights reserved.
#import "ViewManager.h"

@implementation ViewManager
static NSMutableDictionary* _views;
static MEMapView* _controllingView;

+ (void)initialize{
    static BOOL initialized = NO;
    if(!initialized){
        initialized = YES;
        _views = [[NSMutableDictionary alloc]init];
        _controllingView = nil;
    }
}

+(MEMapView*) getControllingView{
    return _controllingView;
}

+(int) getViewCount{
    return _views.count;
}

+(void) setControllingView:(MEMapView*) meMapView{
    
    //Reset previous controller
    if(_controllingView!=nil){
        [_controllingView clearSubscribers];
    }
    _controllingView = meMapView;
    
    //Done?
    if(_controllingView==nil){
        return;
    }
    
    for(id key in _views) {
        MEMapView* subscriber = (MEMapView*)[_views objectForKey:key];
        if(meMapView!=subscriber){
            [meMapView addSubscriber:subscriber];
        }
    }
}

+(NSString*) getUniqueName{
    for(int i=1; i<1000; i++){
        NSString* name = [NSString stringWithFormat:@"View %d", i];
        if([_views objectForKey:name]==nil){
            return name;
        }
    }
    NSLog(@"Too many views. Exiting.");
    exit(0);
    return @"";
}

+(NSString*) registerView:(MEMapView*) meMapView{
    NSString* name = [ViewManager getUniqueName];
    [_views setValue:meMapView forKey:name];
    
    if(_controllingView!=nil){
        [_controllingView addSubscriber:meMapView];
    }
    
    return name;
}

+(void) unregisterView:(MEMapView*) meMapView{
    
    if(meMapView.name!=nil){
        [_views removeObjectForKey:meMapView.name];
    }
    if(_controllingView==meMapView){
        [ViewManager setControllingView:nil];
    }
    else{
        [ViewManager setControllingView:_controllingView];
    }
}
@end
