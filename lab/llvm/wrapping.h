#ifndef WRAPPING_H
#define WRAPPING_H

#define BODY(X) ;

#define B(T,X) ((void*) B_##T(T,X))
#define AC(T,X) AC_##T(T,X)
#define AD(T,X) AD_##T(T,X)

#define C0(C) \
  void *SCOPE(c_##C)() \
       BODY(return (void*) new C())
#define C1(C,T1,A1) \
  void *SCOPE(c_##C##_##T1)(AD(T1,A1))          \
       BODY(return (void*) new C(AC(T1,A1)))
#define C2(C,T1,A1,T2,A2)     \
  void *SCOPE(c_##C##_##T1##_##T2)(AD(T1,A1), AD(T2,A2))        \
       BODY(return (void*) new C(AC(T1,A1), AC(T2,A2)))
#define D(C)  \
  void SCOPE(d_##C)(AD(C##P,_this))                \
       BODY(delete (C*) _this)

#define F0(RT,N) \
  void *SCOPE(f_##N)() \
       BODY(return B(RT,N()))
#define F1(RT,N,T1,A1) \
  void *SCOPE(f_##N##_##T1)(AD(T1,A1))          \
       BODY(return B(RT,N(AC(T1,A1))))

#define CM0(RT,C,M) \
  void *SCOPE(cm_##C##_##M)() \
       BODY(return B(RT, C::M()))
#define CM1(RT,C,M,T1,A1) \
  void *SCOPE(cm_##C##_##M##_##T1)(AD(T1,A1))   \
       BODY(return B(RT, C::M(AC(T1,A1))))
#define CM2(RT,C,M,T1,A1,T2,A2)  \
  void *SCOPE(cm_##C##_##M##_##T1##_##T2)(AD(T1,A1), AD(T2,A2)) \
       BODY(return B(RT, C::M(AC(T1,A1), AC(T2,A2))))
#define CM3(RT,C,M,T1,A1,T2,A2,T3,A3) \
  void *SCOPE(cm_##C##_##M##_##T1##_##T2##_##T3)(AD(T1,A1), AD(T2,A2), AD(T3,A3)) \
       BODY(return B(RT, C::M(AC(T1,A1), AC(T2,A2), AC(T3,A3))))

#define IM0(RT,C,M)  \
  void *SCOPE(im_##C##_##m)(AD(C##P,_this))     \
       BODY(return B(RT, ((C*)_this)->M()))

#define IM1(RT,C,M,T1,A1)  \
  void *SCOPE(im_##C##_##m)(AD(C##P,_this), AD(T1,A1))  \
       BODY(return B(RT, ((C*)_this)->M(AC(T1,A1))))

#endif
