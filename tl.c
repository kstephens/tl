#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h> /* strtoll() */
#include <unistd.h>
#include <assert.h>
#ifdef tl_PTHREAD
#define GC_THREADS
// #define GC_PTHREADS
#endif
#include "gc/gc.h"
typedef void *tl;
typedef size_t tlw;
typedef ssize_t tlsw;
#define tl_malloc(S) GC_malloc(S)
#define tl_realloc(P,S) GC_realloc(P,S)
#ifdef tl_PTHREAD
#include <pthread.h>
static pthread_once_t tl_init_once = PTHREAD_ONCE_INIT;
pthread_key_t tl_rt_thread_key;
static void tl_init_()
{
  pthread_key_create(&tl_rt_thread_key, 0);
  GC_INIT();
}
static void tl_init()
{
  pthread_once(&tl_init_once, tl_init_);
}
tl tl_m_thread(pthread_t rt, tl env, void *pt);
tl* tl_rt_thread() {
  tl *tlp = pthread_getspecific(tl_rt_thread_key);
  if ( ! tlp ) {
    tlp = tl_malloc(sizeof(*tlp) * (16 + 1));
    tlp[0] = 0;
    ++ tlp; /* skip type */
    pthread_setspecific(tl_rt_thread_key, tlp);
    memset(tlp, 0, sizeof(*tlp) * 16);
    tlp[0] = pthread_self();
  }
  return tlp;
}
#define tl_pthread tl_rt_thread()[0]
#define tl_rt tl_rt_thread()[1]
#define tl_env tl_rt_thread()[2]
#else
static void tl_init()
{
  GC_INIT();
}
tl tl_rt; // runtime.
tl tl_env; // environment.
#endif
#define tl_nil ((tl) 0)
#define tl_f tl_nil
#define tl_t tl_s_t
tl tl_allocate(tl type, size_t size)
{
  tl o = tl_malloc(size + sizeof(type));
  o += sizeof(type);
#define tl_t_(o) ((tl*)(o))[-1]
  tl_t_(o) = type;
  memset(o, 0, size);
  return o;
}
tl tl_set_runtime(tl rt) { tl old = tl_rt; tl_rt = rt; return old; }
tl tl_runtime() { return tl_rt; }
tl tl_m_type(tl name);
tl tl_m_symbol(void *x);
tl tl_m_runtime(tl parent)
{
  tl tl_rt_save = tl_rt;
  size_t size = sizeof(tl) * (128 + 256 /* characters */);
  tl_init();
  tl_rt = tl_allocate(0, size);
#define tl_iv(o,n) ((tl*)(o))[n]
#define tl_(n) tl_iv(tl_rt,n)

#define tl_t_type tl_(0)
#define tl_t_runtime tl_(1)
#define tl_t_void tl_(2)
#define tl_t_fixnum tl_(3)
#define tl_t_character tl_(4)
#define tl_t_string tl_(5)
#define tl_t_symbol tl_(6)
#define tl_t_null tl_(7)
#define tl_t_pair tl_(8)
#define tl_t_prim tl_(9)
#define tl_t_eos tl_(10)
#define tl_t_environment tl_(11)
#define tl_t_lambda tl_(12)
#define tl_t_thread tl_(13)

#define tl_v tl_(20)
#define tl_symtab tl_(21)
#define tl_in_error tl_(22)
#define tl_eos tl_(23)
#define tl_result tl_(24)
#define tl_runtime_parent tl_(25)

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
#define tl_s__debug tl_(61)

#define tl_p_apply tl_(80)

  if ( parent ) {
    memcpy(tl_rt, parent, size);
    tl_runtime_parent = parent;
    tl_t_(tl_rt) = tl_t_runtime;
  } else {
  tl_runtime_parent = parent;
  tl_t_type = tl_m_type("type");
  tl_t_(tl_t_type) = tl_t_type;
  tl_t_runtime = tl_m_type("runtime");
  tl_t_(tl_rt) = tl_t_runtime;
  tl_t_void = tl_m_type("void");
  tl_t_fixnum = tl_m_type("fixnum");
  tl_t_character = tl_m_type("character");
  tl_t_string = tl_m_type("string");
  tl_t_symbol = tl_m_type("symbol");
  tl_t_null   = tl_m_type("null");
  tl_t_pair   = tl_m_type("pair");
  tl_t_prim   = tl_m_type("prim");
  tl_t_eos    = tl_m_type("eos");
  tl_t_environment = tl_m_type("environment");
  tl_t_lambda = tl_m_type("lambda");
  tl_t_thread = tl_m_type("thread");

  tl_symtab = tl_nil;
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
  tl_s__debug = tl_m_symbol("&debug");

  tl_v = tl_allocate(tl_t_void, 0);
  tl_eos = tl_allocate(tl_t_eos, 0);

  {
    int i;
    for ( i = 0; i < 0x100; i ++ )
#define _tl_c(c) tl_iv(tl_rt, 128 + ((c) & 0xff))
#define _tl_C(o) (*(int*)(o))
      *(int*) (_tl_c(i) = tl_allocate(tl_t_character, sizeof(int))) = i;
  }
  }

  {
    tl rt = tl_rt;
    tl_rt = tl_rt_save;
    return rt;
  }
}
tl tl_c(int c) { return _tl_c(c); }
#define tl_c(c)_tl_c(c)
int tl_C(tl o) { return _tl_C(o); }
#define tl_C(o)_tl_C(o)
tl tl_get_env() { return tl_env; }
tl tl_type(tl o)
{
#define _tl_type(o) ((o) == 0 ? tl_t_null : (((tlsw) (o)) & 1 ? tl_t_fixnum : tl_t_(o)))
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
tl tl_void(tl o) { return tl_v; }
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
  tl *o = tl_allocate(tl_t_string, sizeof(o) * 2);
  o[0] = x;
  o[1] = (tl) (tlw) l;
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
  while ( l != tl_nil ) {
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
  tl *o = tl_allocate(tl_t_prim, sizeof(tl) * 2);
#define tl_FP(o,r,p) ((r(*)p)tl_iv(o, 0))
  o[0] = f; o[1] = (tl) name;
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
  if ( tl_type(o) == tl_t_character )
    { fprintf(FP, "#\\%c", tl_C(o)); return p; }
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
  // if ( vars == tl_nil ) return env;
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
      vals = vals == tl_nil ? vals : cdr(vals);
    }
    env = cdr(env);
  }
  return tl_nil;
}
tl tl_define(tl var, tl val, tl env)
{
  tl slot;
  while ( env && cdr(env) )
    env = cdr(env);
  if ( (slot = tl_lookup(var, env)) != tl_nil ) {
    car(slot) = val;
    return var; 
  }
  return tl_let(var, val, env);
}
#define _tl_b(x) ((x) ? tl_t : tl_f)
#define _tl_B(x) ((x) != tl_f)
tl tl_b(tlw i) { return _tl_b(i); }
#define tl_b(x)_tl_b(x)
tlw tl_B(tl i) { return _tl_B(i); }
#define tl_B(x)_tl_B(x)
tl tl_eqQ(tl x, tl y)
{
  return tl_b(x == y);
}
tl tl_eqvQ(tl x, tl y)
{
  if ( tl_type(x) == tl_t_fixnum && tl_type(y) == tl_t_fixnum )
    return tl_b(tl_I(x) == tl_I(y));
  return tl_eqQ(x, y);
}
tl tl_value(tl name, tl env)
{
  tl slot = tl_lookup(name, env);
  if ( slot == tl_nil )
    return tl_error("unbound", name);
  return car(slot);
}
tl tl_setE(tl name, tl val, tl env)
{
  tl slot = tl_lookup(name, env);
  if ( slot == tl_nil )
    return tl_error("unbound", name);
  return car(slot) = val;
}
tl tl_eval(tl exp, tl env)
{
  int tl_eval_debug = 0;
  // #define tl_eval_debug 0
  tl val = tl_nil, args = tl_nil, clink = tl_nil;
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
  if ( car(exp) == tl_s__debug )
    { tl_eval_debug ^= 1; G(rtn); }
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
  L(apply);
  if ( val == tl_nil ) return tl_error("Cannot apply nil", val);
  if ( tl_type(val) == tl_t_prim ) G(callprim);

  L(callclosure);
  push(env);
  push(tl_s__callrtn);
  // val = ((params . body) . env)
  env = tl_bind(car(car(val)), args, cdr(val));
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
  if ( val == tl_p_apply ) {
    // tl_eval_debug = 1;
    // pop(val); // args.
    val = car(args);
    args = cadr(args);
    G(apply);
  }
  push(tl_env);
  tl_env = env;
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
  pop(tl_env);
  pop(args);
  G(rtn);

  L(define);
  push(cadr(exp));
  push(tl_s_define);
  exp = cadr(cdr(exp));
  G(eval);

  L(define_);
  pop(exp);
  env = tl_define(exp, val, env);
  val = exp;
  G(rtn);

  L(setE);
  push(cadr(exp));
  push(tl_s_setE);
  exp = cadr(cdr(exp));
  G(eval);

  L(setE_);
  pop(exp);
  tl_setE(exp, val, env);
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
tl tl_quote(tl x)
{
  return cons(tl_s_quote, cons(x, tl_nil));
}
tl tl_apply(tl f, tl args)
{
  return tl_eval(cons(tl_p_apply, cons(tl_quote(f), cons(tl_quote(args), tl_nil))), tl_env);
}
tl tl_eval_print(tl expr, tl env, tl out)
{
  if ( out ) { tl_write(expr, stdout); fprintf(stdout, " => \n"); }
  tl val = tl_eval(expr, env);
  if ( out && val != tl_v ) { tl_write(val, stdout); fprintf(stdout, "\n"); }
  return val;
}
tl tl_stdenv(tl env);
#ifdef tl_PTHREAD
tl tl_m_thread(pthread_t pt, tl rt, tl env)
{
  tl *o = tl_allocate(tl_t_thread, sizeof(*o) * 16);
  memset(o, 0, sizeof(*o) * 16);
  o[0] = pt;
  o[1] = rt;
  o[2] = env;
  return o;
}
static void *tl_pthread_start(void *data)
{
  tl *pt = data, proc;

  pthread_setspecific(tl_rt_thread_key, pt);
  pt[0] = pthread_self();
  tl_rt = pt[1];
  tl_env = pt[2];
  proc = pt[10];
  pt[10] = 0;

#if 0
  fprintf(stderr, "\n  pthread %p object %p in rt %p applying ", pthread_self(), pt, tl_rt);
  tl_write(proc, stderr);
  fprintf(stderr, " in env ");
  tl_write(tl_env, stderr);
  fprintf(stderr, "\n"); fflush(stderr);
#endif

  pt[5] = tl_apply(proc, tl_nil);
  pt[6] = tl_t;      // result is ready.

#if 0
  fprintf(stderr, "\n  pthread %p object %p in rt %p returning ", pthread_self(), pt, tl_rt);
  tl_write(pt[5], stderr);
  fprintf(stderr, "\n"); fflush(stderr);
#endif
  return tl_result; // pthread_exit(tl_result);
}
tl tl_pthread_create(tl proc, tl env)
{
  pthread_t new_thread = 0;
  int result = 0;
  tl *pt;
  tl tl_rt_save = tl_rt;       // save current runtime.
  tl rt = tl_m_runtime(tl_rt); // create new runtime.
  tl_rt = rt;                  // use new runtime.
  env = tl_env;
  tl_rt = tl_rt_save;          // restore current runtime

  pt = tl_m_thread(0, rt, env); // new thread object.
  pt[5] = tl_nil; pt[6] = tl_f; // result.
  pt[10] = proc;                // pass proc to tl_pthread_start.

  result = pthread_create(&new_thread, 0, tl_pthread_start, pt);
  while ( ! (pt[0] == new_thread && pt[10] == 0) ) 
    ;                          // wait for thread to start.

#if 0
  fprintf(stderr, "\n  result=%d pthread %p in rt %p, spawned new pthread %p object %p in rt %p\n", 
          result, pthread_self(), tl_rt, 
          new_thread, pt, rt);
#endif
  return pt;
}
tl tl_pthread_self()
{
  tl *tp = tl_rt_thread();
  if ( ! tp[-1] ) tp[-1] = tl_t_thread;
  if ( ! tp[1] ) tp[1] = tl_rt;
  return tp;
}
tl tl_pthread_join(tl t)
{
  void *value = 0;
  int result = pthread_join(tl_iv(t, 0), &value);
  // assert(value == tl_iv(t, 5));
  assert(tl_iv(t, 6) == tl_t);
  // tl_iv(t, 5) = 0;
  return tl_iv(t, 5);
}
#endif
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
#define MAKE_CHAR(I) tl_c(I)
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
  tl tl_##N##_set(tl ptr, tl word) { return (tl) (tlw) (*((T*)ptr) = (T)(tlw)word); } \
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
  tl tl_word_##N(tl x, tl y) { return (tl) (tlw) (((tlw) x) O ((tlw) y)); }
#define UOP(O,N) \
  tl tl_fixnum_##N(tl x) { return tl_i(O tl_I(x)); }  \
  tl tl_word_##N(tl x) { return (tl) (tlw) (O ((tlw) x)); }
#include "cops.h"
tl tl_stdenv(tl env)
{
  tl _v;
#define D(N,V) env = tl_let(tl_s(N), _v = (V), env)
  D(t, tl_s(t));
  D(nil, tl_nil);
#define V(N) D(N,tl_##N)
  V(eos);
  D(_stdin,stdin); D(_stdout,stdout); D(_stderr,stderr);
#define P(N) D(N, tl_m_prim(N, #N))
  P(tl_allocate);
  P(tl_m_runtime); P(tl_runtime); P(tl_set_runtime); P(tl_get_env);
  P(tl_m_type); P(tl_type); P(tl_typeSET);
  P(tl_void);
  P(tl_i); P(tl_I); P(tl_c); P(tl_C); P(tl_b); P(tl_B);
  P(tl_ivar); P(tl_set_ivar);
  P(tl_eqQ); P(tl_eqvQ);
  P(tl_type_cons); P(tl_cons); 
  P(tl_car); P(tl_cdr);  P(tl_set_carE); P(tl_set_cdrE);
  P(tl_eval); P(tl_repl);
  P(tl_apply); tl_p_apply = _v;
  P(fopen); P(fclose); P(fflush); P(fputs); P(fputc); P(fgetc); P(fseek); 
  P(fdopen); P(fileno); P(isatty), P(ttyname); P(ttyslot);
  P(tl_read); P(tl__write);
  P(GC_malloc); P(GC_realloc);
  P(memset); P(memcpy); P(memcmp);
  P(exit); P(abort); 
  P(fork); P(getpid); P(getppid); P(execl); P(execle); P(execv); P(execvp); P(execvP);
#ifdef tl_PTHREAD
  P(pthread_self); P(pthread_detach); P(pthread_equal); P(pthread_exit);
  P(pthread_join); P(pthread_cancel);
  P(tl_pthread_create); P(tl_pthread_self); P(tl_pthread_join);
#endif
#define ITYPE(T,N) P(tl_##N##_get); P(tl_##N##_set); P(tl_##N##_sizeof);
#define FTYPE(T,N)
ITYPE(tlw,tlw)
ITYPE(tlsw,tlsw)
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
  FILE *out = stdout;
  tl_rt = tl_m_runtime(0);
  tl_env = tl_stdenv(tl_nil);
  if ( ! isatty(0) ) out = 0;
  tl_repl(tl_env, stdin, out, out);
  return 0;
}

