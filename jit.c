#include "wrap.h"
#include "jit.h"

#define CT(TYPE,NAME) WRAP_CT(TYPE,NAME)
#include "jit_types.h"
#undef CT

#define CF(RTYPE,NAME,PARAMS) static DECLARE_CF(RTYPE,NAME,PARAMS);
#include "jit_funcs.h"
#undef CF

#define CF(RTYPE,NAME,PARAMS) static DEFINE_CF(RTYPE,NAME,PARAMS)
#include "jit_funcs.h"
#undef CF

tl tl_jit_env(tl env)
{
  tl _v;
#define CT(TYPE,NAME)                                    \
  D(TYPE, tl_t_##NAME = tl_m_type(#TYPE));               \
  P(tl_##NAME); P(tl_##NAME##_); P(tl_##NAME##_A);       \
  P(tl_##NAME##_FORCE);                                  \
  D(TYPE, tl_t_##NAME##P = tl_m_type(#TYPE"*"));         \
  P(tl_##NAME##P); P(tl_##NAME##P_);                     \
  P(tl_##NAME##P_FORCE);                                 \
  P(tl_##NAME##Pv);                                      \
  P(tl_##NAME##P_R); P(tl_##NAME##P_W);
#include "jit_types.h"
#undef CT

#define CF(RTYPE,NAME,PARAMS) P(tl_##NAME);
#include "jit_funcs.h"
#undef CF

#define CG(TYPE,NAME) D(tl_##NAME, tl_##TYPE(NAME));
#include "jit_globals.h"
#undef CG

  return env;
}

