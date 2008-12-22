/*
 * Copyright (c) 2008
 *   Jonathan Schleifer <js@webkeks.org>
 *
 * All rights reserved.
 *
 * This file is part of libobjfw. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE included in
 * the packaging of this file.
 */

#import "config.h"

#import <stdio.h>
#import <string.h>

#import "OFString.h"
#import "OFExceptions.h"

#ifndef _WIN32
#define ZD "%zd"
#else
#define ZD "%u"
#endif

#define NUM_TESTS 10
#define SUCCESS								\
	printf("\r\033[1;%dmTests successful: " ZD "/%d\033[0m",	\
	    (i == NUM_TESTS - 1 ? 32 : 33), i + 1, NUM_TESTS);		\
	fflush(stdout);
#define FAIL								\
	printf("\r\033[K\033[1;31mTest " ZD "/%d failed!\033[m\n",	\
	    i + 1, NUM_TESTS);						\
	return 1;
#define CHECK(cond)							\
	if (cond) {							\
		SUCCESS							\
	} else {							\
		FAIL							\
	}								\
	i++;
#define CHECK_EXCEPT(code, exception)					\
	@try {								\
		code;							\
		FAIL							\
	} @catch (exception *e) {					\
		SUCCESS							\
	}								\
	i++;

int
main()
{
	size_t i = 0;

	OFString *s1 = [OFString newFromCString: "test"];
	OFString *s2 = [OFString newFromCString: ""];
	OFString *s3;
	OFString *s4 = [OFString new];

	s3 = [s1 clone];

	CHECK(![s1 compareTo: s3])

	[s2 appendCString: "123"];
	[s4 setTo: s2];

	CHECK(![s2 compareTo: s4])
	CHECK(!strcmp([[s1 append: s2] cString], "test123"))
	CHECK(strlen([s1 cString]) == [s1 length] && [s1 length] == 7)
	CHECK(!strcmp([[s1 reverse] cString], "321tset"))
	CHECK(!strcmp([[s1 upper] cString], "321TSET"))
	CHECK(!strcmp([[s1 lower] cString], "321tset"))

	/* Also clears all the memory of the returned C strings */
	[s1 free];
	[s2 free];
	[s3 free];
	[s4 free];

	/* UTF-8 tests */
	CHECK_EXCEPT(s1 = [OFString newFromCString: "\xE0\x80"],
	    OFInvalidEncodingException)
	CHECK_EXCEPT(s1 = [OFString newFromCString: "\xF0\x80\x80\xC0"],
	    OFInvalidEncodingException)

	s1 = [OFString newFromCString: "äöü€𝄞"];
	CHECK(!strcmp([[s1 reverse] cString], "𝄞€üöä"))

	puts("");

	return 0;
}
