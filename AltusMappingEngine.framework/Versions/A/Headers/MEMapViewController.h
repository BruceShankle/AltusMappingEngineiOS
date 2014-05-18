//  Copyright (c) 2012 BA3, LLC. All rights reserved.
#pragma once

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
#import "MEMarkerInfo.h"
#import "MEMapInfo.h"
#import "MEHitTesting.h"

@class MEGeometryGroup;

@interface MEMapViewController : GLKViewController <UIAlertViewDelegate>

/** Forces linker to link this file via NIB-only interfaces.*/
+ (void) forceLink;

/**The EAGLContext in use by this view controller and its view.*/
@property (strong, nonatomic) EAGLContext *context;

///////////////////////////////////////////////////////////////////////////////////////////
//Properties
/**
 Enables or disables multithreaded resource loading. The default is YES.
 */
@property (nonatomic, getter=isMultithreaded) BOOL multiThreaded;

/**
 If set to YES, prior to calling initialize, Altus will use its first-gen
 thread management system.
 */
@property (nonatomic) BOOL useLegacyResourceManager;

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

/** The core in-memory cache size in bytes. Defaults to 60 MB on single-core devices, and 90 MB on dual-core devices. You should adjust this setting before calling the initialize function.*/
@property (assign) unsigned long coreCacheSize;

/** Controls the maximum number of tiles in flight per frame. Defaults to 3 on single-core devices, and 10 on dual-core devices. You should adjust this setting before calling the intialize function.*/
@property (assign) unsigned int maxTilesInFlight;

/** Controls the maximum number of tiles that will be loaded per frame that are supplied by asynchronous tile providers. This is especially helpful for animated tile providers that may be returning a large numbers of frames at once and do not with to cause a frame-rate hitch. The default is 1 tile per frame. This only applies to tiles that supply image data. Tile provider responses that indicate no loading is neccessary (not available or inivisible) are all handled every frame.*/
@property (assign) unsigned int maxAsyncTileLoadsPerFrame;

/** Controls the the number of levels up that parent tiles will be searched in virtual maps that are supplied tiles by tiler providers. The defaul is 5. Reducing this number can potentially save bandwidth in the case of internet-based tile providers, but at the cost of the user potentially not seeing map data if they zoom or pan quickly as tiles are downloading.*/
@property (assign) unsigned int maxVirtualMapParentSearchDepth;

/** Controls the target frames per second to render when current run loop is in UITrackingRunLoopMode. This occurs, for example, when a table view is being scrolled. The default is 10.*/
@property (assign) unsigned int uiTrackingRunLoopPreferredFramesPerSecond;

/** When set to YES, the mapping engine will attempt to reduce the framerate when possible.*/
@property (assign) BOOL greenMode;

/** The frame rate to render at when in green mode, resources are not loading, there are no animations, the camera is not moving, and the user is not interacting with the map. Defaults to 1 fps.*/
@property (assign) unsigned int greenModeIdleFramerate;

/** The frame rate to render at when an animation is occurring, resources are loading, or the camera is moving. Defaults to 12.*/
@property (assign) unsigned int greenModeCruiseFramerate;

/** The frame rate to render at when the user is interacting with the map. Defaults to 30 fps.*/
@property (assign) unsigned int greenModeFullThrottleFramerate;

///////////////////////////////////////////////////////////////////////////////////////////
//Core rendering engine management
/** Allocates resources for thread management, data caching, and map loading. Should be called after the cooresponding MEMapView is loaded.*/
- (void) initialize;

/** Free resources related to rendering. Should be called before deallocating mapping engine views.*/
- (void) shutdown;

/** Set rendering mode. When setting or unsetting modes, the following modes are valid:
 - MERenderNone: Disables rendering.
 - MERender2D: Render a 2D top-down view.
 - MERender3D: Render a 3D perspective view.
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
 @param points The distance in screen points to move the camera forward from the pivot point where rotation occurs when heading is adjusted.
 @param animationDuration If animated, the animation interval in seconds, zero otherwise.
 */
- (void) setTrackUpForwardDistance:(double) points
				 animationDuration:(double) animationDuration;

/**Returns the current track up forward distance.*/
- (double) getTrackUpForwardDistance;

