(let ( (context (tl_jit_context_create))
       (function #f)
       (params #f)
       (signature #f))
  (tl_jit_context_build_start context)
  (set! params (tl_jit_type_tPv 3 tl_jit_type_int))
  (set! signature (tl_jit_type_create_signature tl_jit_abi_cdecl tl_jit_type_int params 3 1))
  (set! function (tl_jit_function_create context signature))
  (let ( (x (tl_jit_value_get_param function 0))
         (y (tl_jit_value_get_param function 1))
         (z (tl_jit_value_get_param function 2)))
    (let* ( (temp1 (tl_jit_insn_mul function x y))
            (temp2 (tl_jit_insn_add function temp1 z)))
      (tl_jit_insn_return function temp2))
    )
  (tl_jit_function_compile function)
  (tl_jit_context_build_end context)
  (let ( (fp (tl_jit_function_to_closure function)))
    (let ((prim (tl_m_prim (tl_voidP_ fp) (tl_S "(jit)")))
           (f (lambda (a b c) 1)))
      (write (tl_i (f (tl_I 3) (tl_I 5) (tl_I 2))))(newline)
      ;; prints 3 * 5 + 2 => 17
      (write (tl_i (prim (tl_I 3) (tl_I 5) (tl_I 2))))(newline)
      (tl_set f 0 (tl_get prim 0))
      (write (tl_i (f (tl_I 3) (tl_I 5) (tl_I 2))))(newline)
      )
  (tl_jit_context_destroy context))
  )
