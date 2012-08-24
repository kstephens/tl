  tl expr, val;

  expr = cons(tl_s_quote, cons(a, tl_nil));
  val = tl_eval_print(TL expr, env);

  expr = cons(tl_s_quote, cons(cons(a, b), tl_nil));
  val = tl_eval_print(TL expr, env);

  expr = tl_s_cons;
  val = tl_eval_print(TL expr, env);

  expr = cons(tl_s_car, cons(cons(tl_s_quote, cons(expr, tl_nil)), tl_nil));
  val = tl_eval_print(TL expr, env);

  expr = cons(tl_s_cons, 
              cons(
                   cons(tl_s_quote, cons(a, tl_nil)),
                   cons(
                        cons(tl_s_quote, cons(b, tl_nil)),
                        tl_nil)));
  val = tl_eval_print(TL expr, env);

  expr = cons(cons(tl_s_lambda, 
                   cons(cons(a, cons(b, tl_nil)),
                        cons(cons(tl_s_cons, cons(a, cons(b, tl_nil))),
                             tl_nil))),
              cons(tl_i(1),
                   cons(tl_i(2),
                        tl_nil)));
  val = tl_eval_print(TL expr, env);
  
