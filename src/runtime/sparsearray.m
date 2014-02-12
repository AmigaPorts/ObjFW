/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012, 2013, 2014
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

#include <stdio.h>
#include <stdlib.h>

#import "runtime.h"
#import "runtime-private.h"

static struct objc_sparsearray_level2 *empty_level2 = NULL;
#ifdef OF_SELUID24
static struct objc_sparsearray_level3 *empty_level3 = NULL;
#endif

static void
init(void)
{
	uint_fast16_t i;

	empty_level2 = malloc(sizeof(struct objc_sparsearray_level2));
	if (empty_level2 == NULL)
		OBJC_ERROR("Not enough memory to allocate sparse array!");

#ifdef OF_SELUID24
	empty_level3 = malloc(sizeof(struct objc_sparsearray_level3));
	if (empty_level3 == NULL)
		OBJC_ERROR("Not enough memory to allocate sparse array!");
#endif

#ifdef OF_SELUID24
	for (i = 0; i < 256; i++) {
		empty_level2->buckets[i] = empty_level3;
		empty_level3->buckets[i] = NULL;
	}
#else
	for (i = 0; i < 256; i++)
		empty_level2->buckets[i] = NULL;
#endif
}

struct objc_sparsearray*
objc_sparsearray_new(void)
{
	struct objc_sparsearray *s;
	uint_fast16_t i;

#ifdef OF_SELUID24
	if (empty_level2 == NULL || empty_level3 == NULL)
		init();
#else
	if (empty_level2 == NULL)
		init();
#endif

	if ((s = malloc(sizeof(struct objc_sparsearray))) == NULL)
		OBJC_ERROR("Not enough memory to allocate sparse array!");

	for (i = 0; i < 256; i++)
		s->buckets[i] = empty_level2;

	return s;
}

void
objc_sparsearray_copy(struct objc_sparsearray *dst,
    struct objc_sparsearray *src)
{
	uint_fast16_t i, j;
#ifdef OF_SELUID24
	uint_fast16_t k;
#endif
	uint32_t idx;

	for (i = 0; i < 256; i++) {
		if (src->buckets[i] == empty_level2)
			continue;

#ifdef OF_SELUID24
		for (j = 0; j < 256; j++) {
			if (src->buckets[i]->buckets[j] == empty_level3)
				continue;

			for (k = 0; k < 256; k++) {
				const void *obj;

				obj = src->buckets[i]->buckets[j]->buckets[k];

				if (obj == NULL)
					continue;

				idx = (uint32_t)
				    (((uint32_t)i << 16) | (j << 8) | k);
				objc_sparsearray_set(dst, idx, obj);
			}
		}
#else
		for (j = 0; j < 256; j++) {
			const void *obj;

			obj = src->buckets[i]->buckets[j];

			if (obj == NULL)
				continue;

			idx = (uint32_t)((i << 8) | j);
			objc_sparsearray_set(dst, idx, obj);
		}
#endif
	}
}

void
objc_sparsearray_set(struct objc_sparsearray *s, uint32_t idx, const void *obj)
{
#ifdef OF_SELUID24
	uint8_t i = idx >> 16;
	uint8_t j = idx >> 8;
	uint8_t k = idx;
#else
	uint8_t i = idx >> 8;
	uint8_t j = idx;
#endif

	if (s->buckets[i] == empty_level2) {
		struct objc_sparsearray_level2 *t;
		uint_fast16_t l;

		t = malloc(sizeof(struct objc_sparsearray_level2));

		if (t == NULL)
			OBJC_ERROR("Not enough memory to insert into sparse "
			    "array!");

		for (l = 0; l < 256; l++)
#ifdef OF_SELUID24
			t->buckets[l] = empty_level3;
#else
			t->buckets[l] = NULL;
#endif

		s->buckets[i] = t;
	}

#ifdef OF_SELUID24
	if (s->buckets[i]->buckets[j] == empty_level3) {
		struct objc_sparsearray_level3 *t;
		uint_fast16_t l;

		t = malloc(sizeof(struct objc_sparsearray_level3));

		if (t == NULL)
			OBJC_ERROR("Not enough memory to insert into sparse "
			    "array!");

		for (l = 0; l < 256; l++)
			t->buckets[l] = NULL;

		s->buckets[i]->buckets[j] = t;
	}

	s->buckets[i]->buckets[j]->buckets[k] = obj;
#else
	s->buckets[i]->buckets[j] = obj;
#endif
}

void
objc_sparsearray_free(struct objc_sparsearray *s)
{
	uint_fast16_t i;
#ifdef OF_SELUID24
	uint_fast16_t j;
#endif

	for (i = 0; i < 256; i++) {
		if (s->buckets[i] == empty_level2)
			continue;

#ifdef OF_SELUID24
		for (j = 0; j < 256; j++)
			if (s->buckets[i]->buckets[j] != empty_level3)
				free(s->buckets[i]->buckets[j]);
#endif

		free(s->buckets[i]);
	}

	free(s);
}

void
objc_sparsearray_cleanup(void)
{
	if (empty_level2 != NULL)
		free(empty_level2);
#ifdef OF_SELUID24
	if (empty_level3 != NULL)
		free(empty_level3);
#endif

	empty_level2 = NULL;
#ifdef OF_SELUID24
	empty_level3 = NULL;
#endif
}
