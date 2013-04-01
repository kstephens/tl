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

CF(jit_value_t,jit_value_create,PARAMS2(jit_function_t,func, jit_type_t,type))
CF(jit_value_t,jit_value_create_nint_constant
   ,PARAMS3(jit_function_t,func, jit_type_t,type, jit_nint,const_value))
CF(jit_value_t,jit_value_create_long_constant
   ,PARAMS3(jit_function_t,func, jit_type_t,type, jit_long,const_value))
CF(jit_value_t,jit_value_create_float32_constant
   ,PARAMS3(jit_function_t,func, jit_type_t,type,
            jit_float32,const_value))
CF(jit_value_t,jit_value_create_float64_constant
   ,PARAMS3(jit_function_t,func, jit_type_t,type,
            jit_float64,const_value))
CF(jit_value_t,jit_value_create_nfloat_constant
   ,PARAMS3(jit_function_t,func, jit_type_t,type,
            jit_nfloat,const_value))
CF(jit_value_t,jit_value_create_constant
   ,PARAMS2(jit_function_t,func, jit_constant_tP,const_value))
CF(jit_value_t,jit_value_get_param
   ,PARAMS2(jit_function_t,func, unsigned_int,param))
CF(jit_value_t,jit_value_get_struct_pointer,PARAMS1(jit_function_t,func))
CF(int,jit_value_is_temporary,PARAMS1(jit_value_t,value))
CF(int,jit_value_is_local,PARAMS1(jit_value_t,value))
CF(int,jit_value_is_constant,PARAMS1(jit_value_t,value))
CF(int,jit_value_is_parameter,PARAMS1(jit_value_t,value))
CF(void,jit_value_ref,PARAMS2(jit_function_t,func, jit_value_t,value))
CF(void,jit_value_set_volatile,PARAMS1(jit_value_t,value))
CF(int,jit_value_is_volatile,PARAMS1(jit_value_t,value))
CF(void,jit_value_set_addressable,PARAMS1(jit_value_t,value))
CF(int,jit_value_is_addressable,PARAMS1(jit_value_t,value))
CF(jit_type_t,jit_value_get_type,PARAMS1(jit_value_t,value))
CF(jit_function_t,jit_value_get_function,PARAMS1(jit_value_t,value))
CF(jit_block_t,jit_value_get_block,PARAMS1(jit_value_t,value))
CF(jit_context_t,jit_value_get_context,PARAMS1(jit_value_t,value))
CF(jit_constant_t,jit_value_get_constant,PARAMS1(jit_value_t,value))
CF(jit_nint,jit_value_get_nint_constant,PARAMS1(jit_value_t,value))
CF(jit_long,jit_value_get_long_constant,PARAMS1(jit_value_t,value))
CF(jit_float32,jit_value_get_float32_constant,PARAMS1(jit_value_t,value))
CF(jit_float64,jit_value_get_float64_constant,PARAMS1(jit_value_t,value))
CF(jit_nfloat,jit_value_get_nfloat_constant,PARAMS1(jit_value_t,value))
CF(int,jit_value_is_true,PARAMS1(jit_value_t,value))
#if 0
CF(int jit_constant_convert
	(jit_constant_t,*result, const jit_constant_t,*value,
	 jit_type_t,type, int overflow_check))
#endif
