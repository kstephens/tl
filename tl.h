#ifndef _tl_tl_h
#define _tl_tl_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <inttypes.h> /* strtoll() */
#include <unistd.h>
#include <stdarg.h>
#include <setjmp.h>
#include <assert.h>

#ifdef tl_PTHREAD
#define GC_THREADS
#endif

typedef void *tl;
typedef size_t tlw;
typedef ssize_t tlsw;

#define tl_nil ((tl) 0)
#define tl_f ((tl) (tlw) 2)
#define tl_t ((tl) (tlw) 4)
#define _tl_b(x) ((x) ? tl_t : tl_f)
#define _tl_B(x) ((x) != tl_f)
static inline tl tl_b(tlw i) { return _tl_b(i); }
#define tl_b(x)_tl_b(x)
static inline tlw tl_B(tl i) { return _tl_B(i); }
#define tl_B(x)_tl_B(x)

#define _tl_i(x) ((tl) ((((tlsw) (x)) << 1) | 1))
#define _tl_I(o) (((tlsw) (o)) >> 1)
static inline tl tl_i(tlsw x) { return _tl_i(x); }
#define tl_i(x)_tl_i(x)
static inline tlsw tl_I(tl o) { return _tl_I(o); }
#define tl_I(o)_tl_I(o)

static inline tl tl_iv(tl o, int n) { return ((tl*)(o))[n]; }
#define tl_iv(o,n) ((tl*)(o))[n]

static inline tl tl_t_(tl o) { return tl_iv(o, -1); }
#define tl_t_(o) tl_iv(o, -1)

#define _tl_type(o)                             \
  (                                             \
   (o) == 0         ? tl_t_null :               \
   ((tlw) (o)) & 1  ? tl_t_fixnum :             \
   (o) <= tl_t      ? tl_t_boolean :            \
                      tl_t_(o) )

#define tl_FP(o,r,p) ((r(*)p) tl_iv(o, 0))

static inline tl tl_closure_env(tl o) { return tl_iv(o, 2); }

#define tl_MARK ((tl) (tlsw) -2)

#endif
