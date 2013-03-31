#include <stdio.h>
#include "jit/jit.h"


int main(int argc, char **argv)
{
  jit_context_t context;
  jit_function_t function;

  context = jit_context_create();
  jit_context_build_start(context);

  {
    jit_type_t params[3];
    jit_type_t signature;

    params[0] = jit_type_int;
    params[1] = jit_type_int;
    params[2] = jit_type_int;
    signature = jit_type_create_signature
      (jit_abi_cdecl, jit_type_int, params, 3, 1);
    function = jit_function_create(context, signature);
  }

  {
    jit_value_t x, y, z;
    x = jit_value_get_param(function, 0);
    y = jit_value_get_param(function, 1);
    z = jit_value_get_param(function, 2);

    {
      jit_value_t temp1, temp2;
      temp1 = jit_insn_mul(function, x, y);
      temp2 = jit_insn_add(function, temp1, z);
      jit_insn_return(function, temp2);
    }
  }

  jit_function_compile(function);
  jit_context_build_end(context);

  {
    jit_int arg1, arg2, arg3;
    void *args[3];
    jit_int result;
    jit_int (*fp) (jit_int, jit_int, jit_int);

    arg1 = 3;
    arg2 = 5;
    arg3 = 2;
    args[0] = &arg1;
    args[1] = &arg2;
    args[2] = &arg3;
    jit_function_apply(function, args, &result);
    printf("mul_add(3, 5, 2) = %d\n", (int)result);

    fp = jit_function_to_closure(function);
    result = fp(arg1, arg2, arg3);
    printf("mul_add(3, 5, 2) = %d\n", (int)result);    
  }

  jit_context_destroy(context);

  return 0;
}