/**If you have set the METrackUp rendering mode, you can set the trackup-forward distance with this function.
 @param meters The distance in meters the move the camera forward from the pivot point where rotation occurs when heading is adjusted.
 */
- (void) setTrackUpForwardDistance:(double) points;

//////////////////////////////////////////////////////////////
//Map layer management

/** Add an Altus map package.*/
- (void) addPackagedMap:(NSString*) mapName packageFileName:(NSString*) packageFileName;

/** Add a map layer to the current view. The map must have been a map produced by the BA3 metool.
 @param mapName Unique name of the map for this view.
 @param mapSqliteFileName The fully qualifed path/filename of the map's .sqlite file.
 @param mapDataFileName The fully qualified path/filename of the map's .map data file.
 @param compressTextures Whether or not raster data from the map should be compressed to 2-byte format internally.
 */
- (void) addMap:(NSString*) mapName mapSqliteFileName:(NSString*) mapSqliteFileName mapDataFileName:(NSString*) mapDataFileName compressTextures:(BOOL) compressTextures;

/** Add a map layer sourced from an image that is made up of mosaiced spherical mercator tiles.
 @param mapName Unique name of the map for this view.
 @param imageFileName A PNG or JPG image file that will be fully decompressed into memory (4 bytes per pixel, make sure you have enough memory).
 @param minX longitdue of West-most pixel in the source image.
 @param minY latitude of South-most pixel in the source image.
 @param maxX longitude of East-most pixel in the source image.
 @param maxY latitude of North-most pixel in the source image.
 @param maxLevel maximum spherical mercator tile level to zoom to on this map (try to set equivalent to your source tiles for the mosaiced image for best efficienty)
 @param defaultTileName name of a cached image to render as a placeholder for a tile that is being loaded
 @param compressTextures Whether or not raster data from the map should be compressed to 2-byte format internally.
 @param zOrder Layer order for this map.
 @param mapLoadinStrategy Determines if only the tiles visible at the current zoom level are loaded first (kHighestDetailOnly and fastest loading) or load lower resolution tiles first (kLowestDetailFirst) which can make the zooming experience less jarring for the user.
 */
- (void) addSphericalMercatorMosaicRasterMap:(NSString*) mapName
                               imageFileName:(NSString*) imageFileName
                                        minX:(long) minX
                                        minY:(long) minY
                                        maxX:(long) maxX
                                        maxY:(long) maxY
                                    maxLevel:(uint) maxLevel
                             defaultTileName:(NSString*) defaultTileName
                            compressTextures:(BOOL) compressTextures
                                      zOrder:(uint) zOrder
                          mapLoadingStrategy:(MEMapLoadingStrategy) mapLoadingStrategy;

/** Add a vector map layer to the current view. The map must have been a map produced by the BA3 metool.
 */
- (void) addVectorMap:(NSString*) mapName mapSqliteFileName:(NSString*) mapSqliteFileName mapDataFileName:(NSString*) mapDataFileName;


/** Add a marker map layer to the current view with from a file
 */
- (void) addVirtualMarkerMap:(MEMarkerMapInfo*) mapInfo;

/** Adds a raster map generated from raw double data */
- (void) addDataGridMap:(NSString*)mapName
              withArray:(double*)array
              withWidth:(int)width
             withHeight:(int)height
             withBounds:(CGRect)bounds;

/** Sets the base map (zOrder of 0) layer to be a tiled map of the specified image.
 @param tiledImage A 256x256 image that will be tiled for the entire map.*/
- (void) setBaseMapImage:(UIImage*) tiledImage;


/** Sets the base map (zOrder of 0) layer to be an tiled map of the specified cached image.
 @param cachedImageName. The name of the cached image.*/
- (void) setBaseMapCachedImage:(NSString*) cachedImageName;


