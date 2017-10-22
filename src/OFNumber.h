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

#ifndef __STDC_LIMIT_MACROS
# define __STDC_LIMIT_MACROS
#endif
#ifndef __STDC_CONSTANT_MACROS
# define __STDC_CONSTANT_MACROS
#endif

#include "objfw-defs.h"

#ifdef OF_HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif

#import "OFObject.h"
#import "OFSerialization.h"
#import "OFJSONRepresentation.h"
#import "OFMessagePackRepresentation.h"

OF_ASSUME_NONNULL_BEGIN

/*! @file */

/*!
 * @brief The C type of a number stored in an OFNumber.
 */
typedef enum {
	/*! bool */
	OF_NUMBER_TYPE_BOOL		= 0x01,
	/*! unsigned char */
	OF_NUMBER_TYPE_UCHAR		= 0x02,
	/*! unsigned short */
	OF_NUMBER_TYPE_USHORT		= 0x03,
	/*! unsigned int */
	OF_NUMBER_TYPE_UINT		= 0x04,
	/*! unsigned long */
	OF_NUMBER_TYPE_ULONG		= 0x05,
	/*! unsigned long long */
	OF_NUMBER_TYPE_ULONGLONG	= 0x06,
	/*! size_t */
	OF_NUMBER_TYPE_SIZE		= 0x07,
	/*! uint8_t */
	OF_NUMBER_TYPE_UINT8		= 0x08,
	/*! uint16_t */
	OF_NUMBER_TYPE_UINT16		= 0x09,
	/*! uint32_t */
	OF_NUMBER_TYPE_UINT32		= 0x0A,
	/*! uint64_t */
	OF_NUMBER_TYPE_UINT64		= 0x0B,
	/*! uintptr_t */
	OF_NUMBER_TYPE_UINTPTR		= 0x0C,
	/*! uintmax_t */
	OF_NUMBER_TYPE_UINTMAX		= 0x0D,
	OF_NUMBER_TYPE_SIGNED		= 0x10,
	/*! signed char */
	OF_NUMBER_TYPE_CHAR		= OF_NUMBER_TYPE_UCHAR |
					      OF_NUMBER_TYPE_SIGNED,
	/*! signed short */
	OF_NUMBER_TYPE_SHORT		= OF_NUMBER_TYPE_USHORT |
					      OF_NUMBER_TYPE_SIGNED,
	/*! signed int */
	OF_NUMBER_TYPE_INT		= OF_NUMBER_TYPE_UINT |
					      OF_NUMBER_TYPE_SIGNED,
	/*! signed long */
	OF_NUMBER_TYPE_LONG		= OF_NUMBER_TYPE_ULONG |
					      OF_NUMBER_TYPE_SIGNED,
	/*! signed long long */
	OF_NUMBER_TYPE_LONGLONG		= OF_NUMBER_TYPE_ULONGLONG |
					      OF_NUMBER_TYPE_SIGNED,
	/*! int8_t */
	OF_NUMBER_TYPE_INT8		= OF_NUMBER_TYPE_UINT8 |
					      OF_NUMBER_TYPE_SIGNED,
	/*! int16_t */
	OF_NUMBER_TYPE_INT16		= OF_NUMBER_TYPE_UINT16 |
					      OF_NUMBER_TYPE_SIGNED,
	/*! int32_t */
	OF_NUMBER_TYPE_INT32		= OF_NUMBER_TYPE_UINT32 |
					      OF_NUMBER_TYPE_SIGNED,
	/*! int64_t */
	OF_NUMBER_TYPE_INT64		= OF_NUMBER_TYPE_UINT64 |
					      OF_NUMBER_TYPE_SIGNED,
	/*! ssize_t */
	OF_NUMBER_TYPE_SSIZE		= OF_NUMBER_TYPE_SIZE |
					      OF_NUMBER_TYPE_SIGNED,
	/*! intmax_t */
	OF_NUMBER_TYPE_INTMAX		= OF_NUMBER_TYPE_UINTMAX |
					      OF_NUMBER_TYPE_SIGNED,
	/*! ptrdiff_t */
	OF_NUMBER_TYPE_PTRDIFF		= 0x0E | OF_NUMBER_TYPE_SIGNED,
	/*! intptr_t */
	OF_NUMBER_TYPE_INTPTR		= 0x0F | OF_NUMBER_TYPE_SIGNED,
	/*! float */
	OF_NUMBER_TYPE_FLOAT		= 0x20,
	/*! double */
	OF_NUMBER_TYPE_DOUBLE		= 0x40 | OF_NUMBER_TYPE_FLOAT
} of_number_type_t;

