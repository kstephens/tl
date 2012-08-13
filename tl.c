#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef void *tl;
// Thread-safe
#define TLT0 tl
#define TLT tl,
#define TLP tl tl_rt,
#define TLP0 tl tl_rt
#define TL tl_rt,
#define TL0 tl_rt

#define tl_nil ((tl) 0)
#define tl_f tl_nil
#define tl_t tl_s_t
#include "gc/gc.h"
#define tl_malloc(S) GC_malloc(S)
#define tl_realloc(P,S) GC_realloc(P,S)
tl tl_allocate(TLP tl type, size_t size)
{
  tl o = tl_malloc(size + sizeof(type));
  o += sizeof(type);
#define tl_t_(o) ((tl*)(o))[-1]
  tl_t_(o) = type;
#define tl_type(o) (((ssize_t) (o)) & 1 ? tl_t_fixnum : tl_t_(o))
  memset(o, 0, size);
  return o;
}
tl tl_m_type(TLP tl name);
tl tl_m_symbol(TLP void *x);
tl tl_m_port(TLP FILE *x);
tl tl_m_runtime(TLP tl parent)
{
#define tl_iv(o,n) ((tl*)(o))[n]
#define tl_(n) tl_iv(tl_rt,n)
  tl_rt = tl_allocate(TL 0, sizeof(tl) * 100);
#define tl_t_type tl_(0)
#define tl_t_runtime tl_(1)
#define tl_t_void tl_(2)
#define tl_t_fixnum tl_(3)
#define tl_t_string tl_(4)
#define tl_t_symbol tl_(5)
#define tl_t_pair tl_(6)
#define tl_t_prim tl_(7)
#define tl_t_port tl_(8)
#define tl_t_eos tl_(9)
#define tl_t_lambda tl_(10)
#define tl_v tl_(20)
#define tl_symtab tl_(21)
#define tl_stdin tl_(22)
#define tl_stdout tl_(23)
#define tl_stderr tl_(24)
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

  tl_t_type = tl_m_type(TL "type");
  tl_t_(tl_t_type) = tl_t_type;
  tl_t_runtime = tl_m_type(TL "runtime");
  tl_t_(tl_rt) = tl_t_runtime;
  tl_t_void = tl_m_type(TL "void");
  tl_t_fixnum = tl_m_type(TL "fixnum");
  tl_t_string = tl_m_type(TL "string");
  tl_t_symbol = tl_m_type(TL "symbol");
  tl_t_pair   = tl_m_type(TL "pair");
  tl_t_prim   = tl_m_type(TL "prim");
  tl_t_port   = tl_m_type(TL "port");
  tl_t_eos    = tl_m_type(TL "eos");
  tl_t_lambda = tl_m_type(TL "lambda");

  tl_s_quote = tl_m_symbol(TL "quote");
  tl_s_quasiquote = tl_m_symbol(TL "quasiquote");
  tl_s_unquote_splicing = tl_m_symbol(TL "unquote-splicing");
  tl_s_unquote = tl_m_symbol(TL "unquote");
  tl_s_DOT = tl_m_symbol(TL ".");
  tl_s_define = tl_m_symbol(TL "define");
  tl_s_setE = tl_m_symbol(TL "set!");
  tl_s_if = tl_m_symbol(TL "if");
  tl_s_lambda = tl_m_symbol(TL "lambda");
  tl_s__if2 = tl_m_symbol(TL "&if");
  tl_s__unbound = tl_m_symbol(TL "&unbound");
  tl_s__closure = tl_m_symbol(TL "&closure");
  tl_s__argval = tl_m_symbol(TL "&argval");
  tl_s_cons = tl_m_symbol(TL "cons");
  tl_s_car = tl_m_symbol(TL "car");
  tl_s_cdr = tl_m_symbol(TL "cdr");
  tl_s_t = tl_m_symbol(TL "t");
  tl_s__callrtn = tl_m_symbol(TL "&callrtn");
  tl_s__stmt = tl_m_symbol(TL "&stmt");
  tl_s__env = tl_m_symbol(TL "&env");
  tl_s__args = tl_m_symbol(TL "&args");

  tl_v = tl_allocate(TL tl_t_void, 0);
  tl_eos = tl_allocate(TL tl_t_eos, 0);
  tl_stdin = tl_m_port(TL stdin);
  tl_stdout = tl_m_port(TL stdout);
  tl_stderr = tl_m_port(TL stderr);
  return tl_rt;
}
tl tl_m_type(TLP tl x)
{
  tl o = tl_allocate(TL tl_t_type, sizeof(x));
  *(void**) o = x;
  return o;
}
tl tl_write(TLP tl o, tl p);
tl tl_error(TLP tl msg, tl obj)
{
  if ( tl_in_error != tl_nil ) abort();
  tl_in_error = tl_t;
  fprintf(stderr, "\nERROR: %s: %s @%p : ", msg, tl_iv(tl_type(obj), 0), obj);
  tl_write(TL obj, tl_stderr);
  fprintf(stderr, "\n");
  abort(); return 0;
}
#if 0
#define tl_i(x) ((tl) ((((ssize_t) (x)) << 1) & 1))
#define tl_I(o) (((ssize_t) (o)) >> 1)
#else
tl tl_m_fixnum(TLP ssize_t x)
{
  tl o = tl_allocate(TL tl_t_fixnum, sizeof(x));
  *(ssize_t*) o = x;
  return o;
}
#define tl_i(x) tl_m_fixnum(TL x)
#define tl_I(o) (*(ssize_t*) (o))
#endif
tl tl_m_string(TLP void *x, size_t l)
{
  tl o = tl_allocate(TL tl_t_string, sizeof(x) + sizeof(l));
  *(void**) o = x;
  return o;
}
#define tl_S(o) (*(void**) (o))
tl tl_m_pair(TLP tl a, tl d)
{
  tl o = tl_allocate(TL tl_t_pair, sizeof(tl) * 2);
#define car(o) ((tl*) (o))[0]
#define cdr(o) ((tl*) (o))[1]
  car(o) = a;
  cdr(o) = d;
  return o;
}
#define cadr(o) car(cdr(o))
#define cddr(o) cdr(cdr(o))
tl tl_pair__car(TLP tl o) { return car(o); }
tl tl_pair__cdr(TLP tl o) { return cdr(o); }
#define cons(a, r) tl_m_pair(TL a, r)
tl tl_m_symbol(TLP void *x)
{
  tl l = tl_symtab;
  while ( l ) {
    tl s = car(l);
#define tl_symbol_name(o) (*(tl*) o)
    if ( strcmp(tl_S(tl_symbol_name(s)), x) == 0 )
      return s;
    l = cdr(l);
  }
  tl o = tl_allocate(TL tl_t_symbol, sizeof(tl));  
  tl_symbol_name(o) = tl_m_string(TL strdup(x), strlen(x));
  tl_symtab = cons(o, tl_symtab);
  return o;
}
#define tl__s(S) tl_m_symbol(TL S)
#define tl_s(N) tl_m_symbol(TL #N)
tl tl_string__string_TO_number(TLP tl o)
{
  long long i = 0;
  if ( sscanf(tl_S(o), "%lld", &i) == 1 )
    return tl_i(i);
  return tl_f;
}
tl tl_string__intern(TLP tl o)
{
  return tl_m_symbol(TL tl_S(o));
}
tl tl_m_prim(TLP void *f, const char *name, int na)
{
  tl o = tl_allocate(TL tl_t_prim, sizeof(f) + sizeof(na));
#define tl_FP(o,r,p) ((r(*)p)tl_iv(o, 0))
  *(void**) (o + 0) = f;
  *(void**) (o + sizeof(f)) = (void*) name;
  *(ssize_t*) (o + sizeof(f) + sizeof(name)) = na;
  return o;
}
tl tl_m_port(TLP FILE *x)
{
  tl p = tl_allocate(TL tl_t_port, sizeof(x));
#define FP *(FILE**)p
  FP = x;
  return p;
}
tl tl_open(TLP tl fn, tl mode)
{
  FILE *fp = fopen(tl_S(fn), tl_S(mode));
  return fp ? tl_m_port(TL fp) : tl_nil;
}
tl tl_close(TLP tl p)
{
  fclose(FP);
  FP = 0;
  return p;
}
tl tl_puts(TLP tl p, void *s)
{
  fwrite(s, strlen(s), 1, FP);
  fflush(FP);
  return p;
}
tl tl_port__write(TLP tl p, tl s, tl l)
{
  fwrite(tl_S(s), tl_I(l), 1, FP);
  return p;
}
tl tl_port__read(TLP tl p, tl s, tl l)
{
  ssize_t c = fread(tl_S(s), tl_I(l), 1, FP);
  return tl_i((long) c);
}
tl tl_newline(TLP tl p)
{
  return tl_puts(TL p, "\n");
}
tl tl_string__display(TLP tl o, tl p)
{
  return tl_port__write(TL p, o, tl_i(strlen(tl_S(o))));
}
tl tl_string__write(TLP tl o, tl p)
{
  fwrite("\"", 1, 1, FP);
  tl_string__display(TL o, p);
  fwrite("\"", 1, 1, FP);
  return p;
}
tl tl_fixnum__write(TLP tl o, tl p)
{
  fprintf(FP, "%lld", (long long) tl_I(o));
  return p;
}
tl tl_symbol__write(TLP tl o, tl p)
{
  return tl_string__display(TL tl_symbol_name(o), p);
}
tl tl_type__write(TLP tl o, tl p)
{
  fprintf(FP, "#<%s %s @%p>", tl_iv(tl_type(o), 0), tl_iv(o, 0), o);
  return p;
}
tl tl_prim__write(TLP tl o, tl p)
{
  fprintf(FP, "#<prim %s @%p @%p>", tl_iv(o, 1), o, tl_iv(o, 0));
  return p;
}
tl tl__write(TLP tl o, tl p, tl op);
tl tl_pair__write(TLP tl o, tl p, tl op)
{
  fwrite("(", 1, 1, FP);
  if ( ! o ) goto rtn;
 again:
  if ( tl_type(o) == tl_t_pair ) {
    tl__write(TL car(o), p, op);
    o = cdr(o);
    if ( ! o ) goto rtn;
    fwrite(" ", 1, 1, FP);
    goto again;
  }
  fwrite(". ", 2, 1, FP);
  tl__write(TL o, p, op);
 rtn:
  fwrite(")", 1, 1, FP);
  return p;
}
tl tl__write(TLP tl o, tl p, tl op)
{
  if ( o == tl_nil )
    return tl_pair__write(TL o, p, op);
  if ( tl_type(o) == tl_t_fixnum )
    return tl_fixnum__write(TL o, p);
  if ( tl_type(o) == tl_t_string )
    return (op != tl_nil ? tl_string__write : tl_string__display)(TL o, p);
  if ( tl_type(o) == tl_t_symbol )
    return tl_symbol__write(TL o, p);
  if ( tl_type(o) == tl_t_pair )
    return tl_pair__write(TL o, p, op);
  if ( tl_type(o) == tl_t_type )
    return tl_type__write(TL o, p);
  if ( tl_type(o) == tl_t_prim )
    return tl_prim__write(TL o, p);
  fprintf(FP, "#<%s @%p>", tl_iv(tl_type(o), 0), o);
  return p;
}
tl tl_display(TLP tl o, tl p) { return tl__write(TL o, p, (tl) 0); }
tl tl_write(TLP tl o, tl p) { return tl__write(TL o, p, (tl) 1); }
#undef FP
tl tl_bind(TLP tl vars, tl args, tl env)
{
  // if ( length(vars) != length(args) ) error
  return cons(cons(vars, args), env);
}
tl tl_let(TLP tl var, tl val, tl env)
{
  if ( ! env )
    env = cons(cons(tl_nil, tl_nil), env);
  tl vv = car(env);
  car(vv) = cons(var, car(vv));
  cdr(vv) = cons(val, cdr(vv));
  return env;
}
tl tl_define(TLP tl var, tl val, tl env)
{
  while ( env && cdr(env) )
    env = cdr(env);
  return tl_let(TL var, val, env);
}
tl tl_eqQ(TLP tl x, tl y)
{
  return x == y ? tl_t : tl_f;
}
tl tl_eqvQ(TLP tl x, tl y)
{
  if ( tl_type(x) == tl_t_fixnum && tl_type(y) == tl_t_fixnum )
    return tl_I(x) == tl_I(y) ? tl_t : tl_f;
  return tl_eqQ(TL x, y);
}
tl tl_lookup(TLP tl name, tl env)
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
tl tl_value(TLP tl name, tl env)
{
  tl slot = tl_lookup(TL name, env);
  if ( slot == tl_s__unbound )
    return tl_error(TL "unbound", name);
  return car(slot);
}
tl tl_setE(TLP tl name, tl val, tl env)
{
  tl slot = tl_lookup(TL name, env);
  if ( slot == tl_s__unbound )
    return tl_error(TL "unbound", name);
  return car(slot) = val;
}
int tl_eval_debug;
#define tl_eval_debug 0
tl tl_eval(TLP tl exp, tl env)
{
  tl val = tl_nil, args = tl_nil, clink = tl_nil;
  if ( tl_eval_debug ) {
    fprintf(stderr, "\n  eval:");
    fprintf(stderr, "\n    env => ");
    tl_write(TL env, tl_stderr);
    fprintf(stderr, "\n    exp => ");
    tl_write(TL exp, tl_stderr);
    tl_write(TL tl_type(exp), tl_stderr);
    fprintf(stderr, "\n");
  }
#define pop(x)  x = car(clink); clink = cdr(clink)
#define push(x) clink = cons(x, clink)
#define L(N) N:                           \
  if ( tl_eval_debug ) {                  \
  fprintf(stderr, "    %s:", #N);         \
  fprintf(stderr, "\n      exp   => ");   \
  tl_write(TL exp, tl_stderr);            \
  fprintf(stderr, "\n      val   => ");   \
  tl_write(TL val, tl_stderr);            \
  fprintf(stderr, "\n      args  => ");   \
  tl_write(TL args, tl_stderr);           \
  fprintf(stderr, "\n      clink => ");   \
  tl_write(TL clink, tl_stderr);          \
  fprintf(stderr, "\n      env   => ");   \
  tl_write(TL env, tl_stderr);            \
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
    val = tl_value(TL exp, env); 
    G(rtn);
  }

  L(self);
  val = exp; 
  G(rtn);

  L(if1);
  val = cddr(exp);
  push(val);
  push(tl_s__if2);
  exp = cadr(exp);
  G(eval);

  L(if2);
  pop(exp);
  if ( val == tl_f )
    exp = (exp = cdr(exp)) != tl_nil ? car(exp) : tl_v;
  else
    exp = car(exp);
  G(eval);

  L(evcomb);
  if ( car(exp) == tl_s_quote )
    { val = car(cdr(exp)); G(rtn); }
  if ( car(exp) == tl_s_if ) G(if1);
  if ( car(exp) == tl_s_lambda ) G(closure);
  if ( car(exp) == tl_s_define ) G(define);
  if ( car(exp) == tl_s_setE ) G(setE);
  //  if ( car(exp) == tl__s("&debug") )
  //   { tl_eval_debug = 1; G(rtn); }
  L(args);
  push(args);
  args = cons(tl_nil, tl_nil);
  push(args);

  L(arg);
  val = cdr(exp);
  push(val);
  push(tl_s__argval);
  exp = car(exp); 
  G(eval);

  L(argval);
  pop(exp);
  args = cdr(args) = cons(val, tl_nil);
  if ( exp ) G(arg);
  pop(args);
  args = cdr(args);

  L(call);
  val = car(args);
  args = cdr(args);
  if ( tl_type(val) == tl_t_prim ) G(callprim);

  L(callclosure);
  push(env);
  push(tl_s__callrtn);
  // val = ((params . body) . env)
  env = tl_bind(TL car(car(val)), args, cdr(val));
  exp = cdr(car(val));
  val = tl_nil;

  L(stmts);
  if ( ! exp ) G(rtn);
  val = car(exp);
  exp = cdr(exp);
  push(exp);
  push(tl_s__stmt);
  exp = val;
  G(eval);

  L(stmt);
  pop(exp);
  G(stmts);

  L(callrtn);
  pop(env);
  pop(args);
  G(rtn);

  L(closure);
  val = cons(cdr(exp), env); 
  tl_t_(val) = tl_t_lambda;
  G(rtn);
  
  L(callprim);
  if ( args == tl_nil )
    val = tl_FP(val,tl,(TLT0))(TL0);
  else if ( cdr(args) == tl_nil )
    val = tl_FP(val,tl,(TLT tl))(TL car(args));
  else if ( cddr(args) == tl_nil )
    val = tl_FP(val,tl,(TLT tl,tl))(TL car(args), cadr(args));
  else if ( cdr(cddr(args)) == tl_nil )
    val = tl_FP(val,tl,(TLT tl,tl,tl))(TL car(args), cadr(args), car(cddr(args)));
  else
    tl_error(TL "too many args", val);
  pop(args);
  G(rtn);

  L(define);
  push(cadr(exp));
  push(tl_s_define);
  exp = cadr(cdr(exp));
  G(eval);

  L(define_);
  pop(exp);
  env = tl_define(TL exp, val, env);
  val = exp;
  G(rtn);

  L(setE);
  push(cadr(exp));
  push(tl_s_setE);
  exp = cadr(cdr(exp));
  G(eval);

  L(setE_);
  pop(exp);
  tl_setE(TL exp, val, env);
  G(rtn);

  L(rtn);
  if ( clink == tl_nil )
    return val;
  pop(exp);
  if ( exp == tl_s__if2 )
    G(if2);
  if ( exp == tl_s__argval )
    G(argval);
  if ( exp == tl_s__stmt )
    G(stmt);
  if ( exp == tl_s__callrtn )
    G(callrtn);
  if ( exp == tl_s_define )
    G(define_);
  if ( exp == tl_s_setE )
    G(setE_);
  abort();
}
tl tl_eval_print(TLP tl expr, tl env)
{
  tl_write(TL expr, tl_stdout); fprintf(stdout, " => \n");
  tl val = tl_eval(TL expr, env);
  tl_write(TL val, tl_stdout); fprintf(stdout, "\n");
  return val;
}
#define VALUE tl
#define READ_DECL tl tl_read(TLP tl stream)
#define READ_CALL() tl_read(TL stream)
#define FP(stream) tl_iv(stream, 0)
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
#define STRING(S,L) tl_m_string(TL (S), (L))
#define SYMBOL_DOT tl_s_DOT
#define SYMBOL(N) tl_s_##N
#define STRING_2_NUMBER(s, radix) tl_string__string_TO_number(TL s)
#define STRING_2_SYMBOL(s) tl_string__intern(TL s)
#define ERROR(msg,args...) tl_error(TL msg, #args)
#define MALLOC(S) tl_malloc(S)
#define REALLOC(P,S) tl_realloc(P,S)
#include "lispread.c"
tl tl_repl(TLP tl env)
{
  tl expr, val;
  tl port = tl_stdin;
  while ( tl_puts(TL tl_stdout, "> "), (expr = tl_read(TL port)) != tl_eos ) {
    val = tl_eval_print(TL expr, env);
  }
  return val;
}
#define ITYPE(T,N)                                                      \
  tl tl_##N##__get(TLP tl ptr) { return (tl) (ssize_t) *(T*)ptr; }      \
  tl tl_##N##__set(TLP tl ptr, tl word) { return (tl) (ssize_t) (*((T*)ptr) = (T)word); } \
  tl tl_##N##__sizeof(TLP0) { return tl_i((ssize_t) sizeof(T)); }
#define FTYPE(T,N)
#include "ctypes.h"
#define BOP(O,N) \
  tl tl_fixnum__##N(TLP tl x, tl y) { return tl_i(tl_I(x) O tl_I(y)); }  \
  tl tl_word__##N(TLP tl x, tl y) { return (tl) (((ssize_t) x) O ((ssize_t) y)); }
#define ROP(O,N)                                                        \
  tl tl_fixnum__##N(TLP tl x, tl y) { return (tl_I(x) O tl_I(y)) ? tl_t : tl_f; } \
  tl tl_word__##N(TLP tl x, tl y) { return (tl) (((ssize_t) x) O ((ssize_t) y)); }
#define UOP(O,N) \
  tl tl_fixnum__##N(TLP tl x) { return tl_i(O tl_I(x)); }  \
  tl tl_word__##N(TLP tl x) { return (tl) (O ((ssize_t) x)); }
#include "cops.h"
tl tl_stdenv(TLP tl env)
{
  env = tl_let(TL tl__s("t"), tl__s("t"), env);
  env = tl_let(TL tl__s("nil"), tl_nil, env);
  env = tl_let(TL tl__s("&eos"), tl_eos, env);
  env = tl_let(TL tl_s(stdin), tl_stdin, env);
  env = tl_let(TL tl_s(stdout), tl_stdout, env);
  env = tl_let(TL tl_s(stderr), tl_stderr, env);
  env = tl_let(TL tl__s("eq?"), tl_m_prim(TL tl_eqQ, "eq?", 2), env);
  env = tl_let(TL tl__s("eqv?"), tl_m_prim(TL tl_eqvQ, "eqv?", 2), env);
  env = tl_let(TL tl_s_cons, tl_m_prim(TL tl_m_pair, "cons", 2), env);
  env = tl_let(TL tl_s_car, tl_m_prim(TL tl_pair__car, "car", 1), env);
  env = tl_let(TL tl_s_cdr, tl_m_prim(TL tl_pair__cdr, "cdr", 1), env);
  env = tl_let(TL tl_s(eval), tl_m_prim(TL tl_eval, "eval", 2), env);
  env = tl_let(TL tl_s(open), tl_m_prim(TL tl_open, "open", 2), env);
  env = tl_let(TL tl_s(close), tl_m_prim(TL tl_close, "close", 1), env);
  env = tl_let(TL tl__s("%read"), tl_m_prim(TL tl_read, "%read", 1), env);
  env = tl_let(TL tl__s("%newline"), tl_m_prim(TL tl_newline, "%newline", 1), env);
  env = tl_let(TL tl__s("%write"), tl_m_prim(TL tl__write, "%write", 3), env);
#define ITYPE(T,N)                                                      \
  env = tl_let(TL tl__s("%"#N"-get"), tl_m_prim(TL tl_##N##__get, "%"#N"-get", 1), env);  \
  env = tl_let(TL tl__s("%"#N"-set"), tl_m_prim(TL tl_##N##__set, "%"#N"-set", 2), env);  \
  env = tl_let(TL tl__s("%"#N"-sizeof"), tl_m_prim(TL tl_##N##__sizeof, "%"#N"-size", 0), env);
#define FTYPE(T,N)
#include "ctypes.h"
#define BOP(O,N) \
  env = tl_let(TL tl__s(#O), tl_m_prim(TL tl_fixnum__##N, #O, 2), env); \
  env = tl_let(TL tl__s("%"#O), tl_m_prim(TL tl_word__##N, "%"#O, 2), env);
#define UOP(O,N) \
  env = tl_let(TL tl__s("@"#O), tl_m_prim(TL tl_fixnum__##N, "@"#O, 1), env); \
  env = tl_let(TL tl__s("%@"#O), tl_m_prim(TL tl_word__##N, "%@"#O, 1), env);
#define ROP(O,N) \
  env = tl_let(TL tl__s(#O), tl_m_prim(TL tl_fixnum__##N, #O, 1), env); \
  env = tl_let(TL tl__s("%"#O), tl_m_prim(TL tl_word__##N, "%"#O, 1), env);
#include "cops.h"
  return env;
}

int main(int argc, char **argv)
{
  tl tl_rt = tl_m_runtime(TL 0);
  tl env = tl_stdenv(TL tl_nil);
  fprintf(stdout, "env =>\n  "); tl_write(TL env, tl_stdout); fprintf(stdout, "\n");
  tl expr, val;

  tl_repl(TL env);
  /*
   */
  return 0;
}