/**
 Adds an MBTiles raster map. Generally, these maps are produced with TileMill from MapBox. The map is added using an internal native tile provider path. Map bounds and maximum zoom level are read from the MBTiles database. Internally, the mapping engine will use a completely native tile provider to load tiles from the MBTiles database and no extra image memory copies are ever created. This is the fastest way possible to load an MBTiles map using the mapping engine.
 
 @param mapName Unique name of the map layer
 @param fileName Fully qualified path to the mbtiles filename
 @param defaultTileName The name of a cached image to use if waiting for tiles to load.
 @param imageDataType Inidicates whether the raster tiles are JPG or PNG
 @param compressTextures YES to compress tile textures to a 2 byte format
 @param zOrder Layer order for this map
 @param mapLoadingStrategy Controls how tiles get loaded, kLowestDetailFirst will load tiles top down (less efficient but better user experience, kHighestDetailOnly will load only tiles at the current zoom level, faster)
 */
- (void) addMBTilesMap:(NSString*) mapName
			  fileName:(NSString*) fileName
	   defaultTileName:(NSString*) defaultTileName
		 imageDataType:(MEImageDataType) imageDataType
	   compessTextures:(BOOL) compressTextures
				zOrder:(uint) zOrder
    mapLoadingStrategy:(MEMapLoadingStrategy) mapLoadingStrategy;

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
- (BOOL) containsMap:(NSString*) mapName;

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

/** Pauses the animation in the given animated virtual map layer.
 @param name Name of the animated virtual map layer
 */
- (void) pauseAnimatedVirtualMap:(NSString*)name;

/** Resumes playback of the animation in the given animated virtual map layer.
 @param name Name of the animated virtual map layer
 */
- (void) playAnimatedVirtualMap:(NSString*)name;

/** Triggers re-request of on-screen tiles that were marked as isDirty when they were requested from the tile provider. Also invalidates cached off-screen tiles that were marked as dirty. Applies to animated and non-animated virtual maps. */
- (void) refreshDirtyTiles:(NSString*) name;


/** Sets whether or not tiles are automatically requested for an animated map as the user pans / zooms. If set to NO, you should call refreshDirtyTiles to have tiles be requested on some periodic basis.*/
- (void) setAutomaticTileRequestModeForAnimatedVirtualMap:(NSString*) name enabled:(BOOL) enabled;

/** Sets the current frame of the animation in the given animated virtual map layer.
 @param name Name of the animated virtual map layer
 @param frame Frame to be set immediately
 */
- (void) setAnimatedVirtualMapFrame:(NSString*)name
                              frame:(unsigned int) frame;

/** Sets the current frame count of the animation in the given animated virtual map layer.
 @param name Name of the animated virtual map layer
 @param frameCount Frame count to be set immediately
 */
- (void) setAnimatedVirtualMapFrameCount:(NSString*)name
                              frameCount:(unsigned int) frameCount;

/** Sets the frame that marks the beginning frame of the animation sequence. This frame will be displayed while other frames are being loaded. Frame numbers are index based starting with 0. The first frame wouldbe index 0, the nth frame would be index n-1, etc.*/
- (void) setAnimatedMapStartFrame:(NSString*) name
					  frameNumber:(unsigned int) frameNumber;


/////////////////////////////////////////////////////////////////////////////////////////
//Marker map management

//Dynamic markers
/**
 Add a dynamic marker to a dynamic marker map.
 @param mapName Unique name of the dynamic marker map layer.
 @param dynamicMarker Object that fully describes the dynamic marker. Either uiImage or cachedImageName MUST be set.
 */
- (void) addDynamicMarkerToMap:(NSString*) mapName dynamicMarker:(MEDynamicMarker*) dynamicMarker;
- (void) removeDynamicMarkerFromMap:(NSString*) mapName markerName:(NSString*) markerName;
- (void) updateDynamicMarkerImage:(NSString*) mapName markerName:(NSString*) markerName uiImage:(UIImage*) uiImage anchorPoint:(CGPoint) anchorPoint offset:(CGPoint) offset compressTexture:(BOOL) compressTexture;
- (void) updateDynamicMarkerImage:(NSString *) mapName markerName:(NSString *) markerName cachedImageName:(NSString*) cachedImageName anchorPoint:(CGPoint) anchorPoint offset:(CGPoint) offset;
- (void) updateDynamicMarkerLocation:(NSString*) mapName markerName:(NSString*) markerName location:(CLLocationCoordinate2D) location animationDuration:(double) animationDuration;
- (void) updateDynamicMarkerRotation:(NSString*) mapName markerName:(NSString*) markerName rotation:(double) rotation animationDuration:(double) animationDuration;
- (void) setDynamicMarkerMapColorBar:(NSString*)mapName colorBar:(MEHeightColorBar*) colorBar;
- (void) hideDynamicMarker:(NSString*) mapName markerName:(NSString*) markerName;
- (void) showDynamicMarker:(NSString*) mapName markerName:(NSString*) markerName;


