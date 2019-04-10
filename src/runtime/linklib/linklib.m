/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017,
 *               2018, 2019
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

#import "ObjFW_RT.h"
#import "private.h"
#import "macros.h"

#include <proto/exec.h>

#import "inline.h"

#include <stdio.h>
#include <stdlib.h>

#ifdef OF_AMIGAOS_M68K
# include <stabs.h>
#endif

#ifdef HAVE_SJLJ_EXCEPTIONS
extern int _Unwind_SjLj_RaiseException(void *);
#else
extern int _Unwind_RaiseException(void *);
#endif
extern void _Unwind_DeleteException(void *);
extern void *_Unwind_GetLanguageSpecificData(void *);
extern uintptr_t _Unwind_GetRegionStart(void *);
extern uintptr_t _Unwind_GetDataRelBase(void *);
extern uintptr_t _Unwind_GetTextRelBase(void *);
extern uintptr_t _Unwind_GetIP(void *);
extern uintptr_t _Unwind_GetGR(void *, int);
extern void _Unwind_SetIP(void *, uintptr_t);
extern void _Unwind_SetGR(void *, int, uintptr_t);
#ifdef HAVE_SJLJ_EXCEPTIONS
extern void _Unwind_SjLj_Resume(void *);
#else
extern void _Unwind_Resume(void *);
#endif
extern void __register_frame_info(const void *, void *);
extern void __deregister_frame_info(const void *);

struct Library *ObjFWRTBase;
void *__objc_class_name_Protocol;

static void
ctor(void)
{
	static bool initialized = false;
	struct objc_libc libc = {
		.malloc = malloc,
		.calloc = calloc,
		.realloc = realloc,
		.free = free,
		.vfprintf = vfprintf,
		.fflush = fflush,
		.abort = abort,
#ifdef HAVE_SJLJ_EXCEPTIONS
		._Unwind_SjLj_RaiseException = _Unwind_SjLj_RaiseException,
#else
		._Unwind_RaiseException = _Unwind_RaiseException,
#endif
		._Unwind_DeleteException = _Unwind_DeleteException,
		._Unwind_GetLanguageSpecificData =
		    _Unwind_GetLanguageSpecificData,
		._Unwind_GetRegionStart = _Unwind_GetRegionStart,
		._Unwind_GetDataRelBase = _Unwind_GetDataRelBase,
		._Unwind_GetTextRelBase = _Unwind_GetTextRelBase,
		._Unwind_GetIP = _Unwind_GetIP,
		._Unwind_GetGR = _Unwind_GetGR,
		._Unwind_SetIP = _Unwind_SetIP,
		._Unwind_SetGR = _Unwind_SetGR,
#ifdef HAVE_SJLJ_EXCEPTIONS
		._Unwind_SjLj_Resume = _Unwind_SjLj_Resume,
#else
		._Unwind_Resume = _Unwind_Resume,
#endif
		.__register_frame_info = __register_frame_info,
		.__deregister_frame_info = __deregister_frame_info,
	};

	if (initialized)
		return;

	if ((ObjFWRTBase = OpenLibrary("objfw_rt.library", 0)) == NULL) {
		fputs("Failed to open objfw_rt.library!\n", stderr);
		abort();
	}

	if (!objc_init_m68k(1, &libc, stdout, stderr)) {
		fputs("Failed to initialize objfw_rt.library!\n", stderr);
		abort();
	}

	initialized = true;
}

static void __attribute__((__unused__))
dtor(void)
{
	CloseLibrary(ObjFWRTBase);
}

#if defined(OF_AMIGAOS_M68K)
ADD2INIT(ctor, -2);
ADD2EXIT(dtor, -2);
#elif defined(OF_MORPHOS)
CONSTRUCTOR_P(ctor, -2);
DESTRUCTOR_P(dtor, -2);
#endif

void
__objc_exec_class(void *module)
{
	/*
	 * The compiler generates constructors that call into this, so it is
	 * possible that we are not set up yet when we get called.
	 */
	ctor();

	__objc_exec_class_m68k(module);
}

IMP
objc_msg_lookup(id object, SEL selector)
{
	return objc_msg_lookup_m68k(object, selector);
}

IMP
objc_msg_lookup_stret(id object, SEL selector)
{
	return objc_msg_lookup_stret_m68k(object, selector);
}

IMP
objc_msg_lookup_super(struct objc_super *super, SEL selector)
{
	return objc_msg_lookup_super_m68k(super, selector);
}

IMP
objc_msg_lookup_super_stret(struct objc_super *super, SEL selector)
{
	return objc_msg_lookup_super_stret_m68k(super, selector);
}

