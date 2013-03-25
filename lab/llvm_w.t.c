#ifdef NO_INCLUDES
#include <stdlib.h>
#include <stdio.h>
#endif
#include "llvm_w.h"

void make_func(void **modp, void **funp)
{
  void *cntx = llvm_f_getGlobalContext();
  void *mod = llvm_c_Module_charP_LLVMContextR("test", cntx);
}

int main(int argc, char **argv)
{
  void *mod, *fun;

  llvm_f_InitializeNativeTarget();
  make_func(&mod, &fun);

  return 0;
}

