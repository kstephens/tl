#ifndef _TL_WRAP_H
#define _TL_WRAP_H

#define UNBOX(T,V) tl_##T##_(V)
#define BOX(D,T,V) D = tl_##T(V)

#define PARAMS_TL(PARAMS) PARAMS_TL_##PARAMS
#define PARAMS_TL_PARAMS0() 
#define PARAMS_TL_PARAMS1(T1,N1) tl N1
#define PARAMS_TL_PARAMS2(T1,N1,T2,N2) tl N1, tl N2
#define PARAMS_TL_PARAMS3(T1,N1,T2,N2,T3,N3) tl N1, tl N2, tl N3

#define PARAM_UNBOX(T,N) T param_##N = UNBOX(T,N)
#define PARAMS_UNBOX(PARAMS) PARAMS_UNBOX_##PARAMS
#define PARAMS_UNBOX_PARAMS0()
#define PARAMS_UNBOX_PARAMS1(T1,N1) PARAM_UNBOX(T1,N1);
#define PARAMS_UNBOX_PARAMS2(T1,N1,T2,N2) PARAM_UNBOX(T1,N1); PARAM_UNBOX(T2,N2);
#define PARAMS_UNBOX_PARAMS3(T1,N1,T2,N2,T3,N3) PARAM_UNBOX(T1,N1); PARAM_UNBOX(T2,N2); PARAM_UNBOX(T3,N3);


#define PARAMS_PARAMS(PARAMS)PARAMS_PARAMS_##PARAMS
#define PARAMS_PARAMS_PARAMS0()
#define PARAMS_PARAMS_PARAMS1(T1,N1) param_##N1
#define PARAMS_PARAMS_PARAMS2(T1,N1,T2,N2) param_##N1, param_##N2
#define PARAMS_PARAMS_PARAMS3(T1,N1,T2,N2,T3,N3) param_##N1, param_##N2, param_##N3

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

#define tl_void_(V) (void) (V)
#define tl_void(V) ((V), (tl) 0)

#define tl_int_(V) tl_I(V)
#define tl_int(V)  tl_i(V)

#define tl_unsigned_int_(V) tl_I(V)
#define tl_unsigned_int(V)  tl_i(V)

#define WRAP_CT1(TYPE,NAME)                                             \
  static tl tl_t_##NAME;                                                \
  struct tl_ts_##NAME {                                                 \
    tl slots[1];                                                        \
    TYPE value;                                                         \
  };                                                                    \
  static tl tl_##NAME(TYPE value) {                                     \
    struct tl_ts_##NAME *result = tl_allocate(tl_t_##NAME, sizeof(*result)); \
    result->value = value;                                              \
    return (tl) result;                                                 \
  }                                                                     \
  static TYPE tl_##NAME##_(tl value) {                                  \
    return ((struct tl_ts_##NAME *) value)->value;                      \
  }

#define WRAP_CT(TYPE,NAME)                                              \
  WRAP_CT1(TYPE,NAME)                                                   \
  typedef TYPE *NAME##P;                                                \
  WRAP_CT1(TYPE##P,NAME##P)                                             \
  static tl tl_##NAME##_A(tl value) {                                   \
    return tl_##NAME##P(&((struct tl_ts_##NAME *) value)->value);       \
  }                                                                     \
  static tl tl_##NAME##P_R(tl value) {                                  \
    return tl_##NAME(*((struct tl_ts_##NAME##P *) value)->value);       \
  }                                                                     \
  static tl tl_##NAME##P_W(tl dst, tl value) {                          \
    *((struct tl_ts_##NAME##P *)dst)->value =                           \
      tl_##NAME##_(value);                                              \
    return dst;                                                         \
  }
#endif
