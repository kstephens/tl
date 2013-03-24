#include "llvm/PassManager.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/Assembly/PrintModulePass.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/ExecutionEngine/Interpreter.h"
#include "llvm/ExecutionEngine/JIT.h"
#include <iostream>

using namespace llvm;

typedef LLVMContext &LLVMContextR;
typedef IntegerType *IntegerTypeP;

#define B(T,X) ((void*) B_##T(X))
#define B_void(X) ((X), 0)
#define B_voidP(X) (X)
#define B_int(X) (X)
#define B_bool(X) ((int) (X))
#define B_IntegerTypeP(X) (X)

#define D(C)  void ds_##C(C *_this) { delete _this; }
#define C0(C) void *cs_##C() { return (void*) new C(); }
#define C1(C,T1,A1) void *cs_##C(T1 A1) { return (void*) new C(A1); }

#define F0(RT,N) void *f_##N() { return B(RT,N()); }
#define F1(RT,N,T1,A1) void *f_##N(T1 A1) { return B(RT,N(A1)); }

#define CM0(RT,C,M)                               \
  void *cm_##C##_##m() {                          \
    return B(RT, C::M());                         \
  }
#define CM1(RT,C,M,T1,A1)                              \
  void *cm_##C##_##m(T1 A1) {                          \
    return B(RT, C::M(A1));                            \
  }
#define CM2(RT,C,M,T1,A1,T2,A2)                               \
  void *cm_##C##_##m(T1 A1, T2 A2) {                          \
    return B(RT, C::M(A1, A2));                               \
  }

#define IM0(RT,C,M)                               \
  void *im_##C##_##m(C *_this) {                  \
    return B(RT, _this->M());                     \
  }

#define IM1(RT,C,M,T1,A1)                            \
  void *im_##C##_##m(C *_this, T1 A1) {              \
    return B(RT, _this->M(), A1);                    \
  }

extern "C" {
  F0(bool,InitializeNativeTarget)
  D(PassManager)
  C0(PassManager)
  C1(EngineBuilder,Module*,m)
  CM2(IntegerTypeP,IntegerType,get,LLVMContextR,cntx,int,size)
}

extern "C" {
int main(int argc, char **argv)
{
  f_InitializeNativeTarget();

  return 0;
}
}
