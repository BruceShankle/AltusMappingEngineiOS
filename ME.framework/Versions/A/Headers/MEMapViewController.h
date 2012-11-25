//  Copyright (c) 2012 BA3, LLC. All rights reserved.

//SDK Imports
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreLocation/CoreLocation.h>

//BA3 Imports
#import "MEMapView.h"
#import "MEInfo.h"
#import "METileProvider.h"
#import "MEColorBar.h"
#import "MERenderModes.h"
#import "METileInfo.h"
#import "MEPolygonStyle.h"
#import "MEAnimatedVectorCircle.h"
#import "MEAnimatedVectorReticle.h"
#import "MEMarkerAnnotation.h"
#import "MEMapInfo.h"
#import "MEHitTesting.h"

@interface MEMapViewController : GLKViewController <UIAlertViewDelegate>

/** Forces linker to link this file via NIB-only interfaces.*/
+ (void) forceLink; 

///////////////////////////////////////////////////////////////////////////////////////////
//Properties
/**
 Enables or disables multithreaded resource loading. The default is YES.
 */
@property (nonatomic, getter=isMultithreaded) BOOL multiThreaded;

/** Contains information about the current state of the mapping engine.*/
@property (atomic, retain) MEInfo* meInfo;

/** Returns the MEMapView this view controller manages. This is the same as the view property simply cast to MEMapView* and primarily provided as a convenience.*/
@property (atomic, readonly) MEMapView* meMapView;

/** Returns the current render flags for the view.*/
@property (atomic, assign, readonly) unsigned int renderFlags;

/** Returns true if the engine has been initialize, false otherwise. The view controller may still be in a paused state if the engine is running, but no frames will be presented.*/
@property (atomic, assign, readonly) BOOL isRunning;

/** When set to YES, tells the mapping engine to display verbose messages about state changes and activity.*/
@property (atomic, assign) BOOL verboseMessagesEnabled;

///////////////////////////////////////////////////////////////////////////////////////////
//Core rendering engine management
/** Allocates resources for caching and map loading. Should be called after the cooresponding MEMapView is loaded.*/
- (void) initialize;

/** Free resources related to rendering. Should be called before deallocating mapping engine views.*/
- (void) shutdown;

/** Set rendering mode. When setting or unsetting modes, the following modes are valid:
 - MERenderNone: Disables rendering.
 - MERender2D: Render a 2D top-down view.
 - MERender3D: Render a 3D perspective view.
 - MEInterpolateCamera: Interpolate camera positions.
 - MEDisableDisplayList: Debugging use only.
 - METrackUp: Render with the observer always facing towards the top of the screen, no matter what the heading is.
 2D and 3D mode are mutually exclusive.
 */
- (void) setRenderMode:(MERenderModeType) mode;

/** Un-set a rendering mode*/
- (void) unsetRenderMode:(MERenderModeType) mode;

/**Returns whether or not a given rendering mode is currently set.*/
- (BOOL) isRenderModeSet:(MERenderModeType) mode;

/**If you have set the METrackUp rendering mode, you can set the trackup-forward distance with this function.
 @param meters The distance in meters the move the camera forward from the pivot point where rotation occurs when heading is adjusted.
 @param animated True if the track-up forward distance should be animated.
 @param If animated, the animation interval in seconds.
 */
- (void) setTrackUpForwardDistance:(double) meters
						  animated:(BOOL) animated
				 animationDuration:(double) animationDuration;

/**Returns the current track up forward distance.*/
- (double) getTrackUpForwardDistance;

/**If you have set the METrackUp rendering mode, you can set the trackup-forward distance with this function.
 @param meters The distance in meters the move the camera forward from the pivot point where rotation occurs when heading is adjusted.
 */
- (void) setTrackUpForwardDistance:(double) meters;

//////////////////////////////////////////////////////////////
//Map layer management

/** Add a map layer to the current view. The map must have been a map produced by the BA3 metool.
 */
- (void) addMap:(NSString*) mapName mapSqliteFileName:(NSString*) mapSqliteFileName mapDataFileName:(NSString*) mapDataFileName compressTextures:(BOOL) compressTextures;

/** Removes all maps currently displayed and optionally flushes the cache.*/
- (void) removeAllMaps:(BOOL) clearCache;

