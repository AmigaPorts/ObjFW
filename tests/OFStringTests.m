/*
 * Copyright (c) 2008, 2009, 2010, 2011
 *   Jonathan Schleifer <js@webkeks.org>
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

#include <stdlib.h>
#include <string.h>
#include <math.h>

#import "OFString.h"
#import "OFArray.h"
#import "OFURL.h"
#import "OFAutoreleasePool.h"

#import "OFInvalidArgumentException.h"
#import "OFInvalidEncodingException.h"
#import "OFInvalidFormatException.h"
#import "OFOutOfRangeException.h"

#import "TestsAppDelegate.h"

static OFString *module = @"OFString";
static OFString* whitespace[] = {
	@" \r \t\n\t \tasd  \t \t\t\r\n",
	@" \t\t  \t\t  \t \t"
};
static of_unichar_t ucstr[] = { 'f', 0xF6, 0xF6, 'b', 0xE4, 'r', 0 };

@interface EntityHandler: OFObject <OFStringXMLUnescapingDelegate>
@end

@implementation EntityHandler
-	   (OFString*)string: (OFString*)string
  containsUnknownEntityNamed: (OFString*)entity
{
	if ([entity isEqual: @"foo"])
		return @"bar";

	return nil;
}
@end

@implementation TestsAppDelegate (OFStringTests)
- (void)stringTests
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	OFMutableString *s[3];
	OFArray *a;
	int i;
	of_unichar_t *ua;
	EntityHandler *h;

	s[0] = [OFMutableString stringWithString: @"täs€"];
	s[1] = [OFMutableString string];
	s[2] = [[s[0] copy] autorelease];

	TEST(@"-[isEqual:]", [s[0] isEqual: s[2]] &&
	    ![s[0] isEqual: [[[OFObject alloc] init] autorelease]])

	TEST(@"-[compare:]", [s[0] compare: s[2]] == OF_ORDERED_SAME &&
	    [s[0] compare: @""] != OF_ORDERED_SAME &&
	    [@"" compare: @"a"] == OF_ORDERED_ASCENDING &&
	    [@"a" compare: @"b"] == OF_ORDERED_ASCENDING &&
	    [@"cd" compare: @"bc"] == OF_ORDERED_DESCENDING &&
	    [@"ä" compare: @"ö"] == OF_ORDERED_ASCENDING &&
	    [@"€" compare: @"ß"] == OF_ORDERED_DESCENDING &&
	    [@"aa" compare: @"z"] == OF_ORDERED_ASCENDING)

	TEST(@"-[caseInsensitiveCompare:]",
	    [@"a" caseInsensitiveCompare: @"A"] == OF_ORDERED_SAME &&
	    [@"Ä" caseInsensitiveCompare: @"ä"] == OF_ORDERED_SAME &&
	    [@"я" caseInsensitiveCompare: @"Я"] == OF_ORDERED_SAME &&
	    [@"€" caseInsensitiveCompare: @"ß"] == OF_ORDERED_DESCENDING &&
	    [@"ß" caseInsensitiveCompare: @"→"] == OF_ORDERED_ASCENDING &&
	    [@"AA" caseInsensitiveCompare: @"z"] == OF_ORDERED_ASCENDING &&
	    [[OFString stringWithCString: "ABC"] caseInsensitiveCompare:
	    [OFString stringWithCString: "AbD"]] == [@"abc" compare: @"abd"])

	TEST(@"-[hash] is the same if -[isEqual:] is YES",
	    [s[0] hash] == [s[2] hash])

	TEST(@"-[description]", [[s[0] description] isEqual: s[0]])

	TEST(@"-[appendString:] and -[appendCString:]",
	    R([s[1] appendCString: "1𝄞"]) && R([s[1] appendString: @"3"]) &&
	    R([s[0] appendString: s[1]]) && [s[0] isEqual: @"täs€1𝄞3"])

	TEST(@"-[length]", [s[0] length] == 7)
	TEST(@"-[cStringLength]", [s[0] cStringLength] == 13)
	TEST(@"-[hash]", [s[0] hash] == 0xD576830E)

	TEST(@"-[characterAtIndex:]", [s[0] characterAtIndex: 0] == 't' &&
	    [s[0] characterAtIndex: 1] == 0xE4 &&
	    [s[0] characterAtIndex: 3] == 0x20AC &&
	    [s[0] characterAtIndex: 5] == 0x1D11E)

	EXPECT_EXCEPTION(@"Detect out of range in -[characterAtIndex:]",
	    OFOutOfRangeException, [s[0] characterAtIndex: 7])

	TEST(@"-[reverse]", R([s[0] reverse]) && [s[0] isEqual: @"3𝄞1€sät"])

	s[1] = [OFMutableString stringWithString: @"abc"];

	TEST(@"-[upper]", R([s[0] upper]) && [s[0] isEqual: @"3𝄞1€SÄT"] &&
	    R([s[1] upper]) && [s[1] isEqual: @"ABC"])

	TEST(@"-[lower]", R([s[0] lower]) && [s[0] isEqual: @"3𝄞1€sät"] &&
	    R([s[1] lower]) && [s[1] isEqual: @"abc"])

	TEST(@"+[stringWithCString:length:]",
	    (s[0] = [OFMutableString stringWithCString: "\xEF\xBB\xBF" "foobar"
					      length: 6]) &&
	    [s[0] isEqual: @"foo"])

	TEST(@"+[stringWithContentsOfFile:encoding]", (s[1] = [OFString
	    stringWithContentsOfFile: @"testfile.txt"
			    encoding: OF_STRING_ENCODING_ISO_8859_1]) &&
	    [s[1] isEqual: @"testäöü"])

	TEST(@"+[stringWithContentsOfURL:encoding]", (s[1] = [OFString
	    stringWithContentsOfURL: [OFURL URLWithString:
					 @"file://testfile.txt"]
			   encoding: OF_STRING_ENCODING_ISO_8859_1]) &&
	    [s[1] isEqual: @"testäöü"])

	TEST(@"-[appendCStringWithLength:]",
	    R([s[0] appendCString: "foo\xEF\xBB\xBF" "barqux" + 3
		       withLength: 6]) && [s[0] isEqual: @"foobar"])

	EXPECT_EXCEPTION(@"Detection of invalid UTF-8 encoding #1",
	    OFInvalidEncodingException,
	    [OFString stringWithCString: "\xE0\x80"])
	EXPECT_EXCEPTION(@"Detection of invalid UTF-8 encoding #2",
	    OFInvalidEncodingException,
	    [OFString stringWithCString: "\xF0\x80\x80\xC0"])

	TEST(@"-[reverse] on UTF-8 strings",
	    (s[0] = [OFMutableString stringWithCString: "äöü€𝄞"]) &&
	    R([s[0] reverse]) && [s[0] isEqual: @"𝄞€üöä"])

	TEST(@"Conversion of ISO 8859-1 to UTF-8",
	    [[OFString stringWithCString: "\xE4\xF6\xFC"
				encoding: OF_STRING_ENCODING_ISO_8859_1]
	    isEqual: @"äöü"])

	TEST(@"Conversion of ISO 8859-15 to UTF-8",
	    [[OFString stringWithCString: "\xA4\xA6\xA8\xB4\xB8\xBC\xBD\xBE"
				encoding: OF_STRING_ENCODING_ISO_8859_15]
	    isEqual: @"€ŠšŽžŒœŸ"])

	TEST(@"Conversion of Windows 1252 to UTF-8",
	    [[OFString stringWithCString: "\x80\x82\x83\x84\x85\x86\x87\x88"
					  "\x89\x8A\x8B\x8C\x8E\x91\x92\x93"
					  "\x94\x95\x96\x97\x98\x99\x9A\x9B"
					  "\x9C\x9E\x9F"
				encoding: OF_STRING_ENCODING_WINDOWS_1252]
	    isEqual: @"€‚ƒ„…†‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›œžŸ"])

	TEST(@"+[stringWithFormat:]",
	    [(s[0] = [OFMutableString stringWithFormat: @"%@:%d", @"test", 123])
	    isEqual: @"test:123"])

	TEST(@"-[appendFormat:]",
	    R(([s[0] appendFormat: @"%02X", 15])) &&
	    [s[0] isEqual: @"test:1230F"])

	TEST(@"-[indexOfFirstOccurrenceOfString:]",
	    [@"𝄞öö" indexOfFirstOccurrenceOfString: @"öö"] == 1 &&
	    [@"𝄞öö" indexOfFirstOccurrenceOfString: @"ö"] == 1 &&
	    [@"𝄞öö" indexOfFirstOccurrenceOfString: @"𝄞"] == 0 &&
	    [@"𝄞öö" indexOfFirstOccurrenceOfString: @"x"] == OF_INVALID_INDEX)

	TEST(@"-[indexOfLastOccurrenceOfString:]",
	    [@"𝄞öö" indexOfLastOccurrenceOfString: @"öö"] == 1 &&
	    [@"𝄞öö" indexOfLastOccurrenceOfString: @"ö"] == 2 &&
	    [@"𝄞öö" indexOfLastOccurrenceOfString: @"𝄞"] == 0 &&
	    [@"𝄞öö" indexOfLastOccurrenceOfString: @"x"] == OF_INVALID_INDEX)

	TEST(@"-[substringFromIndexToIndex:]",
	    [[@"𝄞öö" substringFromIndex: 1
				toIndex: 2] isEqual: @"ö"] &&
	    [[@"𝄞öö" substringFromIndex: 3
				toIndex: 3] isEqual: @""])

	EXPECT_EXCEPTION(@"Detect out of range in "
	    @"-[substringFromIndex:toIndex:] #1", OFOutOfRangeException,
	    [@"𝄞öö" substringFromIndex: 2
			       toIndex: 4])
	EXPECT_EXCEPTION(@"Detect out of range in "
	    @"-[substringFromIndex:toIndex:] #2", OFOutOfRangeException,
	    [@"𝄞öö" substringFromIndex: 4
			       toIndex: 4])

	EXPECT_EXCEPTION(@"Detect start > end in "
	    @"-[substringFromIndex:toIndex:]", OFInvalidArgumentException,
	    [@"𝄞öö" substringFromIndex: 2
			       toIndex: 0])

	TEST(@"-[stringByAppendingString:]",
	    [[@"foo" stringByAppendingString: @"bar"] isEqual: @"foobar"])

	TEST(@"-[hasPrefix:]", [@"foobar" hasPrefix: @"foo"] &&
	    ![@"foobar" hasPrefix: @"foobar0"])

	TEST(@"-[hasSuffix:]", [@"foobar" hasSuffix: @"bar"] &&
	    ![@"foobar" hasSuffix: @"foobar0"])

	i = 0;
	TEST(@"-[componentsSeparatedByString:]",
	    (a = [@"fooXXbarXXXXbazXXXX" componentsSeparatedByString: @"XX"]) &&
	    [[a objectAtIndex: i++] isEqual: @"foo"] &&
	    [[a objectAtIndex: i++] isEqual: @"bar"] &&
	    [[a objectAtIndex: i++] isEqual: @""] &&
	    [[a objectAtIndex: i++] isEqual: @"baz"] &&
	    [[a objectAtIndex: i++] isEqual: @""] &&
	    [[a objectAtIndex: i++] isEqual: @""])

	TEST(@"+[stringWithPath:]",
	    (s[0] = [OFString stringWithPath: @"foo", @"bar", @"baz", nil]) &&
#ifndef _WIN32
	    [s[0] isEqual: @"foo/bar/baz"] &&
#else
	    [s[0] isEqual: @"foo\\bar\\baz"] &&
#endif
	    (s[0] = [OFString stringWithPath: @"foo", nil]) &&
	    [s[0] isEqual: @"foo"])

	TEST(@"-[pathComponents]",
	    /* /tmp */
	    (a = [@"/tmp" pathComponents]) && [a count] == 2 &&
	    [[a objectAtIndex: 0] isEqual: @""] &&
	    [[a objectAtIndex: 1] isEqual: @"tmp"] &&
	    /* /tmp/ */
	    (a = [@"/tmp/" pathComponents]) && [a count] == 2 &&
	    [[a objectAtIndex: 0] isEqual: @""] &&
	    [[a objectAtIndex: 1] isEqual: @"tmp"] &&
	    /* / */
	    (a = [@"/" pathComponents]) && [a count] == 1 &&
	    [[a objectAtIndex: 0] isEqual: @""] &&
	    /* foo/bar */
	    (a = [@"foo/bar" pathComponents]) && [a count] == 2 &&
	    [[a objectAtIndex: 0] isEqual: @"foo"] &&
	    [[a objectAtIndex: 1] isEqual: @"bar"] &&
	    /* foo/bar/baz/ */
	    (a = [@"foo/bar/baz" pathComponents]) && [a count] == 3 &&
	    [[a objectAtIndex: 0] isEqual: @"foo"] &&
	    [[a objectAtIndex: 1] isEqual: @"bar"] &&
	    [[a objectAtIndex: 2] isEqual: @"baz"] &&
	    /* foo// */
	    (a = [@"foo//" pathComponents]) && [a count] == 2 &&
	    [[a objectAtIndex: 0] isEqual: @"foo"] &&
	    [[a objectAtIndex: 1] isEqual: @""] &&
	    [[@"" pathComponents] count] == 0)

	TEST(@"-[lastPathComponent]",
	    [[@"/tmp" lastPathComponent] isEqual: @"tmp"] &&
	    [[@"/tmp/" lastPathComponent] isEqual: @"tmp"] &&
	    [[@"/" lastPathComponent] isEqual: @""] &&
	    [[@"foo" lastPathComponent] isEqual: @"foo"] &&
	    [[@"foo/bar" lastPathComponent] isEqual: @"bar"] &&
	    [[@"foo/bar/baz/" lastPathComponent] isEqual: @"baz"])

	TEST(@"-[stringByDeletingLastPathComponent]",
	    [[@"/tmp" stringByDeletingLastPathComponent] isEqual: @"/"] &&
	    [[@"/tmp/" stringByDeletingLastPathComponent] isEqual: @"/"] &&
	    [[@"/tmp/foo/" stringByDeletingLastPathComponent]
	    isEqual: @"/tmp"] &&
	    [[@"foo/bar" stringByDeletingLastPathComponent] isEqual: @"foo"] &&
	    [[@"/" stringByDeletingLastPathComponent] isEqual: @"/"] &&
	    [[@"foo" stringByDeletingLastPathComponent] isEqual: @"."])

	TEST(@"-[decimalValue]",
	    [@"1234" decimalValue] == 1234 &&
	    [@"\r\n+123  " decimalValue] == 123 &&
	    [@"-500\t" decimalValue] == -500 &&
	    [@"\t\t\r\n" decimalValue] == 0)

	TEST(@"-[hexadecimalValue]",
	    [@"123f" hexadecimalValue] == 0x123f &&
	    [@"\t\n0xABcd\r" hexadecimalValue] == 0xABCD &&
	    [@"  xbCDE" hexadecimalValue] == 0xBCDE &&
	    [@"$CdEf" hexadecimalValue] == 0xCDEF &&
	    [@"\rFeh " hexadecimalValue] == 0xFE &&
	    [@"\r\t" hexadecimalValue] == 0)

	/*
	 * These test numbers can be generated without rounding if we have IEEE
	 * floating point numbers, thus we can use == on then.
	 */
	TEST(@"-[floatValue]",
	    [@"\t-0.25 " floatValue] == -0.25 &&
	    [@"\r-INFINITY\n" floatValue] == -INFINITY &&
	    isnan([@"   NAN\t\t" floatValue]))

	TEST(@"-[doubleValue]",
	    [@"\t-0x1.FFFFFFFFFFFFFP-1020 " doubleValue] ==
	    -0x1.FFFFFFFFFFFFFP-1020 &&
	    [@"\r-INFINITY\n" doubleValue] == -INFINITY &&
	    isnan([@"   NAN\t\t" doubleValue]))

	EXPECT_EXCEPTION(@"Detect invalid characters in -[decimalValue] #1",
	    OFInvalidFormatException, [@"abc" decimalValue])
	EXPECT_EXCEPTION(@"Detect invalid characters in -[decimalValue] #2",
	    OFInvalidFormatException, [@"0a" decimalValue])
	EXPECT_EXCEPTION(@"Detect invalid characters in -[decimalValue] #3",
			 OFInvalidFormatException, [@"0 1" decimalValue])

	EXPECT_EXCEPTION(@"Detect invalid chars in -[hexadecimalValue] #1",
	    OFInvalidFormatException, [@"0xABCDEFG" hexadecimalValue])
	EXPECT_EXCEPTION(@"Detect invalid chars in -[hexadecimalValue] #2",
	    OFInvalidFormatException, [@"0x" hexadecimalValue])
	EXPECT_EXCEPTION(@"Detect invalid chars in -[hexadecimalValue] #3",
	    OFInvalidFormatException, [@"$" hexadecimalValue])
	EXPECT_EXCEPTION(@"Detect invalid chars in -[hexadecimalValue] #4",
	    OFInvalidFormatException, [@"$ " hexadecimalValue])

	EXPECT_EXCEPTION(@"Detect invalid chars in -[floatValue] #1",
	    OFInvalidFormatException, [@"0,0" floatValue])
	EXPECT_EXCEPTION(@"Detect invalid chars in -[floatValue] #2",
	    OFInvalidFormatException, [@"0.0a" floatValue])
	EXPECT_EXCEPTION(@"Detect invalid chars in -[floatValue] #3",
	    OFInvalidFormatException, [@"0 0" floatValue])

	EXPECT_EXCEPTION(@"Detect invalid chars in -[doubleValue] #1",
	    OFInvalidFormatException, [@"0,0" floatValue])
	EXPECT_EXCEPTION(@"Detect invalid chars in -[doubleValue] #2",
	    OFInvalidFormatException, [@"0.0a" floatValue])
	EXPECT_EXCEPTION(@"Detect invalid chars in -[doubleValue] #3",
	    OFInvalidFormatException, [@"0 0" floatValue])

	EXPECT_EXCEPTION(@"Detect out of range in -[decimalValue]",
	    OFOutOfRangeException,
	    [@"12345678901234567890123456789012345678901234567890"
	     @"12345678901234567890123456789012345678901234567890"
	    decimalValue])

	EXPECT_EXCEPTION(@"Detect out of range in -[hexadecimalValue]",
	    OFOutOfRangeException,
	    [@"0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
	     @"0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
	    hexadecimalValue])

	TEST(@"-[unicodeString]", (ua = [@"fööbär" unicodeString]) &&
	    !memcmp(ua, ucstr, 7 * sizeof(of_unichar_t)) && R(free(ua)))

	TEST(@"-[MD5Hash]", [[@"asdfoobar" MD5Hash]
	    isEqual: @"184dce2ec49b5422c7cfd8728864db4c"])

	TEST(@"-[SHA1Hash]", [[@"asdfoobar" SHA1Hash]
	    isEqual: @"f5f81ac0a8b5cbfdc4585ec1ad32e7b3a12b9b49"])

	TEST(@"-[stringByURLEncoding]",
	    [[@"foo\"ba'_~$" stringByURLEncoding] isEqual: @"foo%22ba%27_~%24"])

	TEST(@"-[stringByURLDecoding]",
	    [[@"foo%20bar%22+%24" stringByURLDecoding] isEqual: @"foo bar\" $"])

	TEST(@"-[insertString:atIndex:]",
	    (s[0] = [OFMutableString stringWithString: @"𝄞öööbä€"]) &&
	    R([s[0] insertString: @"äöü"
			 atIndex: 3]) &&
	    [s[0] isEqual: @"𝄞ööäöüöbä€"])

	EXPECT_EXCEPTION(@"Detect invalid encoding in -[stringByURLDecoding] "
	    @"#1", OFInvalidEncodingException, [@"foo%bar" stringByURLDecoding])
	EXPECT_EXCEPTION(@"Detect invalid encoding in -[stringByURLDecoding] "
	    @"#2", OFInvalidEncodingException,
	    [@"foo%FFbar" stringByURLDecoding])

	TEST(@"-[deleteCharactersFromIndex:toIndex:]",
	    (s[0] = [OFMutableString stringWithString: @"𝄞öööbä€"]) &&
	    R([s[0] deleteCharactersFromIndex: 1
				       toIndex: 4]) &&
	    [s[0] isEqual: @"𝄞bä€"] &&
	    R([s[0] deleteCharactersFromIndex: 0
				      toIndex: 4]) &&
	    [s[0] isEqual: @""])

	TEST(@"-[replaceCharactersFromIndex:toIndex:withString:]",
	    (s[0] = [OFMutableString stringWithString: @"𝄞öööbä€"]) &&
		   R([s[0] replaceCharactersFromIndex: 1
					      toIndex: 4
					   withString: @"äöü"]) &&
	    [s[0] isEqual: @"𝄞äöübä€"] &&
	    R([s[0] replaceCharactersFromIndex: 0
				       toIndex: 7
				    withString: @""]) &&
	    [s[0] isEqual: @""])

	EXPECT_EXCEPTION(@"Detect OoR in "
	    @"-[deleteCharactersFromIndex:toIndex:] #1", OFOutOfRangeException,
	    {
		s[0] = [OFMutableString stringWithString: @"𝄞öö"];
		[s[0] deleteCharactersFromIndex: 2
					toIndex: 4];
	    })

	EXPECT_EXCEPTION(@"Detect OoR in "
	    @"-[deleteCharactersFromIndex:toIndex:] #2", OFOutOfRangeException,
	    [s[0] deleteCharactersFromIndex: 4
				    toIndex: 4])

	EXPECT_EXCEPTION(@"Detect s > e in "
	    @"-[deleteCharactersFromIndex:toIndex:]",
	    OFInvalidArgumentException,
	    [s[0] deleteCharactersFromIndex: 2
				    toIndex: 0])

	EXPECT_EXCEPTION(@"OoR "
	    @"-[replaceCharactersFromIndex:toIndex:withString:] #1",
	    OFOutOfRangeException, [s[0] replaceCharactersFromIndex: 2
							    toIndex: 4
							 withString: @""])

	EXPECT_EXCEPTION(@"OoR "
	    @"-[replaceCharactersFromIndex:toIndex:withString:] #2",
	    OFOutOfRangeException,
	    [s[0] replaceCharactersFromIndex: 4
				     toIndex: 4
				  withString: @""])

	EXPECT_EXCEPTION(@"s>e in "
	    @"-[replaceCharactersFromIndex:toIndex:withString:]",
	    OFInvalidArgumentException, [s[0] replaceCharactersFromIndex: 2
								 toIndex: 0
							      withString: @""])

	TEST(@"-[replaceOccurrencesOfString:withString:]",
	    (s[0] = [OFMutableString stringWithString:
	    @"asd fo asd fofo asd"]) &&
	    R([s[0] replaceOccurrencesOfString: @"fo"
				    withString: @"foo"]) &&
	    [s[0] isEqual: @"asd foo asd foofoo asd"] &&
	    (s[0] = [OFMutableString stringWithString: @"XX"]) &&
	    R([s[0] replaceOccurrencesOfString: @"X"
				    withString: @"XX"]) &&
	    [s[0] isEqual: @"XXXX"])

	TEST(@"-[deleteLeadingWhitespaces]",
	    (s[0] = [OFMutableString stringWithString: whitespace[0]]) &&
	    R([s[0] deleteLeadingWhitespaces]) &&
	    [s[0] isEqual: @"asd  \t \t\t\r\n"] &&
	    (s[0] = [OFMutableString stringWithString: whitespace[1]]) &&
	    R([s[0] deleteLeadingWhitespaces]) && [s[0] isEqual: @""])

	TEST(@"-[deleteTrailingWhitespaces]",
	    (s[0] = [OFMutableString stringWithString: whitespace[0]]) &&
	    R([s[0] deleteTrailingWhitespaces]) &&
	    [s[0] isEqual: @" \r \t\n\t \tasd"] &&
	    (s[0] = [OFMutableString stringWithString: whitespace[1]]) &&
	    R([s[0] deleteTrailingWhitespaces]) && [s[0] isEqual: @""])

	TEST(@"-[deleteLeadingAndTrailingWhitespaces]",
	    (s[0] = [OFMutableString stringWithString: whitespace[0]]) &&
	    R([s[0] deleteLeadingAndTrailingWhitespaces]) &&
	    [s[0] isEqual: @"asd"] &&
	    (s[0] = [OFMutableString stringWithString: whitespace[1]]) &&
	    R([s[0] deleteLeadingAndTrailingWhitespaces]) &&
	    [s[0] isEqual: @""])

	TEST(@"-[stringByXMLEscaping]",
	    (s[0] = (id)[@"<hello> &world'\"!&" stringByXMLEscaping]) &&
	    [s[0] isEqual: @"&lt;hello&gt; &amp;world&apos;&quot;!&amp;"])

	TEST(@"-[stringByXMLUnescaping]",
	    [[s[0] stringByXMLUnescaping] isEqual: @"<hello> &world'\"!&"] &&
	    [[@"&#x79;" stringByXMLUnescaping] isEqual: @"y"] &&
	    [[@"&#xe4;" stringByXMLUnescaping] isEqual: @"ä"] &&
	    [[@"&#8364;" stringByXMLUnescaping] isEqual: @"€"] &&
	    [[@"&#x1D11E;" stringByXMLUnescaping] isEqual: @"𝄞"])

	EXPECT_EXCEPTION(@"Detect invalid entities in -[stringByXMLUnescaping] "
	    @"#1", OFInvalidEncodingException, [@"&foo;" stringByXMLUnescaping])
	EXPECT_EXCEPTION(@"Detect invalid entities in -[stringByXMLUnescaping] "
	    @"#2", OFInvalidEncodingException, [@"x&amp" stringByXMLUnescaping])
	EXPECT_EXCEPTION(@"Detect invalid entities in -[stringByXMLUnescaping] "
	    @"#3", OFInvalidEncodingException, [@"&#;" stringByXMLUnescaping])
	EXPECT_EXCEPTION(@"Detect invalid entities in -[stringByXMLUnescaping] "
	    @"#4", OFInvalidEncodingException, [@"&#x;" stringByXMLUnescaping])
	EXPECT_EXCEPTION(@"Detect invalid entities in -[stringByXMLUnescaping] "
	    @"#5", OFInvalidEncodingException, [@"&#g;" stringByXMLUnescaping])
	EXPECT_EXCEPTION(@"Detect invalid entities in -[stringByXMLUnescaping] "
	    @"#6", OFInvalidEncodingException, [@"&#xg;" stringByXMLUnescaping])

	TEST(@"-[stringByXMLUnescapingWithDelegate:]",
	    (h = [[[EntityHandler alloc] init] autorelease]) &&
	    [[@"x&foo;y" stringByXMLUnescapingWithDelegate: h]
	    isEqual: @"xbary"])

#ifdef OF_HAVE_BLOCKS
	TEST(@"-[stringByXMLUnescapingWithBlock:]",
	    [[@"x&foo;y" stringByXMLUnescapingWithBlock:
	        ^ OFString* (OFString *str, OFString *entity) {
		    if ([entity isEqual: @"foo"])
			    return @"bar";

		    return nil;
	    }] isEqual: @"xbary"])
#endif

	[pool drain];
}
@end
