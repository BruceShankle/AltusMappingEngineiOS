//  Copyright (c) 2013 BA3, LLC. All rights reserved.
#pragma once
//Enum for conveying image type in database
typedef enum {
	IMAGEDATATYPE_PNG,
	IMAGEDATATYPE_JPG
} ImageDataType;

/**Used to indicate the geometry layout of an MEAnimatedVectorReticle.*/
typedef enum {
	kAnimatedVectorReticleInwardPointingWithCircle,
	kAnimatedVectorReticleInwardPointingWithoutCircle,
	kAnimatedVectorReticleOutwardPointingWithCircle,
	kAnimatedVectorReticleOutwardPointingWithoutCircle
} MEAnimatedVectorReticleStyle;