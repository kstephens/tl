#ifndef _llvm_w_types_h
#define _llvm_w_types_h

#define _SCOPE(X) llvm_##X
#define SCOPE(X)_SCOPE(X)

typedef char *charP;
typedef const char *CcharP;

#define B_void(T,X) ((X), 0)
#define B_voidP(T,X) (X)
#define B_charP(T,X) (X)
#define B_CcharP(T,X) (X)
#define B_int(T,X) (X)
#define B_bool(T,X) ((int) (X))
#define B_IntegerTypeP(T,X) (X)
#define B_ModuleP(T,X)  (X)
#define B_ModuleR(T,X) &(X)
#define B_LLVMContextR(T,X) &(X)

#define AD_voidP(T,N) T N
#define AC_voidP(T,X) (X)
#define AD_charP(T,N) T N
#define AC_charP(T,X) (X)
#define AD_CcharPP(T,N) T N
#define AC_CcharP(T,X) (X)
#define AD_int(T,N) T N
#define AC_int(T,X) (X)
#define AD_bool(T,N) int N
#define AC_bool(T,X) (X)
#define AD_ModuleP(T,N) void *N
#define AC_ModuleP(T,X) (T)(X)
#define AD_ModuleR(T,N) void *N
#define AC_ModuleR(T,X) *(T)(X)
#define AD_LLVMContextR(T,N) void *N
#define AC_LLVMContextR(T,X) *(T)(X)
#define AD_PassManagerP(T,N) void *N
#define AC_PassManagerP(T,N) (T)(X)

#endif
