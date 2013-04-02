CF(jit_context_t,jit_context_create,PARAMS0())
CF(void,jit_context_destroy,PARAMS1(jit_context_t,context))
CF(void,jit_context_build_start,PARAMS1(jit_context_t,context))
CF(void,jit_context_build_end,PARAMS1(jit_context_t,context))

/* jit-function.h */
CF(jit_function_t,jit_function_create,PARAMS2(jit_context_t,context,jit_type_t,signature))
CF(int, jit_function_compile, PARAMS1(jit_function_t,func))
CF(voidP, jit_function_to_closure, PARAMS1(jit_function_t,func))

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

CF(jit_type_t, jit_type_copy, PARAMS1(jit_type_t,type))
CF(void, jit_type_free, PARAMS1(jit_type_t,type))
CF(jit_type_t, jit_type_create_struct
   ,PARAMS3(jit_type_tP,fields, unsigned_int,num_fields, int,incref))
CF(jit_type_t, jit_type_create_union
   ,PARAMS3(jit_type_tP,fields, unsigned_int,num_fields, int,incref))
CF(jit_type_t, jit_type_create_signature
   , PARAMS5(jit_abi_t,abi, jit_type_t,return_type, jit_type_tP,params,
             unsigned_int,num_params, int,incref))
CF(jit_type_t, jit_type_create_pointer, PARAMS2(jit_type_t,type, int,incref))
CF(jit_type_t, jit_type_create_tagged
   , PARAMS5(jit_type_t,type, int,kind, voidP,data,
                  jit_meta_free_func,free_func, int,incref))
CF(int, jit_type_set_names
   , PARAMS3(jit_type_t,type, charPP,names, unsigned_int,num_names))
CF(void, jit_type_set_size_and_alignment
   , PARAMS3(jit_type_t,type, jit_nint,size, jit_nint,alignment))
CF(void, jit_type_set_offset
   , PARAMS3(jit_type_t,type, unsigned_int,field_index, jit_nuint,offset))
CF(int, jit_type_get_kind, PARAMS1(jit_type_t,type))
CF(jit_nuint, jit_type_get_size, PARAMS1(jit_type_t,type))
CF(jit_nuint, jit_type_get_alignment, PARAMS1(jit_type_t,type))
CF(unsigned_int, jit_type_num_fields, PARAMS1(jit_type_t,type))
CF(jit_type_t, jit_type_get_field
   , PARAMS2(jit_type_t,type, unsigned_int,field_index))
CF(jit_nuint, jit_type_get_offset
   , PARAMS2(jit_type_t,type, unsigned_int,field_index))
CF(const_charP, jit_type_get_name, PARAMS2(jit_type_t,type, unsigned_int,index))
// #define	JIT_INVALID_NAME	(~((unsigned int)0))
CF(unsigned_int, jit_type_find_name, PARAMS2(jit_type_t,type, charP,name))
CF(unsigned_int, jit_type_num_params, PARAMS1(jit_type_t,type))
CF(jit_type_t, jit_type_get_return, PARAMS1(jit_type_t,type))
CF(jit_type_t, jit_type_get_param, PARAMS2(jit_type_t,type, unsigned_int,param_index))
CF(jit_abi_t, jit_type_get_abi, PARAMS1(jit_type_t,type))
CF(jit_type_t, jit_type_get_ref, PARAMS1(jit_type_t,type))
CF(jit_type_t, jit_type_get_tagged_type, PARAMS1(jit_type_t,type))
CF(void, jit_type_set_tagged_type
   ,PARAMS3(jit_type_t,type, jit_type_t,underlying, int,incref))
CF(int, jit_type_get_tagged_kind, PARAMS1(jit_type_t,type))
CF(voidP, jit_type_get_tagged_data, PARAMS1(jit_type_t,type))
CF(void, jit_type_set_tagged_data
   ,PARAMS3(jit_type_t,type, voidP,data, jit_meta_free_func,free_func))
