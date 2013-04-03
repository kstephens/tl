#ifndef NO_INCLUDES
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
#endif

using namespace llvm;

#define TP(X) typedef X *X##R; typedef X *X##P;
TP(LLVMContext);
TP(IntegerType);
TP(Module);
TP(PassManager);
TP(Function);
TP(BasicBlock);
typedef IRBuilder<> IRBuilderT;
TP(IRBuilderT);

extern "C" {
#include "llvm_w.h"
}

extern "C" {
#undef BODY
#define BODY(X) { X; }
#include "llvm_w_decls.h"
}

