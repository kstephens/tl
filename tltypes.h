#ifndef TYPE_
#define TYPE_(T)TYPE(T,T)
#endif
TYPE_(tl)
ITYPE(tlw,tlw)
ITYPE(tlsw,tlsw)
ITYPE(useconds_t,useconds_t)
#ifdef tl_PTHREAD
TYPE_(pthread_t) TYPE_(pthread_attr_t)
TYPE_(pthread_mutex_t) TYPE_(pthread_mutexattr_t)
TYPE_(pthread_cond_t) TYPE_(pthread_condattr_t)
TYPE_(pthread_rwlock_t) TYPE_(pthread_rwlockattr_t)
#endif
#include "ctypes.h"