/**
 For dynamic and memory marker maps, adds a new marker to the marker map.
 @param mapName Unique name of the marker map layer.
 @param markerAnnotation Marker annotation that describes the marker.
 @warning This API has been deprecated and will be removed in a future release.
 */
- (void) addMarkerToMap:(NSString*)mapName
	   markerAnnotation:(MEMarkerAnnotation*)markerAnnotation;

/** For dynamic and memory marker maps, removes a marker from the map.
 @param mapName Unique name of the marker map layer.
 @param markerMetaData The meta data supplied with the marker when it was added.
 @warning This API has been deprecated and will be removed in a future release.
 */
- (void) removeMarkerFromMap:(NSString*) mapName
			  markerMetaData:(NSString*) markerMetaData;


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
 @warning This API has been deprecated and will be removed in a future release.
 */
- (void) updateMarkerLocationInMap:(NSString*) mapName
						  metaData:(NSString*) metaData
                       newLocation:(CLLocationCoordinate2D) newLocation;

/** For dynamic marker maps, updates the geographic position of the specified marker, optionally with animation.
 @param mapName Unique name of the marker map.
 @param metaData Unique ID of the marker to update.
 @param newLocation New geographic location of the marker.
 @param animationDuration The animation duration in seconds.
 @warning This API has been deprecated and will be removed in a future release.
 */
- (void) updateMarkerLocationInMap:(NSString*) mapName
						  metaData:(NSString*) metaData
                       newLocation:(CLLocationCoordinate2D) newLocation
				 animationDuration:(double) animationDuration;

/** For dynamic marker maps, update multiple attributes of a marker.
 @warning This API has been deprecated and will be removed in a future release.*/
- (void) updateMarkerInMap:(NSString*) mapName
				  metaData:(NSString*) metaData
			   newLocation:(CLLocationCoordinate2D) newLocation
			   newRotation:(double) newRotation
		 animationDuration:(double) animationDuration;

/** For dynamic marker maps, updates the rotation of the marker.
 @warning This API has been deprecated and will be removed in a future release.
 */
- (void) updateMarkerRotationInMap:(NSString*) mapName
						  metaData:(NSString*) metaData
                       newRotation:(double) newRotation;

/**
 For dynamic marker maps, updates the rotation of the marker.
 @warning This API has been deprecated and will be removed in a future release.
 */
- (void) updateMarkerRotationInMap:(NSString*) mapName
						  metaData:(NSString*) metaData
                       newRotation:(double) newRotation
				 animationDuration:(double) animationDuration;

/**
 Tells the rendering engine to stop drawing a marker. The marker will fade out. Presently, this is a one-way operation.
 @warning This API has been deprecated and will be removed in a future release.
 */
- (void) hideMarkerInMap:(NSString*) mapName
				metaData:(NSString*) metaData;


///////////////////////////////////////////////////////////////////////////////////////////
//Vector map management

/**Adds a polygon to a vector map.
 @param mapName The name of the vector map.
 @param points An array of NSValue objects that wrap CGPoints. The x,y values of the point represent longitude,latitude.
 @param style The style of the polygon.*/
- (void) addPolygonToVectorMap:(NSString*) mapName
                        points:(NSMutableArray*)points
                         style:(MEPolygonStyle*)style;

- (void) setStyleSetOnVectorMap:(NSString*) mapName
                  styleFileName:(NSString*) styleFileName
                   styleSetName:(NSString*) styleSetName;

/**Adds a style to a feature in a vector map.
 @param mapName The name of the vector map.
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

/**Adds a scale-dependent style to a feature in a vector map.
 @param mapName The name of the vector map.
 @param featureID The polygon feature of the map to apply the style to.
 @param scale the target scale for the style
 @param style The style to apply.*/
- (void) addPolygonStyleToVectorMap:(NSString*) mapName scale:(double) scale featureId:(unsigned int) featureID style:(MEPolygonStyle*)style;

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


