/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017
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

#import "OFException.h"

#ifndef OF_HAVE_SOCKETS
# error No sockets available!
#endif

OF_ASSUME_NONNULL_BEGIN

/*!
 * @class OFAddressTranslationFailedException \
 *	  OFAddressTranslationFailedException.h \
 *	  ObjFW/OFAddressTranslationFailedException.h
 *
 * @brief An exception indicating the translation of an address failed.
 */
@interface OFAddressTranslationFailedException: OFException
{
	OFString *_host;
	int _error;
}

/*!
 * @brief The host for which the address translation was requested.
 */
@property OF_NULLABLE_PROPERTY (readonly, nonatomic) OFString *host;

/*!
 * @brief Creates a new, autoreleased address translation failed exception.
 *
 * @param host The host for which translation was requested
 * @return A new, autoreleased address translation failed exception
 */
+ (instancetype)exceptionWithHost: (nullable OFString *)host;

+ (instancetype)exceptionWithError: (int)error;
+ (instancetype)exceptionWithHost: (nullable OFString *)host
			    error: (int)error;

/*!
 * @brief Initializes an already allocated address translation failed exception.
 *
 * @param host The host for which translation was requested
 * @return An initialized address translation failed exception
 */
- (instancetype)initWithHost: (nullable OFString *)host;

- (instancetype)initWithError: (int)error;
- (instancetype)initWithHost: (nullable OFString *)host
		       error: (int)error OF_DESIGNATED_INITIALIZER;
@end

OF_ASSUME_NONNULL_END
