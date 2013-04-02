#ifndef _TL_WRAP_H
#define _TL_WRAP_H

#define UNBOX(T,V) tl_##T##_(V)
#define BOX(D,T,V) D = tl_##T(V)

#define PARAMS_TL(PARAMS) PARAMS_TL_##PARAMS
#define PARAMS_TL_PARAMS0() 
#define PARAMS_TL_PARAMS1(T1,N1) tl N1
#define PARAMS_TL_PARAMS2(T1,N1,T2,N2) tl N1, tl N2
#define PARAMS_TL_PARAMS3(T1,N1,T2,N2,T3,N3) tl N1, tl N2, tl N3
#define PARAMS_TL_PARAMS4(T1,N1,T2,N2,T3,N3,T4,N4) tl N1, tl N2, tl N3, tl N4
#define PARAMS_TL_PARAMS5(T1,N1,T2,N2,T3,N3,T4,N4,T5,N5) tl N1, tl N2, tl N3, tl N4, tl N5

#define PARAM_UNBOX(T,N) T param_##N = UNBOX(T,N)
#define PARAMS_UNBOX(PARAMS) PARAMS_UNBOX_##PARAMS
#define PARAMS_UNBOX_PARAMS0()
#define PARAMS_UNBOX_PARAMS1(T1,N1) PARAM_UNBOX(T1,N1);
#define PARAMS_UNBOX_PARAMS2(T1,N1,T2,N2) PARAM_UNBOX(T1,N1); PARAM_UNBOX(T2,N2);
#define PARAMS_UNBOX_PARAMS3(T1,N1,T2,N2,T3,N3) PARAM_UNBOX(T1,N1); PARAM_UNBOX(T2,N2); PARAM_UNBOX(T3,N3);
#define PARAMS_UNBOX_PARAMS4(T1,N1,T2,N2,T3,N3,T4,N4) PARAM_UNBOX(T1,N1); PARAM_UNBOX(T2,N2); PARAM_UNBOX(T3,N3); PARAM_UNBOX(T4,N4);
#define PARAMS_UNBOX_PARAMS5(T1,N1,T2,N2,T3,N3,T4,N4,T5,N5) PARAM_UNBOX(T1,N1); PARAM_UNBOX(T2,N2); PARAM_UNBOX(T3,N3); PARAM_UNBOX(T4,N4); PARAM_UNBOX(T5,N5);

#define PARAMS_PARAMS(PARAMS)PARAMS_PARAMS_##PARAMS
#define PARAMS_PARAMS_PARAMS0()
#define PARAMS_PARAMS_PARAMS1(T1,N1) param_##N1
#define PARAMS_PARAMS_PARAMS2(T1,N1,T2,N2) param_##N1, param_##N2
#define PARAMS_PARAMS_PARAMS3(T1,N1,T2,N2,T3,N3) param_##N1, param_##N2, param_##N3
#define PARAMS_PARAMS_PARAMS4(T1,N1,T2,N2,T3,N3,T4,N4) param_##N1, param_##N2, param_##N3, param_##N4
#define PARAMS_PARAMS_PARAMS5(T1,N1,T2,N2,T3,N3,T4,N4,T5,N5) param_##N1, param_##N2, param_##N3, param_##N4, param_##N5

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
    tl size;                                                            \
    TYPE value;                                                         \
  };                                                                    \
  static tl tl_##NAME(TYPE value) {                                     \
    struct tl_ts_##NAME *self = tl_allocate(tl_t_##NAME, sizeof(*self)); \
    self->value = value;                                                \
    return (tl) self;                                                   \
  }                                                                     \
  static TYPE tl_##NAME##_(tl self) {                                   \
    return ((struct tl_ts_##NAME *) self)->value;                       \
  }

#define WRAP_CT(TYPE,NAME)                                              \
  WRAP_CT1(TYPE,NAME)                                                   \
  typedef TYPE *NAME##P;                                                \
  WRAP_CT1(TYPE##P,NAME##P)                                             \
  static tl tl_##NAME##Pv(tl count, tl value) {                        \
    size_t i;                                                           \
    struct tl_ts_##NAME##P *self = tl_allocate(tl_t_##NAME##P, sizeof(*self)); \
    self->size = count;                                                 \
    self->value = tl_malloc(sizeof(self->value[0]) * tl_I(count));      \
    for ( i = 0; i < tl_I(count); ++ i ) self->value[i] = tl_##NAME##_(value); \
    return self;                                                        \
  }                                                                     \
  static tl tl_##NAME##P_R(tl self, tl i) {                              \
    return tl_##NAME(((struct tl_ts_##NAME##P *) self)->value[tl_I(i)]); \
  }                                                                     \
  static tl tl_##NAME##P_W(tl self, tl i, tl value) {                    \
    ((struct tl_ts_##NAME##P *) self)->value[tl_I(i)] =                 \
      tl_##NAME##_(value);                                              \
    return self;                                                        \
  }                                                                     \
  static tl tl_##NAME##_A(tl self) {                                    \
    return tl_##NAME##P(&((struct tl_ts_##NAME *) self)->value);        \
  }                                                                     \

#endif