/**Clears all dynamic lines and polygons from a vector map.
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

/**Called when a tile has been loaded through a virtual layer. Should only be called on the main thread.*/
- (void) tileLoadComplete:(METileProviderRequest*) meTileRequest;

/**Called by vector tile providers to supply geometry for a requested tile.*/
- (void) markerTileLoadComplete:(METileProviderRequest*) meTileRequest markerArray:(NSArray*) markerArray;

/**Called by vector tile providers to supply geometry for a requested tile.*/
- (void) vectorTileLoadComplete:(METileProviderRequest*) meTileRequest meGeometryGroup:(MEGeometryGroup*) meGeometryGroup;

/**Called by vector tile providers to supply binary geometry for a requested tile.*/
- (void) vectorTileLoadComplete:(METileProviderRequest*) meTileRequest tileData:(NSData*)tileData;

/**Returns whether or not the engine considers the tile represented by meTileRequest to be required to satisfy the current view for any non-animated virtual map. This call will dispatched to the main queue if it is not made on the main queue. If you need to know if an animated map tile request is still valid, please call animatedTileIsNeeded which does not dispatch to the main queue.*/
-(BOOL) tileIsNeeded:(METileProviderRequest*) meTileRequest;


-(BOOL) animatedTileIsNeeded:(METileProviderRequest*) meTileRequest;

/**Returns an array of METileRequest objects which represent the tiles currently needed by the mapping engine. You should only all this function on the main thread.*/
-(NSArray*) currentAnimatedMapTileRequests;

/**Tells the engine when the application receives a memory warning from the system.*/
- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application;

/**Forward this call form your AppDelegate so the mapping engine can manage internal state.*/
- (void)applicationWillResignActive:(UIApplication *)application;

/**Forward this call form your AppDelegate so the mapping engine can manage internal state.*/
- (void)applicationDidEnterBackground:(UIApplication *)application;

/**Forward this call form your AppDelegate so the mapping engine can manage internal state.*/
- (void)applicationWillEnterForeground:(UIApplication *)application;

/**Forward this call form your AppDelegate so the mapping engine can manage internal state.*/
- (void)applicationDidBecomeActive:(UIApplication *)application;

/**Forward this call form your AppDelegate so the mapping engine can manage internal state.*/
- (void)applicationWillTerminate:(UIApplication *)application;


- (void) setClippingPlaneValue:(CGFloat) newValue;

/**Adds an animated vector circle. This can be used for pulsating location beacons.*/
- (void) addAnimatedVectorCircle:(MEAnimatedVectorCircle*) animatedVectorCircle;

/**Update the position of an animated vector circle.*/
- (void) updateAnimatedVectorCircleLocation:(NSString*) name
								newLocation:(CLLocationCoordinate2D)newLocation
						  animationDuration:(CGFloat) animationDuration;

/**Removes an animated vector circle.*/
- (void) removeAnimatedVectorCircle:(NSString*) name;

/**Adds an animated reticle to mark locations.*/
- (void) addAnimatedVectorReticle:(MEAnimatedVectorReticle*) animatedVectorReticle;

/**Update the position of an animated reticle.*/
- (void) updateAnimatedVectorReticleLocation:(NSString*) name
								 newLocation:(CLLocationCoordinate2D)newLocation
						   animationDuration:(CGFloat) animationDuration;

/**Removes an animated reticle.*/
- (void) removeAnimatedVectorReticle:(NSString*) name;

/** Adds a map layer whose type and properties are specified by a MEMapInfo object.*/
- (void) addMapUsingMapInfo:(MEMapInfo*) meMapInfo;

/**Instructs the mapping engine to reload a map.
 @param mapName The name of the map to be refreshed.*/
- (void) refreshMap:(NSString*) mapName;

/**Instructs the mapping engine to reload the specified portion of a map.
 @param mapName The name of the map.
 @param lowerLeft The lower-left point of the region to refresh.
 @param upperRight The upper-right point of the region to refresh.
 */
- (void) refreshMapRegion:(NSString*) mapName
				lowerLeft:(CLLocationCoordinate2D) lowerLeft
			   upperRight:(CLLocationCoordinate2D) upperRight;

