//  Copyright (c) 2012 BA3, LLC. All rights reserved.

#pragma once

#if DEBUG
#define MERelease(x) [x release]
#else
#define MERelease(x) [x release], x = nil
#endif