/** Remove a map layer from the current view and optionally clear the internal caches. If caches are not cleared, and you re-enable the same map at a future point, cached data 'may' be used to draw the map. If you choose to clear the cache, the engine will re-request all map data if you later re-add that map. Whether or not you want to flush the cache depends on your useage scenario. For example, if your application has downloaded an updated map, you would want to remove the existing one and clear its data from the cache. If the user is just toggling a map on and off, you would not want to clear it data from the cache the cache.
 @param mapPath The name of the map file (or layer name).
 @param clearCache A boolean value that indicates whether or not to flush the map's data from the cache.*/
- (void) removeMap:(NSString*) mapPath
        clearCache:(BOOL) clearCache;

/**Intended for virtual tile providers, when called, tells the mapping engine to re-request all tiles for the specified map. This could be use, for example, for displaying weather where the map changes over time.*/
- (void) invalidateMap:(NSString*) mapName;

/** Returns an array me MEMapInfo objects, each specifiying information about a map currently loaded. */
- (NSArray*) loadedMaps;

/** Returns whether or not the specified map is currently enabled.*/
- (BOOL) containsMap:(NSString*) mapPath;

/** Set the alpha value of a map layer.
 @param mapPath The name of the map file wihout the file extension.
 @param alpha Value to set alpha to. Range is 0 to 1.*/
- (void) setMapAlpha:(NSString*) mapPath
               alpha:(CGFloat) alpha;

/** Get the alpha value of a map layer.
 @param mapPath The name of the map.*/
- (double) getMapAlpha:(NSString*) mapPath;

/**Sets whether or not a loaded map is visible or not visible. This is not the same as setting the alpha to 0.0. When alpha is set to 0.0, the engine will still draw the map 'invisibly' going through all drawing logic. When the map is not visible, all loading logic for a map occurs, but the drawing logic is skipped. This can be used, for example, if you want to add a map, set it to invisible, wait for the engine to load it, then when your delegate is notified that loading is complete, to set visibilty to true to have the map instantly appear without the user seeing loading.*/
- (void) setMapIsVisible:(NSString*) mapPath
			   isVisible:(BOOL) isVisible;

/**Returns whether or not a map is visible.*/
- (BOOL) getMapIsVisible:(NSString*) mapPath;

/** Set the zorder value of a map layer.
 @param mapPath The name of the map.
 @param zOrder Value to set the zorder to.*/
- (void) setMapZOrder:(NSString*) mapPath
               zOrder:(int) zOrder;

/** Get the current zorder value of a map layer.*/
- (int) getMapZOrder:(NSString*) mapPath;

///////////////////////////////////////////////////////////////////////////////////////////
//Terrain avoidance

/** Updates the terrain avoidance and warning system (TAWS) color bar. If not set, the mapping engine will use a default TAWS color bar. You can set the color bar at any time.
 */
-(void) updateTawsColorBar:(METerrainColorBar*)colorBar;

/**Returns the current terrain avoidance and warning system (TAWS) color bar.*/
-(METerrainColorBar*) tawsColorBar;

/** Updates the altitude that is used to draw the TAWS layer (if enabled).
 */
-(void) updateTawsAltitude:(double)altitude;

///////////////////////////////////////////////////////////////////////////////////////////
//Virtual Map Management

/** Add a MapBox style map generated in TileMill. Should be removed with the removeMBTilesMap function.
 @param name Unique name for this layer.
 @param databaseFile Full path to the .mbtiles sqlite file for the map.
 @param tileType The type of tiles, jpg or png.
 @param zOrder An integer value greater than or equal to 1 that sets the layers draw order relative to other layers. A lower value means the layer will lower in the stack.
 @param maxLevel Maximum zoom level tiles go to.
 */
-(void) addMBTilesMap:(NSString*) name
		 databaseFile:(NSString*) databaseFile
		   tileType:(MEImageDataType) tileType
			   zOrder:(int) zOrder
			 maxLevel:(int) maxLevel;

/** Pauses the animation in the given animated virtual map layer.
 @param name Name of the animated virtual map layer
 */
- (void) pauseAnimatedVirtualMap:(NSString*)name;

/** Resumes playback of the animation in the given animated virtual map layer.
 @param name Name of the animated virtual map layer
 */
- (void) playAnimatedVirtualMap:(NSString*)name;

/** Sets the current frame of the animation in the given animated virtual map layer.
 @param name Name of the animated virtual map layer
 @param frame Frame to be set immediately
 */
- (void) setAnimatedVirtualMapFrame:(NSString*)name
                              frame:(unsigned int) frame;


///////////////////////////////////////////////////////////////////////////////////////////
//Marker map management