/*!
 * @class OFNumber OFNumber.h ObjFW/OFNumber.h
 *
 * @brief Provides a way to store a number in an object.
 */
@interface OFNumber: OFObject <OFCopying, OFComparing, OFSerialization,
    OFJSONRepresentation, OFMessagePackRepresentation>
{
	union of_number_value {
		bool		   bool_;
		signed char	   sChar;
		signed short	   sShort;
		signed int	   sInt;
		signed long	   sLong;
		signed long long   sLongLong;
		unsigned char	   uChar;
		unsigned short	   uShort;
		unsigned int	   uInt;
		unsigned long	   uLong;
		unsigned long long uLongLong;
		int8_t		   int8;
		int16_t		   int16;
		int32_t		   int32;
		int64_t		   int64;
		uint8_t		   uInt8;
		uint16_t	   uInt16;
		uint32_t	   uInt32;
		uint64_t	   uInt64;
		size_t		   size;
		ssize_t		   sSize;
		intmax_t	   intMax;
		uintmax_t	   uIntMax;
		ptrdiff_t	   ptrDiff;
		intptr_t	   intPtr;
		uintptr_t	   uIntPtr;
		float		   float_;
		double		   double_;
	} _value;
	of_number_type_t _type;
}

/*!
 * The type of the number.
 */
@property (readonly, nonatomic) of_number_type_t type;