CF(int, jit_type_is_primitive, PARAMS1(jit_type_t,type))
CF(int, jit_type_is_struct, PARAMS1(jit_type_t,type))
CF(int, jit_type_is_union, PARAMS1(jit_type_t,type))
CF(int, jit_type_is_signature, PARAMS1(jit_type_t,type))
CF(int, jit_type_is_pointer, PARAMS1(jit_type_t,type))
CF(int, jit_type_is_tagged, PARAMS1(jit_type_t,type))
CF(jit_nuint, jit_type_best_alignment, PARAMS0())
CF(jit_type_t, jit_type_normalize, PARAMS1(jit_type_t,type))
CF(jit_type_t, jit_type_remove_tags, PARAMS1(jit_type_t,type))
CF(jit_type_t, jit_type_promote_int, PARAMS1(jit_type_t,type))
CF(int, jit_type_return_via_pointer, PARAMS1(jit_type_t,type))
CF(int, jit_type_has_tag, PARAMS2(jit_type_t,type, int,kind))

/* jit-function.h */

/* isns.h */
CF(int, jit_insn_get_opcode, PARAMS1(jit_insn_t,insn))
CF(jit_value_t, jit_insn_get_dest, PARAMS1(jit_insn_t,insn))
CF(jit_value_t, jit_insn_get_value1, PARAMS1(jit_insn_t,insn))
CF(jit_value_t, jit_insn_get_value2, PARAMS1(jit_insn_t,insn))
CF(jit_label_t, jit_insn_get_label, PARAMS1(jit_insn_t,insn))
CF(jit_function_t, jit_insn_get_function, PARAMS1(jit_insn_t,insn))
CF(voidP, jit_insn_get_native, PARAMS1(jit_insn_t,insn))
CF(const_charP, jit_insn_get_name, PARAMS1(jit_insn_t,insn))
CF(jit_type_t, jit_insn_get_signature, PARAMS1(jit_insn_t,insn))
CF(int, jit_insn_dest_is_value, PARAMS1(jit_insn_t,insn))

CF(int, jit_insn_label, PARAMS2(jit_function_t,func, jit_label_tP,label))
CF(int, jit_insn_new_block, PARAMS1(jit_function_t,func))
CF(jit_value_t, jit_insn_load, PARAMS2(jit_function_t,func, jit_value_t,value))
CF(jit_value_t, jit_insn_dup, PARAMS2(jit_function_t,func, jit_value_t,value))
CF(jit_value_t, jit_insn_load_small
	, PARAMS2(jit_function_t,func, jit_value_t,value))
CF(int, jit_insn_store
   , PARAMS3(jit_function_t,func, jit_value_t,dest, jit_value_t,value))
CF(jit_value_t, jit_insn_load_relative
   , PARAMS4(jit_function_t,func, jit_value_t,value,
             jit_nint,offset, jit_type_t,type))
CF(int, jit_insn_store_relative
   , PARAMS4(jit_function_t,func, jit_value_t,dest,
             jit_nint,offset, jit_value_t,value))
CF(jit_value_t, jit_insn_add_relative
   , PARAMS3(jit_function_t,func, jit_value_t,value, jit_nint,offset))
CF(jit_value_t, jit_insn_load_elem
   , PARAMS4(jit_function_t,func, jit_value_t,base_addr,
             jit_value_t,index, jit_type_t,elem_type))
CF(jit_value_t, jit_insn_load_elem_address
   , PARAMS4(jit_function_t,func, jit_value_t,base_addr,
             jit_value_t,index, jit_type_t,elem_type))
CF(int, jit_insn_store_elem
   , PARAMS4(jit_function_t,func, jit_value_t,base_addr,
             jit_value_t,index, jit_value_t,value))
CF(int, jit_insn_check_null, PARAMS2(jit_function_t,func, jit_value_t,value))

