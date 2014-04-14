//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#import <UIKit/UIKit.h>
#import <ME/ME.h>

@interface ExplorerPoint : NSObject
@property (assign) CLLocationCoordinate2D location;
@property (assign) double altitude;
@property (assign) double heading;
@property (assign) double pitch;
@property (assign) double roll;
@end

@interface TerrainExplorerUI : UIViewController <MEMapViewDelegate, MEDynamicMarkerMapDelegate, MEVectorMapDelegate>
@property (retain) MEMapViewController* meMapViewController;

@property (retain) NSMutableArray* terrainMaps;

@property (retain) NSString* markerMapName;
@property (retain) NSMutableArray* markers;

@property (retain) NSString* routeLineMapName;
@property (retain) MELineStyle* routeLineStyle;

@property (retain) NSMutableArray* explorerPoints;

@property (retain) NSTimer* timer;
@property (assign) double interval;

@property (assign) int routeIndex;
@property (assign) double animationDuration;
@property (assign) CGPoint markerAnchorPoint;

@property (retain) NSString* routeFileName;

-(void) start;
-(void) stop;
- (IBAction)removeLastTapped:(id)sender;
- (IBAction)playTapped:(id)sender;
- (IBAction)stopTapped:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *btnPlay;
@property (retain, nonatomic) IBOutlet UIButton *btnRemoveLast;
@property (retain, nonatomic) IBOutlet UIButton *btnStop;
@property (retain, nonatomic) IBOutlet UISegmentedControl *scModeSelect;
@property (retain, nonatomic) IBOutlet UISegmentedControl *scAltitudeSelect;
@property (assign) BOOL isPlaying;
- (IBAction)removeAllTapped:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *btnRemoveAll;
- (IBAction)saveTapped:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *btnSave;
- (IBAction)scAltitudeSelectChanged:(id)sender;
@property (retain, nonatomic) IBOutlet UISlider *sliderAGL;
- (IBAction)sliderAGLChanged:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *lblAGL;
@end