Class
objc_lookUpClass(const char *name)
{
	return objc_lookUpClass_m68k(name);
}

Class
objc_getClass(const char *name)
{
	return objc_getClass_m68k(name);
}

Class
objc_getRequiredClass(const char *name)
{
	return objc_getRequiredClass_m68k(name);
}

Class
objc_lookup_class(const char *name)
{
	return objc_lookup_class_m68k(name);
}

Class
objc_get_class(const char *name)
{
	return objc_get_class_m68k(name);
}

void
objc_exception_throw(id object)
{
#ifdef OF_AMIGAOS_M68K
	/*
	 * This does not use the glue code to hack around a compiler bug.
	 *
	 * When using the generated inline stubs, the compiler does not emit
	 * any frame information, making the unwind fail. As unwind always
	 * starts from objc_exception_throw(), this means exceptions would
	 * never work. If, however, we're using a function pointer instead of
	 * the inline stub, the compiler does generate a frame and everything
	 * works fine.
	 */
	register void *a6 __asm__("a6") = ObjFWRTBase;
	uintptr_t throw = (((uintptr_t)ObjFWRTBase) - 0x60);
	((void (*)(id __asm__("a0")))throw)(object);
	(void)a6;
#else
	objc_exception_throw_m68k(object);
#endif

	OF_UNREACHABLE
}

int
objc_sync_enter(id object)
{
	return objc_sync_enter_m68k(object);
}

int
objc_sync_exit(id object)
{
	return objc_sync_exit_m68k(object);
}

id
objc_getProperty(id self, SEL _cmd, ptrdiff_t offset, bool atomic)
{
	return objc_getProperty_m68k(self, _cmd, offset, atomic);
}

void
objc_setProperty(id self, SEL _cmd, ptrdiff_t offset, id value, bool atomic,
    signed char copy)
{
	objc_setProperty_m68k(self, _cmd, offset, value, atomic, copy);
}

void
objc_getPropertyStruct(void *dest, const void *src, ptrdiff_t size, bool atomic,
    bool strong)
{
	objc_getPropertyStruct_m68k(dest, src, size, atomic, strong);
}

void
objc_setPropertyStruct(void *dest, const void *src, ptrdiff_t size, bool atomic,
    bool strong)
{
	objc_setPropertyStruct_m68k(dest, src, size, atomic, strong);
}

void
objc_enumerationMutation(id object)
{
#ifdef OF_AMIGAOS_M68K
	/*
	 * This does not use the glue code to hack around a compiler bug.
	 *
	 * When using the generated inline stubs, the compiler does not emit
	 * any frame information, making the unwind fail. As a result
	 * objc_enumerationMutation() might throw an exception that could never
	 * be caught. If, however, we're using a function pointer instead of
	 * the inline stub, the compiler does generate a frame and everything
	 * works fine.
	 */
	register void *a6 __asm__("a6") = ObjFWRTBase;
	uintptr_t enumerationMutation = (((uintptr_t)ObjFWRTBase) - 0x8A);
	((void (*)(id __asm__("a0")))enumerationMutation)(object);
	(void)a6;
#else
	objc_enumerationMutation_m68k(object);
#endif

	OF_UNREACHABLE
}

#ifdef HAVE_SJLJ_EXCEPTIONS
int
__gnu_objc_personality_sj0(int version, int actions, uint64_t exClass,
    void *ex, void *ctx)
{
	return __gnu_objc_personality_sj0_m68k(version, actions, &exClass,
	    ex, ctx);
}
#else
int
__gnu_objc_personality_v0(int version, int actions, uint64_t exClass,
    void *ex, void *ctx)
{
	return __gnu_objc_personality_v0_m68k(version, actions, &exClass,
	    ex, ctx);
}
#endif

id
objc_retain(id object)
{
	return objc_retain_m68k(object);
}

id
objc_retainBlock(id block)
{
	return objc_retainBlock_m68k(block);
}

id
objc_retainAutorelease(id object)
{
	return objc_retainAutorelease_m68k(object);
}

void
objc_release(id object)
{
	objc_release_m68k(object);
}

id
objc_autorelease(id object)
{
	return objc_autorelease_m68k(object);
}

id
objc_autoreleaseReturnValue(id object)
{
	return objc_autoreleaseReturnValue_m68k(object);
}

id
objc_retainAutoreleaseReturnValue(id object)
{
	return objc_retainAutoreleaseReturnValue_m68k(object);
}

id
objc_retainAutoreleasedReturnValue(id object)
{
	return objc_retainAutoreleasedReturnValue_m68k(object);
}