/*!
 * @brief Creates a new OFNumber with the specified bool.
 *
 * @param bool_ A bool which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithBool: (bool)bool_;

/*!
 * @brief Creates a new OFNumber with the specified signed char.
 *
 * @param sChar A signed char which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithChar: (signed char)sChar;

/*!
 * @brief Creates a new OFNumber with the specified signed short.
 *
 * @param sShort A signed short which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithShort: (signed short)sShort;

/*!
 * @brief Creates a new OFNumber with the specified signed int.
 *
 * @param sInt A signed int which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithInt: (signed int)sInt;

/*!
 * @brief Creates a new OFNumber with the specified signed long.
 *
 * @param sLong A signed long which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithLong: (signed long)sLong;

/*!
 * @brief Creates a new OFNumber with the specified signed long long.
 *
 * @param sLongLong A signed long long which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithLongLong: (signed long long)sLongLong;

/*!
 * @brief Creates a new OFNumber with the specified unsigned char.
 *
 * @param uChar An unsigned char which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithUnsignedChar: (unsigned char)uChar;

/*!
 * @brief Creates a new OFNumber with the specified unsigned short.
 *
 * @param uShort An unsigned short which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithUnsignedShort: (unsigned short)uShort;

/*!
 * @brief Creates a new OFNumber with the specified unsigned int.
 *
 * @param uInt An unsigned int which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithUnsignedInt: (unsigned int)uInt;

/*!
 * @brief Creates a new OFNumber with the specified unsigned long.
 *
 * @param uLong An unsigned long which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithUnsignedLong: (unsigned long)uLong;

/*!
 * @brief Creates a new OFNumber with the specified unsigned long long.
 *
 * @param uLongLong An unsigned long long which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithUnsignedLongLong: (unsigned long long)uLongLong;

/*!
 * @brief Creates a new OFNumber with the specified int8_t.
 *
 * @param int8 An int8_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithInt8: (int8_t)int8;

/*!
 * @brief Creates a new OFNumber with the specified int16_t.
 *
 * @param int16 An int16_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithInt16: (int16_t)int16;

/*!
 * @brief Creates a new OFNumber with the specified int32_t.
 *
 * @param int32 An int32_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithInt32: (int32_t)int32;

/*!
 * @brief Creates a new OFNumber with the specified int64_t.
 *
 * @param int64 An int64_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithInt64: (int64_t)int64;

/*!
 * @brief Creates a new OFNumber with the specified uint8_t.
 *
 * @param uInt8 A uint8_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithUInt8: (uint8_t)uInt8;

/*!
 * @brief Creates a new OFNumber with the specified uint16_t.
 *
 * @param uInt16 A uint16_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithUInt16: (uint16_t)uInt16;

/*!
 * @brief Creates a new OFNumber with the specified uint32_t.
 *
 * @param uInt32 A uint32_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithUInt32: (uint32_t)uInt32;

/*!
 * @brief Creates a new OFNumber with the specified uint64_t.
 *
 * @param uInt64 A uint64_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithUInt64: (uint64_t)uInt64;

/*!
 * @brief Creates a new OFNumber with the specified size_t.
 *
 * @param size A size_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithSize: (size_t)size;

/*!
 * @brief Creates a new OFNumber with the specified ssize_t.
 *
 * @param sSize An ssize_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithSSize: (ssize_t)sSize;

/*!
 * @brief Creates a new OFNumber with the specified intmax_t.
 *
 * @param intMax An intmax_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithIntMax: (intmax_t)intMax;

/*!
 * @brief Creates a new OFNumber with the specified uintmax_t.
 *
 * @param uIntMax A uintmax_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithUIntMax: (uintmax_t)uIntMax;

/*!
 * @brief Creates a new OFNumber with the specified ptrdiff_t.
 *
 * @param ptrDiff A ptrdiff_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithPtrDiff: (ptrdiff_t)ptrDiff;

/*!
 * @brief Creates a new OFNumber with the specified intptr_t.
 *
 * @param intPtr An intptr_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithIntPtr: (intptr_t)intPtr;

/*!
 * @brief Creates a new OFNumber with the specified uintptr_t.
 *
 * @param uIntPtr A uintptr_t which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithUIntPtr: (uintptr_t)uIntPtr;

/*!
 * @brief Creates a new OFNumber with the specified float.
 *
 * @param float_ A float which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithFloat: (float)float_;

/*!
 * @brief Creates a new OFNumber with the specified double.
 *
 * @param double_ A double which the OFNumber should contain
 * @return A new autoreleased OFNumber
 */
+ (instancetype)numberWithDouble: (double)double_;

- (instancetype)init OF_UNAVAILABLE;

