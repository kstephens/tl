#ifndef TL_JIT_H
#define TL_JIT_H

#include "jit/jit.h"

tl tl_jit_env(tl env);

#define UNBOX_jit_context_t(T,V) tl_jit_context_t_(V)
#define BOX_jit_context_t(D,T,V) D = tl_jit_context_t(V)

#endif
