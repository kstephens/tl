CF(jit_context_t,jit_context_create,PARAMS0())
CF(void,jit_context_destroy,PARAMS1(jit_context_t,context))
CF(void,jit_context_build_start,PARAMS1(jit_context_t,context))
CF(void,jit_context_build_end,PARAMS1(jit_context_t,context))

CF(jit_function_t,jit_function_create,PARAMS2(jit_context_t,context,jit_type_t,signature))

CF(jit_function_t,jit_block_get_function,PARAMS1(jit_block_t,block))
CF(jit_context_t,jit_block_get_context,PARAMS1(jit_block_t,block))
CF(jit_label_t,jit_block_get_label,PARAMS1(jit_block_t,block))
CF(jit_block_t,jit_block_next,PARAMS2(jit_function_t,func, jit_block_t,previous))
CF(jit_block_t,jit_block_previous,PARAMS2(jit_function_t,func, jit_block_t,previous))
CF(jit_block_t,jit_block_from_label,PARAMS2(jit_function_t,func, jit_label_t,label))

