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

extern "C" {
#include "ct/ct.h"
}

using namespace llvm;


extern "C" {
  static int uid = -1;
  void ct_llvm_init() {
    if ( uid < 0 ) {
      uid = ct_t_get_user_id();
    }
    InitializeNativeTarget();
  }

  void *ct_llvm_context() {
    return (void*) &getGlobalContext();
  }
#define cntx (*(LLVMContext*)ct_llvm_context())

  void *ct_t_llvm_Type(ct_t t) {
    Type *ty = (Type*) ct_t_user(t)[uid];
    if ( ! ty ) {
      switch ( t ) {
      case ct_t_void: ty = Type::getVoidTy(cntx); break;
      case ct_t_char:     case ct_t_uchar:
      case ct_t_short:    case ct_t_ushort:
      case ct_t_int:      case ct_t_uint:
      case ct_t_long:     case ct_t_ulong:
      case ct_t_longlong: case ct_t_ulonglong:
        ty = Type::getIntNTy(cntx, ct_t_sizeof_bits(t)); break;
      case ct_t_float:      ty = Type::getFloatTy(cntx); break;
      case ct_t_double:     ty = Type::getDoubleTy(cntx); break;
      case ct_t_longdouble: ty = Type::getX86_FP80Ty(cntx); break;
      default:
        if ( ct_t_PTRQ(t) ) {
        } else if ( ct_t_ARRAYQ(t) ) {
        } else if ( ct_t_STRUCTQ(t) ) {
        } else if ( ct_t_UNIONQ(t) ) {
        }
      }
    }
    ct_t_user(t)[uid] = (Type*) ty;
    return (void*) ty;
  }

  void *ct_llvm_Module_new(const char *name) {
    return (void*) new Module(name, cntx);
  }
  void ct_llvm_Module_delete(void *_module) {
    delete (Module*) _module;
  }
  typedef IRBuilder<> IRBuilderT;
  void *ct_llvm_Function_new(ct_t ftype, const char *func_name, const char **arg_names, void *_module) {
    Module *module = (Module*) _module;
    Constant *c = module->getOrInsertFunction((llvm::StringRef) func_name, (llvm::FunctionType*) ct_t_llvm_Type(ftype));
    Function *func = cast<Function>(c);

    if ( arg_names ) {
      Function::arg_iterator args = func->arg_begin(), args_end = func->arg_end();
      for ( int i = 0; args != args_end; ++ i ) {
        Value *x = args ++;
        if ( arg_names[i] && arg_names[0] )
          x->setName(arg_names[i]);
      }
    }

    BasicBlock* block = BasicBlock::Create(cntx, "entry", func);
    IRBuilderT *builder = new IRBuilderT(block);

    return (void*) builder;
  }
  void ct_llvm_Function_end(void *builder) {
    delete (IRBuilderT*) builder;
  }
}