id
objc_storeStrong(id *object, id value)
{
	return objc_storeStrong_m68k(object, value);
}

id
objc_storeWeak(id *object, id value)
{
	return objc_storeWeak_m68k(object, value);
}

id
objc_loadWeakRetained(id *object)
{
	return objc_loadWeakRetained_m68k(object);
}

id
objc_initWeak(id *object, id value)
{
	return objc_initWeak_m68k(object, value);
}

void
objc_destroyWeak(id *object)
{
	objc_destroyWeak_m68k(object);
}

id
objc_loadWeak(id *object)
{
	return objc_loadWeak_m68k(object);
}

void
objc_copyWeak(id *dest, id *src)
{
	objc_copyWeak_m68k(dest, src);
}

void
objc_moveWeak(id *dest, id *src)
{
	objc_moveWeak_m68k(dest, src);
}

SEL
sel_registerName(const char *name)
{
	return sel_registerName_m68k(name);
}

const char *
sel_getName(SEL selector)
{
	return sel_getName_m68k(selector);
}

bool
sel_isEqual(SEL selector1, SEL selector2)
{
	return sel_isEqual_m68k(selector1, selector2);
}

Class
objc_allocateClassPair(Class superclass, const char *name, size_t extraBytes)
{
	return objc_allocateClassPair_m68k(superclass, name, extraBytes);
}

void
objc_registerClassPair(Class class)
{
	objc_registerClassPair_m68k(class);
}

unsigned int
objc_getClassList(Class *buffer, unsigned int count)
{
	return objc_getClassList_m68k(buffer, count);
}

Class *
objc_copyClassList(unsigned int *length)
{
	return objc_copyClassList_m68k(length);
}

bool
class_isMetaClass(Class class)
{
	return class_isMetaClass_m68k(class);
}

const char *
class_getName(Class class)
{
	return class_getName_m68k(class);
}

Class
class_getSuperclass(Class class)
{
	return class_getSuperclass_m68k(class);
}

unsigned long
class_getInstanceSize(Class class)
{
	return class_getInstanceSize_m68k(class);
}

bool
class_respondsToSelector(Class class, SEL selector)
{
	return class_respondsToSelector_m68k(class, selector);
}

bool
class_conformsToProtocol(Class class, Protocol *protocol)
{
	return class_conformsToProtocol_m68k(class, protocol);
}

IMP
class_getMethodImplementation(Class class, SEL selector)
{
	return class_getMethodImplementation_m68k(class, selector);
}

IMP
class_getMethodImplementation_stret(Class class, SEL selector)
{
	return class_getMethodImplementation_stret_m68k(class, selector);
}

const char *
class_getMethodTypeEncoding(Class class, SEL selector)
{
	return class_getMethodTypeEncoding_m68k(class, selector);
}

bool
class_addMethod(Class class, SEL selector, IMP implementation,
    const char *typeEncoding)
{
	return class_addMethod_m68k(class, selector, implementation,
	    typeEncoding);
}

IMP
class_replaceMethod(Class class, SEL selector, IMP implementation,
    const char *typeEncoding)
{
	return class_replaceMethod_m68k(class, selector, implementation,
	    typeEncoding);
}

Class
object_getClass(id object)
{
	return object_getClass_m68k(object);
}

Class
object_setClass(id object, Class class)
{
	return object_setClass_m68k(object, class);
}

const char *
object_getClassName(id object)
{
	return object_getClassName_m68k(object);
}

const char *
protocol_getName(Protocol *protocol)
{
	return protocol_getName_m68k(protocol);
}

bool
protocol_isEqual(Protocol *protocol1, Protocol *protocol2)
{
	return protocol_isEqual_m68k(protocol1, protocol2);
}

bool
protocol_conformsToProtocol(Protocol *protocol1, Protocol *protocol2)
{
	return protocol_conformsToProtocol_m68k(protocol1, protocol2);
}

void
objc_exit(void)
{
	objc_exit_m68k();
}

objc_uncaught_exception_handler
objc_setUncaughtExceptionHandler(objc_uncaught_exception_handler handler)
{
	return objc_setUncaughtExceptionHandler_m68k(handler);
}

void
objc_setForwardHandler(IMP forward, IMP stretForward)
{
	objc_setForwardHandler_m68k(forward, stretForward);
}

void
objc_setEnumerationMutationHandler(objc_enumeration_mutation_handler handler)
{
	objc_setEnumerationMutationHandler_m68k(handler);
}

void
objc_zero_weak_references(id value)
{
	objc_zero_weak_references_m68k(value);
}