CF(jit_value_t, jit_insn_add
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_add_ovf
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_sub
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_sub_ovf
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_mul
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_mul_ovf
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_div
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_rem
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_rem_ieee
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_neg
   , PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_and
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_or
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_xor
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_not
   , PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_shl
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_shr
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_ushr
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_sshr
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_eq
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_ne
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_lt
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_le
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_gt
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_ge
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_cmpl
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_cmpg
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_to_bool
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_to_not_bool
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_acos
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_asin
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_atan
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_atan2
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_ceil
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_cos
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_cosh
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_exp
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_floor
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_log
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_log10
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_pow
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_rint
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_round
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_sin
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_sinh
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_sqrt
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_tan
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_tanh
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_is_nan
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_is_finite
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_is_inf
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_abs
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_min
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_max
	, PARAMS3(jit_function_t,func, jit_value_t,value1, jit_value_t,value2))
CF(jit_value_t, jit_insn_sign
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(int, jit_insn_branch
   , PARAMS2(jit_function_t,func, jit_label_tP,label))
CF(int, jit_insn_branch_if
   , PARAMS3(jit_function_t,func, jit_value_t,value, jit_label_tP,label))
CF(int, jit_insn_branch_if_not
   , PARAMS3(jit_function_t,func, jit_value_t,value, jit_label_tP,label))
CF(int, jit_insn_jump_table
	, PARAMS4(jit_function_t,func, jit_value_t,value,
                  jit_label_tP,labels, unsigned_int,num_labels))
CF(jit_value_t, jit_insn_address_of
	, PARAMS2(jit_function_t,func, jit_value_t,value1))
CF(jit_value_t, jit_insn_address_of_label
   , PARAMS2(jit_function_t,func, jit_label_tP,label))
CF(jit_value_t, jit_insn_convert
	, PARAMS4(jit_function_t,func, jit_value_t,value,
                  jit_type_t,type, int,overflow_check))

#if 0
CF(jit_value_t, jit_insn_call
	(jit_function_t,func, const_charP name,
	 jit_function_t, jit_func, jit_type_t,signature,
	 jit_value_tP args, unsigned int num_args, int flags))
CF(jit_value_t, jit_insn_call_indirect
	(jit_function_t,func, jit_value_t,value, jit_type_t,signature,
	 jit_value_tP args, unsigned int num_args, int flags))
CF(jit_value_t, jit_insn_call_indirect_vtable
	(jit_function_t,func, jit_value_t,value, jit_type_t,signature,
	 jit_value_tP args, unsigned int num_args, int flags))
CF(jit_value_t, jit_insn_call_native
	(jit_function_t,func, const_charP name,
	 voidP native_func, jit_type_t,signature,
	 jit_value_tP args, unsigned int num_args, int flags))
CF(jit_value_t, jit_insn_call_intrinsic
	(jit_function_t,func, const_charP name, voidP intrinsic_func,
	 jit_intrinsic_descr_tP descriptor,
	 jit_value_t,arg1, jit_value_t,arg2))
#endif
CF(int, jit_insn_incoming_reg
   , PARAMS3(jit_function_t,func, jit_value_t,value, int,reg))
CF(int, jit_insn_incoming_frame_posn
   , PARAMS3(jit_function_t,func, jit_value_t,value, jit_nint,frame_offset))
CF(int, jit_insn_outgoing_reg
   , PARAMS3(jit_function_t,func, jit_value_t,value, int,reg))
CF(int, jit_insn_outgoing_frame_posn
   , PARAMS3(jit_function_t,func, jit_value_t,value, jit_nint,frame_offset))
CF(int, jit_insn_return_reg
   , PARAMS3(jit_function_t,func, jit_value_t,value, int,reg))
CF(int, jit_insn_setup_for_nested
   , PARAMS3(jit_function_t,func, int,nested_level, int,reg))
CF(int, jit_insn_flush_struct, PARAMS2(jit_function_t,func, jit_value_t,value))
CF(jit_value_t, jit_insn_import
	, PARAMS2(jit_function_t,func, jit_value_t,value))
CF(int, jit_insn_push, PARAMS2(jit_function_t,func, jit_value_t,value))
CF(int, jit_insn_push_ptr
	, PARAMS3(jit_function_t,func, jit_value_t,value, jit_type_t,type))
CF(int, jit_insn_set_param
   , PARAMS3(jit_function_t,func, jit_value_t,value, jit_nint,offset))
CF(int, jit_insn_set_param_ptr
	, PARAMS4(jit_function_t,func, jit_value_t,value, jit_type_t,type,
                  jit_nint,offset))
CF(int, jit_insn_push_return_area_ptr, PARAMS1(jit_function_t,func))
CF(int, jit_insn_pop_stack, PARAMS2(jit_function_t,func, jit_nint,num_items))
CF(int, jit_insn_defer_pop_stack
   , PARAMS2(jit_function_t,func, jit_nint,num_items))
CF(int, jit_insn_flush_defer_pop
   , PARAMS2(jit_function_t,func, jit_nint,num_items))
CF(int, jit_insn_return, PARAMS2(jit_function_t,func, jit_value_t,value))
CF(int, jit_insn_return_ptr
	, PARAMS3(jit_function_t,func, jit_value_t,value, jit_type_t,type))
CF(int, jit_insn_default_return, PARAMS1(jit_function_t,func))
CF(int, jit_insn_throw, PARAMS2(jit_function_t,func, jit_value_t,value))
CF(jit_value_t, jit_insn_get_call_stack, PARAMS1(jit_function_t,func))

#if 0
CF(jit_value_t, jit_insn_thrown_exception(jit_function_t,func))
CF(int, jit_insn_uses_catcher(jit_function_t,func))
CF(jit_value_t, jit_insn_start_catcher(jit_function_t,func))
CF(int, jit_insn_branch_if_pc_not_in_range
	(jit_function_t,func, jit_label_t,start_label,
	 jit_label_t,end_label, jit_label_tP label))
CF(int, jit_insn_rethrow_unhandled(jit_function_t,func))
CF(int, jit_insn_start_finally
	(jit_function_t,func, jit_label_tP finally_label))
CF(int, jit_insn_return_from_finally(jit_function_t,func))
CF(int, jit_insn_call_finally
	(jit_function_t,func, jit_label_tP finally_label))
CF(jit_value_t, jit_insn_start_filter
	(jit_function_t,func, jit_label_tP label, jit_type_t,type))
CF(int, jit_insn_return_from_filter
	, PARAMS2(jit_function_t,func, jit_value_t,value))
CF(jit_value_t, jit_insn_call_filter
	(jit_function_t,func, jit_label_t,*label,
	 jit_value_t,value, jit_type_t,type))

CF(int, jit_insn_memcpy
	(jit_function_t,func, jit_value_t,dest,
	 jit_value_t,src, jit_value_t,size))
CF(int, jit_insn_memmove
	(jit_function_t,func, jit_value_t,dest,
	 jit_value_t,src, jit_value_t,size))
CF(int, jit_insn_memset
	(jit_function_t,func, jit_value_t,dest,
	 jit_value_t,value, jit_value_t,size))
CF(jit_value_t, jit_insn_alloca
	(jit_function_t,func, jit_value_t,size))

CF(int, jit_insn_move_blocks_to_end
   (jit_function_t,func, jit_label_t,from_label, jit_label_t,to_label))
CF(int, jit_insn_move_blocks_to_start
   (jit_function_t,func, jit_label_t,from_label, jit_label_t,to_label))


CF(int, jit_insn_mark_offset
   (jit_function_t,func, jit_int,offset))
CF(int, jit_insn_mark_breakpoint
   (jit_function_t,func, jit_nint,data1, jit_nint,data2))
CF(int, jit_insn_mark_breakpoint_variable
	(jit_function_t,func, jit_value_t,data1, jit_value_t,data2))

CF(void, jit_insn_iter_init(jit_insn_iter_tP,iter, jit_block_t,block))
   CF(void, jit_insn_iter_init_last
      (jit_insn_iter_tP,iter, jit_block_t,block))
CF(jit_insn_t, jit_insn_iter_next(jit_insn_iter_tP,iter))
CF(jit_insn_t, jit_insn_iter_previous(jit_insn_iter_tP,iter))

#endif
