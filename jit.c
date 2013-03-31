
#define UNBOX(T,V) UNBOX_##T(T,V)
#define BOX(D,T,V) BOX_##T(D,T,V)

#define PARAMS_TL(PARAMS) PARAMS_TL_##PARAMS
#define PARAMS_TL_PARAMS0() 
#define PARAMS_TL_PARAMS1(T1,N1) tl N1
#define PARAMS_TL_PARAMS2(T1,N1,T2,N2) tl N1, tl N2

#define PARAM_UNBOX(T,N) T param_##N = UNBOX(T,N)
#define PARAMS_UNBOX(PARAMS) PARAMS_UNBOX_##PARAMS
#define PARAMS_UNBOX_PARAMS0()
#define PARAMS_UNBOX_PARAMS1(T1,N1) PARAM_UNBOX(T1,N1);
#define PARAMS_UNBOX_PARAMS2(T1,N1,T2,N2) PARAM_UNBOX(T1,N1); PARAM_UNBOX(T2,N2);

#define PARAMS_PARAMS(PARAMS)PARAMS_PARAMS_##PARAMS
#define PARAMS_PARAMS_PARAMS0()
#define PARAMS_PARAMS_PARAMS1(T1,N1) param_##N1
#define PARAMS_PARAMS_PARAMS2(T1,N1,T2,N2) param_##N1, param_##N2

#define PARAMS_FREE(PARAMS)

#define tl_NAME_CF(RTYPE,NAME,PARAMS) tl_##NAME
#define DECLARE_CF(RTYPE,NAME,PARAMS) tl tl_##NAME(PARAMS_TL(PARAMS))
#define DEFINE_CF(RTYPE,NAME,PARAMS)                    \
  DECLARE_CF(RTYPE,NAME,PARAMS) {                       \
    tl __return = 0;                                    \
    PARAMS_UNBOX(PARAMS);                               \
    BOX(__return, RTYPE, NAME (PARAMS_PARAMS(PARAMS))); \
    PARAMS_FREE(PARAMS);                                \
    return __return;                                    \
  }

#define UNBOX_void(T,V)
#define BOX_void(D,T,V) V

#include "jit.h"

#define CT(TYPE,NAME)                                                   \
  static tl tl_t_##NAME;                                                \
  struct tl_ts_##NAME {                                                 \
    tl slots[4];                                                        \
    TYPE value;                                                         \
  };                                                                    \
  static tl tl_##NAME(TYPE value) {                                    \
    struct tl_ts_##NAME *result = tl_allocate(tl_t_##NAME, sizeof(*result)); \
    result->value = value;                                              \
    return (tl) result;                                                 \
  }                                                                     \
  static TYPE tl_##NAME##_(tl value) {                                  \
  struct tl_ts_##NAME *result = value;                                  \
  return result->value;                                                 \
  }
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
#define CT(TYPE,NAME) D(TYPE, tl_t_##NAME = tl_m_type(#TYPE));
#include "jit_types.h"
#undef CT

#define CF(RTYPE,NAME,PARAMS) P(tl_##NAME);
#include "jit_funcs.h"
#undef CF
  return env;
}