/*!
 * @brief Initializes an already allocated OFNumber with the specified bool.
 *
 * @param bool_ A bool which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithBool: (bool)bool_;

/*!
 * @brief Initializes an already allocated OFNumber with the specified signed
 *	  char.
 *
 * @param sChar A signed char which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithChar: (signed char)sChar;

/*!
 * @brief Initializes an already allocated OFNumber with the specified signed
 *	  short.
 *
 * @param sShort A signed short which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithShort: (signed short)sShort;

/*!
 * @brief Initializes an already allocated OFNumber with the specified signed
 *	  int.
 *
 * @param sInt A signed int which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithInt: (signed int)sInt;

/*!
 * @brief Initializes an already allocated OFNumber with the specified signed
 *	  long.
 *
 * @param sLong A signed long which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithLong: (signed long)sLong;

/*!
 * @brief Initializes an already allocated OFNumber with the specified signed
 *	  long long.
 *
 * @param sLongLong A signed long long which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithLongLong: (signed long long)sLongLong;

/*!
 * @brief Initializes an already allocated OFNumber with the specified unsigned
 *	  char.
 *
 * @param uChar An unsigned char which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithUnsignedChar: (unsigned char)uChar;

/*!
 * @brief Initializes an already allocated OFNumber with the specified unsigned
 *	  short.
 *
 * @param uShort An unsigned short which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithUnsignedShort: (unsigned short)uShort;

/*!
 * @brief Initializes an already allocated OFNumber with the specified unsigned
 *	  int.
 *
 * @param uInt An unsigned int which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithUnsignedInt: (unsigned int)uInt;

/*!
 * @brief Initializes an already allocated OFNumber with the specified unsigned
 *	  long.
 *
 * @param uLong An unsigned long which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithUnsignedLong: (unsigned long)uLong;

/*!
 * @brief Initializes an already allocated OFNumber with the specified unsigned
 *	  long long.
 *
 * @param uLongLong An unsigned long long which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithUnsignedLongLong: (unsigned long long)uLongLong;

/*!
 * @brief Initializes an already allocated OFNumber with the specified int8_t.
 *
 * @param int8 An int8_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithInt8: (int8_t)int8;

/*!
 * @brief Initializes an already allocated OFNumber with the specified int16_t.
 *
 * @param int16 An int16_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithInt16: (int16_t)int16;

/*!
 * @brief Initializes an already allocated OFNumber with the specified int32_t.
 *
 * @param int32 An int32_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithInt32: (int32_t)int32;

/*!
 * @brief Initializes an already allocated OFNumber with the specified int64_t.
 *
 * @param int64 An int64_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithInt64: (int64_t)int64;

/*!
 * @brief Initializes an already allocated OFNumber with the specified uint8_t.
 *
 * @param uInt8 A uint8_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithUInt8: (uint8_t)uInt8;

/*!
 * @brief Initializes an already allocated OFNumber with the specified uint16_t.
 *
 * @param uInt16 A uint16_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithUInt16: (uint16_t)uInt16;

/*!
 * @brief Initializes an already allocated OFNumber with the specified uint32_t.
 *
 * @param uInt32 A uint32_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithUInt32: (uint32_t)uInt32;

/*!
 * @brief Initializes an already allocated OFNumber with the specified uint64_t.
 *
 * @param uInt64 A uint64_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithUInt64: (uint64_t)uInt64;

/*!
 * @brief Initializes an already allocated OFNumber with the specified size_t.
 *
 * @param size A size_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithSize: (size_t)size;

/*!
 * @brief Initializes an already allocated OFNumber with the specified ssize_t.
 *
 * @param sSize An ssize_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithSSize: (ssize_t)sSize;

/*!
 * @brief Initializes an already allocated OFNumber with the specified intmax_t.
 *
 * @param intMax An intmax_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithIntMax: (intmax_t)intMax;

/*!
 * @brief Initializes an already allocated OFNumber with the specified
 *	  uintmax_t.
 *
 * @param uIntMax A uintmax_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithUIntMax: (uintmax_t)uIntMax;

/*!
 * @brief Initializes an already allocated OFNumber with the specified
 *	  ptrdiff_t.
 *
 * @param ptrDiff A ptrdiff_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithPtrDiff: (ptrdiff_t)ptrDiff;

/*!
 * @brief Initializes an already allocated OFNumber with the specified intptr_t.
 *
 * @param intPtr An intptr_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithIntPtr: (intptr_t)intPtr;

/*!
 * @brief Initializes an already allocated OFNumber with the specified
 *	  uintptr_t.
 *
 * @param uIntPtr A uintptr_t which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithUIntPtr: (uintptr_t)uIntPtr;

/*!
 * @brief Initializes an already allocated OFNumber with the specified float.
 *
 * @param float_ A float which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithFloat: (float)float_;

/*!
 * @brief Initializes an already allocated OFNumber with the specified double.
 *
 * @param double_ A double which the OFNumber should contain
 * @return An initialized OFNumber
 */
- (instancetype)initWithDouble: (double)double_;

/*!
 * @brief Returns the OFNumber as a bool.
 *
 * @return The OFNumber as a bool
 */
- (bool)boolValue;

/*!
 * @brief Returns the OFNumber as a signed char.
 *
 * @return The OFNumber as a signed char
 */
- (signed char)charValue;

/*!
 * @brief Returns the OFNumber as a signed short.
 *
 * @return The OFNumber as a signed short
 */
- (signed short)shortValue;

/*!
 * @brief Returns the OFNumber as a signed int.
 *
 * @return The OFNumber as a signed int
 */
- (signed int)intValue;

/*!
 * @brief Returns the OFNumber as a signed long.
 *
 * @return The OFNumber as a signed long
 */
