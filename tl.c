#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h> /* strtoll() */
#include <unistd.h>
typedef void *tl;
typedef size_t tlw;
typedef ssize_t tlsw;
tl tl_rt; // runtime.
#define tl_nil ((tl) 0)
#define tl_f tl_nil
#define tl_t tl_s_t
#include "gc/gc.h"
#define tl_malloc(S) GC_malloc(S)
#define tl_realloc(P,S) GC_realloc(P,S)
tl tl_allocate(tl type, size_t size)
{
  tl o = tl_malloc(size + sizeof(type));
  o += sizeof(type);
#define tl_t_(o) ((tl*)(o))[-1]
  tl_t_(o) = type;
  memset(o, 0, size);
  return o;
}
tl tl_m_type(tl name);
tl tl_m_symbol(void *x);
tl tl_m_runtime(tl parent)
{
#define tl_iv(o,n) ((tl*)(o))[n]
#define tl_(n) tl_iv(tl_rt,n)
  tl_rt = tl_allocate(0, sizeof(tl) * 100);
#define tl_t_type tl_(0)
#define tl_t_runtime tl_(1)
#define tl_t_void tl_(2)
#define tl_t_fixnum tl_(3)
#define tl_t_string tl_(4)
#define tl_t_symbol tl_(5)
#define tl_t_pair tl_(6)
#define tl_t_prim tl_(7)
#define tl_t_eos tl_(8)
#define tl_t_environment tl_(9)
#define tl_t_lambda tl_(10)
#define tl_t_if2 tl_(11)
#define tl_t_evcom3 tl_(12)
#define tl_t_define tl_(13)
#define tl_t_setE tl_(14)

#define tl_v tl_(20)
#define tl_symtab tl_(21)
#define tl_in_error tl_(25)
#define tl_eos tl_(26)
#define tl_env tl_(27)
#define tl_s_quote tl_(40)
#define tl_s_if tl_(41)
#define tl_s_lambda tl_(42)
#define tl_s__if2 tl_(43)
#define tl_s__unbound tl_(44)
#define tl_s__closure tl_(45)
#define tl_s__argval tl_(46)
#define tl_s_cons tl_(47)
#define tl_s_car tl_(48)
#define tl_s_cdr tl_(49)
#define tl_s_t tl_(50)
#define tl_s_DOT tl_(51)
#define tl_s_quasiquote tl_(52)
#define tl_s_unquote_splicing tl_(53)
#define tl_s_unquote tl_(54)
#define tl_s__callrtn tl_(55)
#define tl_s__stmt tl_(56)
#define tl_s_define tl_(57)
#define tl_s_setE tl_(58)
#define tl_s__env tl_(59)
#define tl_s__args tl_(60)

  tl_t_type = tl_m_type("type");
  tl_t_(tl_t_type) = tl_t_type;
  tl_t_runtime = tl_m_type("runtime");
  tl_t_(tl_rt) = tl_t_runtime;
  tl_t_void = tl_m_type("void");
  tl_t_fixnum = tl_m_type("fixnum");
  tl_t_string = tl_m_type("string");
  tl_t_symbol = tl_m_type("symbol");
  tl_t_pair   = tl_m_type("pair");
  tl_t_prim   = tl_m_type("prim");
  tl_t_eos    = tl_m_type("eos");
  tl_t_environment = tl_m_type("environment");
  tl_t_lambda = tl_m_type("lambda");
  tl_t_if2 = tl_m_type("if2");
  tl_t_evcom3 = tl_m_type("evcom3");
  tl_t_define = tl_m_type("define");
  tl_t_setE = tl_m_type("set!");

  tl_s_quote = tl_m_symbol("quote");
  tl_s_quasiquote = tl_m_symbol("quasiquote");
  tl_s_unquote_splicing = tl_m_symbol("unquote-splicing");
  tl_s_unquote = tl_m_symbol("unquote");
  tl_s_DOT = tl_m_symbol(".");
  tl_s_define = tl_m_symbol("define");
  tl_s_setE = tl_m_symbol("set!");
  tl_s_if = tl_m_symbol("if");
  tl_s_lambda = tl_m_symbol("lambda");
  tl_s__if2 = tl_m_symbol("&if");
  tl_s__unbound = tl_m_symbol("&unbound");
  tl_s__closure = tl_m_symbol("&closure");
  tl_s__argval = tl_m_symbol("&argval");
  tl_s_cons = tl_m_symbol("cons");
  tl_s_car = tl_m_symbol("car");
  tl_s_cdr = tl_m_symbol("cdr");
  tl_s_t = tl_m_symbol("t");
  tl_s__callrtn = tl_m_symbol("&callrtn");
  tl_s__stmt = tl_m_symbol("&stmt");
  tl_s__env = tl_m_symbol("&env");
  tl_s__args = tl_m_symbol("&args");

  tl_v = tl_allocate(tl_t_void, 0);
  tl_eos = tl_allocate(tl_t_eos, 0);
  return tl_rt;
}
tl tl_type(tl o)
{
#define _tl_type(o) (((tlsw) (o)) & 1 ? tl_t_fixnum : tl_t_(o))
  return _tl_type(o);
}
#define tl_type(o)_tl_type(o)
tl tl_m_type(tl x)
{
  tl o = tl_allocate(tl_t_type, sizeof(x));
  *(void**) o = x;
  return o;
}
tl tl_typeSET(tl o, tl t)
{
  tl_t_(o) = t;
  return o;
}
tl tl_write(tl o, tl p);
tl tl_error(tl msg, tl obj)
{
  if ( tl_in_error != tl_nil ) abort();
  tl_in_error = tl_t;
  fprintf(stderr, "\nERROR: %s: %s @%p : ", (char*)msg, (char*) tl_iv(tl_type(obj), 0), obj);
  tl_write(obj, stderr);
  fprintf(stderr, "\n");
  abort(); return 0;
}
#if 0
#define _tl_i(x) ((tl) ((((tlsw) (x)) << 1) & 1))
#define _tl_I(o) (((tlsw) (o)) >> 1)
#else
tl tl_m_fixnum(tlsw x)
{
  tl o = tl_allocate(tl_t_fixnum, sizeof(x));
  *(tlsw*) o = x;
  return o;
}
#define _tl_i(x) tl_m_fixnum(x)
#define _tl_I(o) (*(tlsw*) (o))
#endif
tl tl_i(tlsw x) { return _tl_i(x); }
tlsw tl_I(tl o) { return _tl_I(o); }
#define tl_i(x)_tl_i(x)
#define tl_I(o)_tl_I(o)
tl tl_ivar(tl o, tl i)
{
  return ((tl*) o)[tl_I(i)];
}
tl tl_set_ivar(tl o, tl i, tl v)
{
  return ((tl*) o)[tl_I(i)] = v;
}
tl tl_m_string(void *x, size_t l)
{
  tl o = tl_allocate(tl_t_string, sizeof(x) + sizeof(l));
  *(void**) o = x;
  return o;
}
#define tl_S(o) (*(void**) (o))
tl tl_type_cons(tl t, tl a, tl d)
{
  tl o = tl_allocate(t, sizeof(tl) * 2);
#define car(o) ((tl*) (o))[0]
#define cdr(o) ((tl*) (o))[1]
  car(o) = a;
  cdr(o) = d;
  return o;
}
tl tl_cons(tl a, tl d) { return tl_type_cons(tl_t_pair, a, d); }
#define cadr(o) car(cdr(o))
#define cddr(o) cdr(cdr(o))
tl tl_car(tl o) { return car(o); } tl tl_set_carE(tl o, tl v) { return car(o) = v; }
tl tl_cdr(tl o) { return cdr(o); } tl tl_set_cdrE(tl o, tl v) { return cdr(o) = v; }
#define cons tl_cons
tl tl_m_symbol(void *x)
{
  tl l = tl_symtab;
  while ( l ) {
    tl s = car(l);
#define tl_symbol_name(o) (*(tl*) o)
    if ( strcmp(tl_S(tl_symbol_name(s)), x) == 0 )
      return s;
    l = cdr(l);
  }
  tl o = tl_allocate(tl_t_symbol, sizeof(tl));  
  tl_symbol_name(o) = tl_m_string(strdup(x), strlen(x));
  tl_symtab = cons(o, tl_symtab);
  return o;
}
#define tl__s(S) tl_m_symbol(S)
#define _tl_s(N)tl_m_symbol(#N)
#define tl_s(N)_tl_s(N)
tl tl_string_TO_number(tl o, int radix)
{
  long long i = 0; char *endptr = 0;
  const char *str = tl_S(o), *strend = strchr(str, '\0');
  if ( radix < 1 ) radix = 10;
  i = strtoll(str, &endptr, radix);
  if ( endptr == strend ) {
    tl o = tl_i(i);
    if ( tl_I(o) == i ) return o;
  }
  return tl_f;
}
tl tl_string__intern(tl o)
{
  return tl_m_symbol(tl_S(o));
}
tl tl_m_prim(void *f, const char *name)
{
  tl o = tl_allocate(tl_t_prim, sizeof(tl) * 2);
#define tl_FP(o,r,p) ((r(*)p)tl_iv(o, 0))
  *(void**) (o + 0) = f;
  *(void**) (o + sizeof(f)) = (void*) name;
  return o;
}
#define FP ((FILE*)p)
tl tl_port__write(tl p, tl s, tl l)
{
  fwrite(tl_S(s), tl_I(l), 1, FP);
  return p;
}
tl tl_port__read(tl p, tl s, tl l)
{
  ssize_t c = fread(tl_S(s), tl_I(l), 1, FP);
  return tl_i((long) c);
}
tl tl_string__display(tl o, tl p)
{
  return tl_port__write(p, o, tl_i(strlen(tl_S(o))));
}
tl tl_string__write(tl o, tl p)
{
  fwrite("\"", 1, 1, FP);
  tl_string__display(o, p);
  fwrite("\"", 1, 1, FP);
  return p;
}
tl tl_fixnum__write(tl o, tl p)
{
  fprintf(FP, "%lld", (long long) tl_I(o));
  return p;
}
tl tl_symbol__write(tl o, tl p)
{
  return tl_string__display(tl_symbol_name(o), p);
}
tl tl_type__write(tl o, tl p)
{
  fprintf(FP, "#<%s %s @%p>", (char*) tl_iv(tl_type(o), 0), (char*) tl_iv(o, 0), o);
  return p;
}
tl tl_prim__write(tl o, tl p)
{
  fprintf(FP, "#<prim %s @%p @%p>", (char*) tl_iv(o, 1), o, tl_iv(o, 0));
  return p;
}
tl tl__write(tl o, tl p, tl op);
tl tl_pair__write(tl o, tl p, tl op)
{
  fwrite("(", 1, 1, FP);
  if ( ! o ) goto rtn;
 again:
  if ( tl_type(o) == tl_t_pair ) {
    tl__write(car(o), p, op);
    o = cdr(o);
    if ( ! o ) goto rtn;
    fwrite(" ", 1, 1, FP);
    goto again;
  }
  fwrite(". ", 2, 1, FP);
  tl__write(o, p, op);
 rtn:
  fwrite(")", 1, 1, FP);
  return p;
}
tl tl__write(tl o, tl p, tl op)
{
  if ( o == tl_nil )
    return tl_pair__write(o, p, op);
  if ( tl_type(o) == tl_t_fixnum )
    return tl_fixnum__write(o, p);
  if ( tl_type(o) == tl_t_string )
    return (op != tl_nil ? tl_string__write : tl_string__display)(o, p);
  if ( tl_type(o) == tl_t_symbol )
    return tl_symbol__write(o, p);
  if ( tl_type(o) == tl_t_pair )
    return tl_pair__write(o, p, op);
  if ( tl_type(o) == tl_t_type )
    return tl_type__write(o, p);
  if ( tl_type(o) == tl_t_prim )
    return tl_prim__write(o, p);
  fprintf(FP, "#<%s @%p>", (char*) tl_iv(tl_type(o), 0), o);
  return p;
}
tl tl_display(tl o, tl p) { return tl__write(o, p, (tl) 0); }
tl tl_write(tl o, tl p) { return tl__write(o, p, (tl) 1); }
#undef FP
tl tl_bind(tl vars, tl args, tl env)
{
  // if ( length(vars) != length(args) ) error
  return cons(tl_typeSET(cons(vars, args), tl_t_environment), env);
}
tl tl_let(tl var, tl val, tl env)
{
  if ( env == tl_nil )
    env = tl_bind(tl_nil, tl_nil, env);
  tl vv = car(env);
  car(vv) = cons(var, car(vv));
  cdr(vv) = cons(val, cdr(vv));
  return env;
}
tl tl_define(tl var, tl val, tl env)
{
  while ( env && cdr(env) )
    env = cdr(env);
  return tl_let(var, val, env);
}
tl tl_eqQ(tl x, tl y)
{
  return x == y ? tl_t : tl_f;
}
tl tl_eqvQ(tl x, tl y)
{
  if ( tl_type(x) == tl_t_fixnum && tl_type(y) == tl_t_fixnum )
#define tl_b(x) ((x) ? tl_t : tl_f)
    return tl_b(tl_I(x) == tl_I(y));
  return tl_eqQ(x, y);
}
tl tl_lookup(tl name, tl env)
{
  while ( env ) {
    tl vv = car(env);
    tl vars = car(vv), vals = cdr(vv);
    while ( vars ) {
      if ( vars == name )
        return cons(vals, tl_nil); // restarg hack.
      if ( car(vars) == name )
        return vals;
      vars = cdr(vars);
      vals = cdr(vals);
    }
    env = cdr(env);
  }
  return tl_s__unbound;
}
tl tl_value(tl name, tl env)
{
  tl slot = tl_lookup(name, env);
  if ( slot == tl_s__unbound )
    return tl_error("unbound", name);
  return car(slot);
}
tl tl_setE(tl name, tl val, tl env)
{
  tl slot = tl_lookup(name, env);
  if ( slot == tl_s__unbound )
    return tl_error("unbound", name);
  return car(slot) = val;
}
int tl_eval_debug;
#define tl_eval_debug 1
tl tl_eval(tl exp, tl env)
{
  tl val = tl_nil, args = tl_nil, argp = tl_nil, clink = tl_nil;
  if ( tl_eval_debug ) {
    fprintf(stderr, "\n  eval:");
    fprintf(stderr, "\n    env => ");
    tl_write(env, stderr);
    fprintf(stderr, "\n    exp => ");
    tl_write(exp, stderr);
    tl_write(tl_type(exp), stderr);
    fprintf(stderr, "\n");
  }
#define pop(x)  x = car(clink); clink = cdr(clink)
#define tpush(t,x) clink = tl_type_cons(t, x, clink)
#define push(x) clink = cons(x, clink)
#define L(N) N:                           \
  if ( tl_eval_debug ) {                  \
  fprintf(stderr, "    %s:", #N);         \
  fprintf(stderr, "\n      exp   => ");   \
  tl_write(exp, stderr);            \
  fprintf(stderr, "\n      val   => ");   \
  tl_write(val, stderr);            \
  fprintf(stderr, "\n      args  => ");   \
  tl_write(args, stderr);           \
  fprintf(stderr, "\n      clink => ");   \
  tl_write(clink, stderr);          \
  fprintf(stderr, "\n      env   => ");   \
  tl_write(env, stderr);            \
  fprintf(stderr, "\n");                  \
  }
#define G(N) do {                             \
    if ( tl_eval_debug )                      \
      fprintf(stderr, "      goto %s\n", #N); \
      goto N;                                 \
    } while(0)

  L(eval);
  if ( exp == tl_nil )
    { val = exp; G(rtn); }
  if ( tl_type(exp) == tl_t_pair ) G(evcomb);
  if ( tl_type(exp) == tl_t_symbol ) {
    if ( exp == tl_s__env ) { val = env; G(rtn); }
    if ( exp == tl_s__args ) { val = args; G(rtn); }
    val = tl_value(exp, env); 
    G(rtn);
  }

  L(self);
  val = exp; 
  G(rtn);

  L(if1);
  val = cddr(exp);
  push(env);
  tpush(tl_t_if2, val);
  exp = cadr(exp);
  G(eval);

  L(if2);
  pop(exp);
  pop(env);
  if ( val == tl_f )
    exp = (exp = cdr(exp)) != tl_nil ? car(exp) : tl_v;
  else
    exp = car(exp);
  G(eval);

  L(evcomb);
  args = argp = tl_nil;

  L(evcom1);
  if ( car(exp) == tl_s_quote )
    { val = car(cdr(exp)); G(rtn); }
  if ( car(exp) == tl_s_if ) G(if1);
  if ( car(exp) == tl_s_lambda ) G(proc);
  if ( car(exp) == tl_s_define ) G(define);
  if ( car(exp) == tl_s_setE ) G(setE);
  //  if ( car(exp) == tl__s("&debug") )
  //   { tl_eval_debug = 1; G(rtn); }

  L(evcom2);
  push(env);
  push(args);
  push(argp);
  val = cdr(exp);
  tpush(tl_t_evcom3, val);
  exp = car(exp);
  G(eval);

  L(evcom3);
  pop(exp);
  pop(argp);
  pop(args);
  pop(env);
  if ( argp != tl_nil )
    argp = cdr(argp) = cons(val, tl_nil);
  else
    args = argp = cons(val, tl_nil);
  G(evcom1);

  L(call);
  val = car(args);
  args = cdr(args);
  if ( tl_type(val) == tl_t_prim ) G(callprim);

  L(callclosure);
  // val = ((params . body) . env)
  env = tl_bind(car(car(val)), args, cdr(val));
  exp = cdr(car(val));
  val = tl_nil;

  L(proc);
  val = tl_type_cons(tl_t_lambda, cdr(exp), env); 
  G(rtn);
  
  L(callprim);
  if ( args == tl_nil )
    val = tl_FP(val,tl,())();
  else if ( cdr(args) == tl_nil )
    val = tl_FP(val,tl,(tl))(car(args));
  else if ( cddr(args) == tl_nil )
    val = tl_FP(val,tl,(tl,tl))(car(args), cadr(args));
  else if ( cdr(cddr(args)) == tl_nil )
    val = tl_FP(val,tl,(tl,tl,tl))(car(args), cadr(args), car(cddr(args)));
  else if ( cdr(cdr(cddr(args))) == tl_nil )
    val = tl_FP(val,tl,(tl,tl,tl,tl))(car(args), cadr(args), car(cddr(args)), car(cdr(cddr(args))));
  else
    tl_error("too many args", val);
  pop(args);
  G(rtn);

  L(define);
  tpush(tl_t_define, cadr(exp));
  exp = cadr(cdr(exp));
  G(eval);

  L(define_);
  pop(exp);
  env = tl_define(exp, val, env);
  val = exp;
  G(rtn);

  L(setE);
  tpush(tl_s_setE, cadr(exp));
  exp = cadr(cdr(exp));
  G(eval);

  L(setE_);
  pop(exp);
  tl_setE(exp, val, env);
  G(rtn);

  L(rtn);
  if ( clink == tl_nil )
    return val;
  if ( tl_t_(clink) == tl_t_if2 )
    G(if2);
  if ( tl_t_(clink) == tl_t_evcom3 )
    G(evcom3);
  if ( tl_t_(clink) == tl_t_define )
    G(define_);
  if ( tl_t_(clink) == tl_t_setE )
    G(setE_);
  abort();
}
tl tl_eval_print(tl expr, tl env, tl out)
{
  if ( out ) { tl_write(expr, stdout); fprintf(stdout, " => \n"); }
  tl val = tl_eval(expr, env);
  if ( out ) { tl_write(val, stdout); fprintf(stdout, "\n"); }
  return val;
}
#define VALUE tl
#define READ_DECL tl tl_read(tl stream)
#define READ_CALL() tl_read(stream)
#define FP(stream) ((FILE*)stream)
#define GETC(stream) getc(FP(stream))
#define UNGETC(stream,c) ungetc(c, FP(stream))
#define EQ(X,Y) ((X) == (Y))
#define NIL tl_nil
#define EOS tl_eos
#define CONS cons
#define CAR car
#define T tl_t
#define F tl_f
#define SET_CDR(C,R) cdr(C) = (R)
#define MAKE_CHAR(I) tl_i(I)
#define LIST_2_VECTOR(X) X
#define STRING(S,L) tl_m_string((S), (L))
#define SYMBOL_DOT tl_s_DOT
#define SYMBOL(N) tl_s_##N
#define STRING_2_NUMBER(s, radix) tl_string_TO_number(s, radix)
#define STRING_2_SYMBOL(s) tl_string__intern(s)
#define ERROR(msg,args...) tl_error(msg, #args)
#define MALLOC(S) tl_malloc(S)
#define REALLOC(P,S) tl_realloc(P,S)
#include "lispread.c"
tl tl_repl(tl env, tl in, tl out, tl prompt)
{
  tl expr, val;
 again:
  if ( prompt ) fputs("> ", (FILE*)prompt);
  if ( (expr = tl_read(in)) != tl_eos ) {
    val = tl_eval_print(expr, env, out);
    goto again;
  }
  return val;
}
#define ITYPE(T,N)                                                      \
  tl tl_##N##_get(tl ptr) { return (tl) (tlw) *(T*)ptr; }      \
  tl tl_##N##_set(tl ptr, tl word) { return (tl) (tlw) (*((T*)ptr) = (size_t)(T)word); } \
  tl tl_##N##_sizeof(TLP0) { return tl_i((tlw) sizeof(T)); }
#define FTYPE(T,N)
// ITYPE(tl,tl)
ITYPE(tlw,tlw)
ITYPE(tlsw,tlsw)
#include "ctypes.h"
#define BOP(O,N) \
  tl tl_fixnum_##N(tl x, tl y) { return tl_i(tl_I(x) O tl_I(y)); }  \
  tl tl_word_##N(tl x, tl y) { return (tl) (((tlw) x) O ((tlw) y)); }
#define ROP(O,N)                                                        \
  tl tl_fixnum_##N(tl x, tl y) { return (tl_I(x) O tl_I(y)) ? tl_t : tl_f; } \
  tl tl_word_##N(tl x, tl y) { return (tl) (((tlw) x) O ((tlw) y)); }
#define UOP(O,N) \
  tl tl_fixnum_##N(tl x) { return tl_i(O tl_I(x)); }  \
  tl tl_word_##N(tl x) { return (tl) (O ((tlw) x)); }
#include "cops.h"
tl tl_stdenv(tl env)
{
#define D(N,V) env = tl_let(tl_s(N), V, env)
  D(t, tl_s(t));
  D(nil, tl_nil);
#define V(N) D(N,tl_##N)
  V(eos);
  D(_stdin,stdin); D(_stdout,stdout); D(_stderr,stderr);
#define P(N) D(N, tl_m_prim(N, #N))
  P(tl_m_type); P(tl_type); P(tl_typeSET);
  P(tl_i); P(tl_I);
  P(tl_ivar); P(tl_set_ivar);
  P(tl_eqQ); P(tl_eqvQ);
  P(tl_type_cons); P(tl_cons); 
  P(tl_car); P(tl_cdr);  P(tl_set_carE); P(tl_set_cdrE);
  P(tl_eval);  P(tl_repl);
  P(fopen); P(fclose); P(fflush); P(fputs); P(fputc); P(fgetc); P(fseek); 
  P(fdopen); P(fileno); P(isatty), P(ttyname); P(ttyslot);
  P(tl_read); P(tl__write);
  P(GC_malloc); P(GC_realloc);
#define ITYPE(T,N) P(tl_##N##_get); P(tl_##N##_set); P(tl_##N##_sizeof);
#define FTYPE(T,N)
#include "ctypes.h"
#define BOP(O,N) P(tl_fixnum_##N); P(tl_word_##N);
#define UOP(O,N) BOP(O,N)
#define ROP(O,N) BOP(O,N)
#include "cops.h"
  {
    FILE *fp;
    if ( (fp = fopen("boot.scm", "r")) ) {
      tl_repl(env, fp, 0, 0); 
      fclose(fp);
    }
  }
  return env;
}

int main(int argc, char **argv)
{
  tl tl_rt = tl_m_runtime(0);
  tl env = tl_stdenv(tl_nil);
  tl expr, val;

  // fprintf(stdout, "env =>\n  "); tl_write(env, stdout); fprintf(stdout, "\n");
  tl_repl(env, stdin, stdout, stdout);

  return 0;
}


