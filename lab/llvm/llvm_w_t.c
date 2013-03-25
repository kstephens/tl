#ifdef NO_INCLUDES
#include <stdlib.h>
#include <stdio.h>
#endif
#include "llvm_w.h"

static
void make_func(void **modp, void **funp)
{
  int int_size = sizeof(int) * 8;

  void *cntx = llvm_f_getGlobalContext();
  void *mod = llvm_c_Module_charP_LLVMContextR("test", cntx);
  *modp = mod;

}

int main_c(int arg, char **argv)
{
  void *mod, *fun;

  llvm_f_InitializeNativeTarget();
  make_func(&mod, &fun);

  void *pm = llvm_c_PassManager(); 

  return 0;
}