- (signed long)longValue;

/*!
 * @brief Returns the OFNumber as a signed long long.
 *
 * @return The OFNumber as a signed long long
 */
- (signed long long)longLongValue;

/*!
 * @brief Returns the OFNumber as an unsigned char.
 *
 * @return The OFNumber as an unsigned char
 */
- (unsigned char)unsignedCharValue;

/*!
 * @brief Returns the OFNumber as an unsigned short.
 *
 * @return The OFNumber as an unsigned short
 */
- (unsigned short)unsignedShortValue;

/*!
 * @brief Returns the OFNumber as an unsigned int.
 *
 * @return The OFNumber as an unsigned int
 */
- (unsigned int)unsignedIntValue;

/*!
 * @brief Returns the OFNumber as an unsigned long.
 *
 * @return The OFNumber as an unsigned long
 */
- (unsigned long)unsignedLongValue;

/*!
 * @brief Returns the OFNumber as an unsigned long long.
 *
 * @return The OFNumber as an unsigned long long
 */
- (unsigned long long)unsignedLongLongValue;

/*!
 * @brief Returns the OFNumber as an int8_t.
 *
 * @return The OFNumber as an int8_t
 */
- (int8_t)int8Value;

/*!
 * @brief Returns the OFNumber as an int16_t.
 *
 * @return The OFNumber as an int16_t
 */
- (int16_t)int16Value;

/*!
 * @brief Returns the OFNumber as an int32_t.
 *
 * @return The OFNumber as an int32_t
 */
- (int32_t)int32Value;

/*!
 * @brief Returns the OFNumber as an int64_t.
 *
 * @return The OFNumber as an int64_t
 */
- (int64_t)int64Value;

/*!
 * @brief Returns the OFNumber as a uint8_t.
 *
 * @return The OFNumber as a uint8_t
 */
- (uint8_t)uInt8Value;

/*!
 * @brief Returns the OFNumber as a uint16_t.
 *
 * @return The OFNumber as a uint16_t
 */
- (uint16_t)uInt16Value;

/*!
 * @brief Returns the OFNumber as a uint32_t.
 *
 * @return The OFNumber as a uint32_t
 */
- (uint32_t)uInt32Value;

/*!
 * @brief Returns the OFNumber as a uint64_t.
 *
 * @return The OFNumber as a uint64_t
 */
- (uint64_t)uInt64Value;

/*!
 * @brief Returns the OFNumber as a size_t.
 *
 * @return The OFNumber as a size_t
 */
- (size_t)sizeValue;

/*!
 * @brief Returns the OFNumber as an ssize_t.
 *
 * @return The OFNumber as an ssize_t
 */
- (ssize_t)sSizeValue;

/*!
 * @brief Returns the OFNumber as an intmax_t.
 *
 * @return The OFNumber as an intmax_t
 */
- (intmax_t)intMaxValue;

/*!
 * @brief Returns the OFNumber as a uintmax_t.
 *
 * @return The OFNumber as a uintmax_t
 */
- (uintmax_t)uIntMaxValue;

/*!
 * @brief Returns the OFNumber as a ptrdiff_t.
 *
 * @return The OFNumber as a ptrdiff_t
 */
- (ptrdiff_t)ptrDiffValue;

/*!
 * @brief Returns the OFNumber as an intptr_t.
 *
 * @return The OFNumber as an intptr_t
 */
- (intptr_t)intPtrValue;

/*!
 * @brief Returns the OFNumber as a uintptr_t.
 *
 * @return The OFNumber as a uintptr_t
 */
- (uintptr_t)uIntPtrValue;

/*!
 * @brief Returns the OFNumber as a float.
 *
 * @return The OFNumber as a float
 */
- (float)floatValue;

/*!
 * @brief Returns the OFNumber as a double.
 *
 * @return The OFNumber as a double
 */
- (double)doubleValue;
@end

OF_ASSUME_NONNULL_END

#if !defined(NSINTEGER_DEFINED) && !__has_feature(modules)
/* Required for number literals to work */
@compatibility_alias NSNumber OFNumber;
#endif