/** For dynamic marker maps, adds a new marker to the marker map.
 @param mapName Unique name of the marker map layer.
 @param marker Object that describes the marker.
 */
- (void) addMarkerToMap:(NSString*)mapName
                 marker:(MEMarkerAnnotation*)marker;

/** Sets a height color bar for the specified marker map. Once set you can call setMarkerMapColorBarEnabled to turn use of the color bar on and off.*/
- (void) setMarkerMapColorBar:(NSString*)mapName
			   colorBar:(MEHeightColorBar*) colorBar;

/** Sets where or not a color bar is applied when rendering markers.*/
- (void) setMarkerMapColorBarEnabled:(NSString*)mapName
							 enabled:(BOOL) enabled;

/** For dynamic marker maps, updates the geographic position of the specified marker.
 @param mapName Unique name of the marker map.
 @param metaData Unique ID of the marker to update.
 @param newLocation New geographic location of the marker.
 */
- (void) updateMarkerLocationInMap:(NSString*) mapName
                         metaData:(NSString*) metaData
                       newLocation:(CLLocationCoordinate2D) newLocation;

/** For dynamic marker maps, updates the geographic position of the specified marker, optionally with animation.
 @param mapName Unique name of the marker map.
 @param metaData Unique ID of the marker to update.
 @param newLocation New geographic location of the marker.
 @param animated If YES, animate the marker to the new location.
 @param animationDuration The animation duration in seconds.
 */
- (void) updateMarkerLocationInMap:(NSString*) mapName
						  metaData:(NSString*) metaData
                       newLocation:(CLLocationCoordinate2D) newLocation
						  animated:(BOOL) animated
				 animationDuration:(double) animationDuration;

/** For dynamic marker maps, update multiple attributes of a marker.*/
- (void) updateMarkerInMap:(NSString*) mapName
				  metaData:(NSString*) metaData
			   newLocation:(CLLocationCoordinate2D) newLocation
			   newRotation:(double) newRotation
				  animated:(BOOL) animated
		 animationDuration:(double) animationDuration;

/** For dynamic marker maps, updates the rotation of the marker.
 */
- (void) updateMarkerRotationInMap:(NSString*) mapName
						  metaData:(NSString*) metaData
                       newRotation:(double) newRotation;

/** For dynamic marker maps, updates the rotation of the marker.
 */
- (void) updateMarkerRotationInMap:(NSString*) mapName
						  metaData:(NSString*) metaData
                       newRotation:(double) newRotation
						  animated:(BOOL) animated
				 animationDuration:(double) animationDuration;


///////////////////////////////////////////////////////////////////////////////////////////
//Vector map management

/**Adds a polygon to a vector map.
 @param mapName The name of the vector map.
 @param points An array of NSValue objects that wrap CGPoints. The x,y values of the point represent longitude,latitude.
 @param style The style of the polygon.*/
- (void) addPolygonToVectorMap:(NSString*) mapName
                        points:(NSMutableArray*)points
                         style:(MEPolygonStyle*)style;

/**Adds a style to a feature in a vector map.
 @param mapName The name of the vector map.
 @param featureID The polygon feature of the map to apply the style to.
 @param style The style to apply.*/
- (void) addPolygonStyleToVectorMap:(NSString*) mapName
                         featureId:(unsigned int) featureID
                             style:(MEPolygonStyle*)style;

/**Updates a style previously set for a feature in a vector map.
 @param mapName The name of the vector map.
 @param featureID The polygon feature of the map to apply the style to.
 @param style The style to apply.
 @param animationDuration The duration in seconds to animation to this style from the previous style*/
- (void) updatePolygonStyleInVectorMap:(NSString*) mapName
                             featureId:(unsigned int) featureID
                                 style:(MEPolygonStyle*)style
                     animationDuration:(CGFloat)animationDuration;

/**Adds a line to a vector map.
 @param mapName The name of the vector map.
 @param points An array of NSValue objects that wrap CGPoints. The x,y values of the point represent longitude,latitude for each point in the line.
 @param style The style of the polygon.*/
- (void) addLineToVectorMap:(NSString*) mapName
                     points:(NSArray*)points
                      style:(MELineStyle*)style;

/**Adds a dynamic line to a vector map.
 @param mapName The name of the vector map.
 @param points An array of NSValue objects that wrap CGPoints. The x,y values of the point represent longitude,latitude for each point in the line.
 @param style The style of the polygon.*/
