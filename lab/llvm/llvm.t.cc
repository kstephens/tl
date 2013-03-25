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

static
void make_func(Module** modp, Function **funp);

int main(int argc, char**argv)
{
  Module* mod;
  Function *fun;

  InitializeNativeTarget();

  make_func(&mod, &fun);

  verifyModule(*mod, PrintMessageAction);

  PassManager pm;
  //  pm.add(createPrintModulePass(&outs()));
#if 0
  pm.add(new TargetData(mod));
  pm.add(createVerifierPass());
  pm.add(createLowerSetJmpPass());
  pm.add(createRaiseAllocationsPass());
  pm.add(createCFGSimplificationPass());
  pm.add(createPromoteMemoryToRegisterPass());
  pm.add(createGlobalOptimizerPass());
  pm.add(createGlobalDCEPass());
  pm.add(createFunctionInliningPass()); 
#endif
  pm.run(*mod);

  // Setup for JIT
  // ExistingModuleProvider* mp = new ExistingModuleProvider(mod);
  // ExecutionEngine* engine = ExecutionEngine::create(mp);
  std::string errStr;
  ExecutionEngine *ee =
    EngineBuilder(mod)
    .setErrorStr(&errStr)
    .setEngineKind(EngineKind::JIT)
    .create();

  if (!ee) {
    errs() << argv[0] << ": Failed to construct ExecutionEngine: " << errStr
           << "\n";
    return 1;
  }

  // Show us what we've created!
  // std::cout << "Created\n" << *mod;

  // Have our function JIT'd into machine code and return. We cast it to a particular C function pointer signature so we can call in nicely.
  int (*fp)(int, int, int) = (int (*)(int, int, int)) ee->getPointerToFunction(fun);

  // Call what we've created!
  int result = fp(2, 3, 5);
  std::cout << "fp(2, 3, 5) => " << result << "\n";

  delete mod;

  return 0;
}

static
void make_func(Module** modp, Function **funcp)
{
  int int_size = sizeof(int) * 8;

  // Module Construction
  LLVMContext &cntx = getGlobalContext();
  Module* mod = new Module("test", cntx);
  *modp = mod;

  /*
Exciting, isn’t it!? All we’re doing here is instantiating a module and giving it a name. The name isn’t particularly important unless you’re going to be dealing with multiple modules at once.
  */

  Constant* c = mod->getOrInsertFunction("func",
                                         IntegerType::get(cntx, int_size), /* ret type */
                                         IntegerType::get(cntx, int_size), /* args */
                                         IntegerType::get(cntx, int_size),
                                         IntegerType::get(cntx, int_size),
  /*varargs terminated with null*/       NULL);
  
  Function* func = cast<Function>(c);
  *funcp = func;
  func->setCallingConv(CallingConv::C);

  /*
We construct our Function by calling getOrInsertFunction() on our module, passing in the name, return type, and argument types of the function. In the case of our mul_add function, that means one 32-bit integer for the return value and three 32-bit integers for the arguments.

You'll notice that getOrInsertFunction() doesn't actually return a Function*. This is because getOrInsertFunction() will return a cast of the existing function if the function already existed with a different prototype. Since we know that there's not already a mul_add function, we can safely just cast c to a Function*.

In addition, we set the calling convention for our new function to be the C calling convention. This isn’t strictly necessary, but it ensures that our new function will interoperate properly with C code, which is a good thing.
  */

  Function::arg_iterator args = func->arg_begin();
  Value* x = args++;
  x->setName("x");
  Value* y = args++;
  y->setName("y");
  Value* z = args++;
  z->setName("z");

/*
While we’re setting up our function, let's also give names to the parameters. This also isn’t strictly necessary (LLVM will generate names for them if you don’t specify them), but it’ll make looking at our output somewhat more pleasant. To name the parameters, we iterate over the arguments of our function and call setName() on them. We’ll also keep the pointer to x, y, and z around, since we’ll need them when we get around to creating instructions.

Great! We have a function now. But what good is a function if it has no body? Before we start working on a body for our new function, we need to recall some details of the LLVM IR. The IR, being an abstract assembly language, represents control flow using jumps (we call them branches), both conditional and unconditional. The straight-line sequences of code between branches are called basic blocks, or just blocks. To create a body for our function, we fill it with blocks:
*/

  BasicBlock* block = BasicBlock::Create(getGlobalContext(), "entry", func);
  IRBuilder<> builder(block);

  /*
We create a new basic block, as you might expect, by calling its constructor. All we need to tell it is its name and the function to which it belongs. In addition, we’re creating an IRBuilder object, which is a convenience interface for creating instructions and appending them to the end of a block. Instructions can be created through their constructors as well, but some of their interfaces are quite complicated. Unless you need a lot of control, using IRBuilder will make your life simpler.
  */

  Value* tmp = builder.CreateBinOp(Instruction::Add,
                                   x, y, "tmp");
  Value* tmp2 = builder.CreateBinOp(Instruction::Mul,
                                    tmp, z, "tmp2");

  builder.CreateRet(tmp2);
}