/** Adds an image that will stay cached until it is removed using removeCachedImage. Cached images are identified by their name and may be specified as the default tile for certain maps types or returned by tile providers that have no specific tile to return for a given tile request. Generally this should be a fully opaque 256x256 or 512x512 pixel image.
 @param uiImage A UIImage containing the image data.
 @param tileName The unique name of the tile.
 @param compressTexture Whether or not the image should be compressed to RGB565 format.*/
- (void) addCachedImage:(UIImage*) uiImage
			   withName:(NSString*) imageName
		compressTexture:(BOOL) compressTexture;

/** Adds a marker image that will stay cached until it is removed using removeCachedImage. The intent is for the image to be used as a marker image. Cached marker images are identified by their name and may be specified as the image to be used for a marker when a marker is added. To changed the cached image, call the function again with the same image name, but a different image.*/
- (void) addCachedMarkerImage:(UIImage*) uiImage
					 withName:(NSString*) imageName
			  compressTexture:(BOOL) compressTexture
nearestNeighborTextureSampling:(BOOL) nearestNeighborTextureSampling;


/** Removes a cached image or cached marker image that was previously added with the addCachedImage or addCachedMarkerImage function.*/
-(void) removeCachedImage:(NSString*) tileName;


/** Returns an angle relative to the verticle edge of the view that represents the rotation you would apply to a screen-aligned object so that it points to the given heading. You would use this function, for example, if you wanted to display an 2D arrow that points in at heading. If you desire for an object to do this and always be up to date and smoothly animated, you should use a marker layer with a marker whose rotation type is kMarkerRotationTrueNorthAligned, then the mapping engine will manage the rotation of the object.*/
-(CGFloat) screenRotationForLocation:(CLLocationCoordinate2D) location
						 withHeading:(CGFloat) heading;


/** Returns an angle relative to the verticle edge of the view that represents the rotation you would apply to a screen-aligned object so that it points to the given heading releative to the current geographic point at the center of the view. You would use this function, for example, if you wanted to display an 2D arrow that points in at heading. If you desire for an object to do this and always be up to date and smoothly animated, you should use a marker layer with a marker whose rotation type is kMarkerRotationTrueNorthAligned, then the mapping engine will manage the rotation of the object.*/
-(CGFloat) screenRotationForMapCenterWithHeading:(double) heading;

/** Returns an array of MEMarker objects for markers that are visible for a given marker map layer. This function should only be called form the main thread, not from a background thread.
 @param mapName Name of currently loaded marker layer.*/
- (NSArray*) getVisibleMarkers:(NSString*) mapName;

/** Stops and invalidates the CADisplayLink timer that is used to drive updates. Provided for applications that desire to mananage timing and updates themselves. When stopped, the mapping engine will no longer update / draw and your application will be responsible for calling the updateWithTimestamp function in order to ensure updates occur.
 */
- (void) stopDisplayLink;

/** Creates and starts a CADisplayLink  timer that is used to drive updates. This function is provided for applications that desire to manage timing and updates themsevles. When started, you should discontinue calling updateWithTimestamp.
 */
- (void) startDisplayLink;

/** This function is provided for applications that desire to manage timing and updates themselves. If you are not managing your own CADisplayLink timer, there is no need to ever call this function. If you desire to use this function, you should first call stopDisplayLink, then create your own CADisplayLink timer, start it, and when it fires call this function passing the CADisplayLink timestamp value each time you want the mapping engine to update and draw.
 @param timestamp The timestamp value of the CADisplayLink timer you are managing.
 */
- (void) updateWithTimestamp:(CFTimeInterval) timestamp;

/**Used to notify the view controller that a user interaction (panning/zoomin) or code-based panning/zooming has occured. This is primarily for green-mode support so that gesture recognizers can notify the view controller to increase the frame rate in response to user touches. This function may be made private in a future release.*/
- (void) greenModeFulleThrottle;

/**Activate your license and disable the BA3 watermark.
 */
- (void) setLicenseKey:(NSString*) licenseKey;

/**Returns the version tag for this build of Altus.*/
+ (NSString*) getVersionTag;
    
/**	*/
+ (NSString*) getVersionHash;
    
@end