- (void) addDynamicLineToVectorMap:(NSString*) mapName
                            lineId:(NSString*) lineId
                            points:(NSArray*)points
                             style:(MELineStyle*)style;

/**Adds an ESRI shape file to an in-memory vector map.
 @param mapName The name of the vector map.
 @param shapeFilePath Full path to the shape file.
 @param style The style of the line with which to render the shape.*/
-(void) addShapeFileToVectorMap:(NSString*) mapName
				  shapeFilePath:(NSString*) shapeFilePath
						  style:(MELineStyle*)style;


/**Clears all dynamic lines and polygosn from a vector map.
 @param mapName The name of the vector map.*/
- (void) clearDynamicGeometryFromMap:(NSString*) mapName;

/**Returns an object if there is vector geometry present at the screen point. Use this for detecting when the user has touched vector geometry. Returns nil if nothing is pressed. If the vectorDelegate is set, also calls hitdetection methods of the delegate.
 @param mapName Name of the vector map layer on which to search for hits.
 @param point Screen position in points to check.*/
- (MEVectorGeometryHit*) detectHitOnMap:(NSString*) mapName
						  atScreenPoint:(CGPoint) screenPoint
                    withVertexHitBuffer:(CGFloat)vertexHitBuffer
                      withLineHitBuffer:(CGFloat)lineHitBuffer;

/**Sets tesselation threshold for lines in nautical miles. */
- (void) setTesselationThresholdForMap:(NSString*) mapName
                         withThreshold:(CGFloat) threshold;

///////////////////////////////////////////////////////////////////////////////////////////
//Clipping
/** Allow one map to clip another map. Anywhere the clip map would draw is will not be drawn by the target map.*/
- (void) addClipMapToMap:(NSString*)mapName
             clipMapName:(NSString*)clipMapName;


///////////////////////////////////////////////////////////////////////////////////////////
//Symbiote management
/** Adds an object that implements the MESymbiote protocol. MESymbiote objects are notified when to update their positions on screen and/or to redraw themselves to stay synchronized with drawing done by the mapping engine. See the MESymbiote protocol.*/
- (void) addSymbiote:(id<MESymbiote>) symbiote;

/** Removes a symbiote object. When the object is removed, it will not longer be updated by the mapping engine. See the MESymbiote protocol.*/
- (void) removeSymbiote:(id<MESymbiote>) symbiote;


///////////////////////////////////////////////////////////////////////////////////////////
//Map management API - This will be removed

/**Updates the terrain color bar. When updated, the base map layer derived from terrain will be colored using the new color bar. 3D terrain will also use these colors. If not set, the mapping engine will use a default terrain color bar. You should set this value before beginning animation, otherwise cached tiles may not inherit the new colors.
 */
-(void) updateTerrainColorBar:(METerrainColorBar*) terrainColorBar;

/**Returns the current terrain color bar.*/
-(METerrainColorBar*) terrainColorBar;

/**Called when a tile has been loaded through a virtual layer.*/
- (void) tileLoadComplete:(METileInfo*) tileInfo;

/**Tells the engine when the application receives a memory warning from the system.*/
- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application;

- (void) setClippingPlaneValue:(CGFloat) newValue;

/**Adds an animated vector circle. This can be used for pulsating location beacons.*/
- (void) addAnimatedVectorCircle:(MEAnimatedVectorCircle*) animatedVectorCircle;

/**Update the position of an animated vector circle.*/
- (void) updateAnimatedVectorCircleLocation:(NSString*) name
								newLocation:(CLLocationCoordinate2D)newLocation
								   animated:(BOOL) animated
						  animationDuration:(CGFloat) animationDuration;

/**Removes an animated vector circle.*/
- (void) removeAnimatedVectorCircle:(NSString*) name;

/**Adds an animated reticle to mark locations.*/
- (void) addAnimatedVectorReticle:(MEAnimatedVectorReticle*) animatedVectorReticle;

/**Update the position of an animated reticle.*/
- (void) updateAnimatedVectorReticleLocation:(NSString*) name
								 newLocation:(CLLocationCoordinate2D)newLocation
									animated:(BOOL) animated
						   animationDuration:(CGFloat) animationDuration;

/**Removes an animated reticle.*/
- (void) removeAnimatedVectorReticle:(NSString*) name;

/**Adds a map using a map info object.*/
- (void) addMapUsingMapInfo:(MEMapInfo*) meMapInfo;

@end
