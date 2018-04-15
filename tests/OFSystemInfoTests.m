/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017,
 *               2018
 *   Jonathan Schleifer <js@heap.zone>
 *
 * All rights reserved.
 *
 * This file is part of ObjFW. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE.QPL included in
 * the packaging of this file.
 *
 * Alternatively, it may be distributed under the terms of the GNU General
 * Public License, either version 2 or 3, which can be found in the file
 * LICENSE.GPLv2 or LICENSE.GPLv3 respectively included in the packaging of this
 * file.
 */

#include "config.h"

#import "OFSystemInfo.h"
#import "OFAutoreleasePool.h"

#import "TestsAppDelegate.h"

static OFString *module = @"OFSystemInfo";

@implementation TestsAppDelegate (OFSystemInfoTests)
- (void)systemInfoTests
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];

	PRINT(GREEN, @"Page size: %zd", [OFSystemInfo pageSize]);

	PRINT(GREEN, @"Number of CPUs: %zd", [OFSystemInfo numberOfCPUs]);

	PRINT(GREEN, @"Operating system name: %@",
	    [OFSystemInfo operatingSystemName]);

	PRINT(GREEN, @"Operating system version: %@",
	    [OFSystemInfo operatingSystemVersion]);

#ifdef OF_HAVE_FILES
	PRINT(GREEN, @"User data path: %@", [OFSystemInfo userDataPath]);

	PRINT(GREEN, @"User config path: %@", [OFSystemInfo userDataPath]);
#endif

	PRINT(GREEN, @"CPU vendor: %@", [OFSystemInfo CPUVendor]);

#if defined(OF_X86_64) || defined(OF_X86)
	PRINT(GREEN, @"Supports MMX: %d", [OFSystemInfo supportsMMX]);

	PRINT(GREEN, @"Supports SSE: %d", [OFSystemInfo supportsSSE]);

	PRINT(GREEN, @"Supports SSE2: %d", [OFSystemInfo supportsSSE2]);

	PRINT(GREEN, @"Supports SSE3: %d", [OFSystemInfo supportsSSE3]);

	PRINT(GREEN, @"Supports SSSE3: %d", [OFSystemInfo supportsSSSE3]);

	PRINT(GREEN, @"Supports SSE4.1: %d", [OFSystemInfo supportsSSE41]);

	PRINT(GREEN, @"Supports SSE4.2: %d", [OFSystemInfo supportsSSE42]);

	PRINT(GREEN, @"Supports AVX: %d", [OFSystemInfo supportsAVX]);

	PRINT(GREEN, @"Supports AVX2: %d", [OFSystemInfo supportsAVX2]);
#endif

#ifdef OF_POWERPC
	PRINT(GREEN, @"Supports AltiVec: %d", [OFSystemInfo supportsAltiVec]);
#endif

	[pool drain];
}
@end
