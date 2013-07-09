#include "tl.h"

#ifndef tl_NO_GC
#include "gc/gc.h"
#else
void *GC_malloc(size_t s) { return malloc(s); }
void *GC_malloc_atomic(size_t s) { return malloc(s); }
void *GC_realloc(void *p, size_t s) { return realloc(p, s); }
void GC_free(void *p) { free(p); }
void GC_gcollect() { }
void GC_register_finalizer(void *p1, void *p2, void *p3, void *p4, void *p5) { }
void GC_invoke_finalizers() { }
int  GC_general_register_disappearing_link(void **link) { return 0; }
#define GC_INIT() (void) 0
char *GC_strdup(const char *x) { return strcpy(GC_malloc_atomic(strlen(x) + 1), x); }
#endif

#define ASSERT_ZERO(x) ((x) == 0 ? (void) 0 : (void) assert(! #x))

#ifdef tl_PTHREAD
#include <pthread.h>
static pthread_once_t tl_init_once = PTHREAD_ONCE_INIT;
pthread_key_t tl_rt_thread_key;
static int tl_rt_thread_key_init;
static void tl_init_()
{
  ASSERT_ZERO(pthread_key_create(&tl_rt_thread_key, 0));
  ++ tl_rt_thread_key_init;
}

static void tl_init_th()
{
  ASSERT_ZERO(pthread_once(&tl_init_once, tl_init_));
}

tl tl_m_thread(pthread_t rt, tl env, void *pt);
tl* tl_rt_thread()
{
  tl *tlp = pthread_getspecific(tl_rt_thread_key);
  if ( ! tlp ) {
    assert(tl_rt_thread_key_init);
    tlp = GC_malloc(sizeof(*tlp) * (16 + 1));
    memset(tlp, 0, sizeof(*tlp) * (16 + 1));
    ++ tlp; /* skip type */
    tlp[1] = (tl) pthread_self();
    ASSERT_ZERO(pthread_setspecific(tl_rt_thread_key, tlp));
  }
  return tlp;
}
#define TL_RT tl *_tl_thr_ = 0;
#define _tl_thr (_tl_thr_ ? _tl_thr_ : (_tl_thr_ = tl_rt_thread()))
#define tl_rt  (_tl_thr[0])
#define tl_pthread (_tl_thr[1])
#define tl_env (_tl_thr[2])
#else
static void tl_init_th()
{
}
#define TL_RT
tl tl_rt; // runtime.
tl tl_env; // environment.
#endif

FILE *tl_stdin, *tl_stdout, *tl_stderr;
char *tl_progpath, *tl_progname, *tl_progdir, *tl_libdir;

static void tl_init(int argc, char **argv)
{
  char *r;
  tl_stdin = stdin; tl_stdout = stdout; tl_stderr = stderr;
  tl_progpath = tl_progname = argv[0];
  if ( (r = strrchr(tl_progname, '/')) ) {
    tl_progdir = malloc(r - tl_progname + 1);
    strncpy(tl_progdir, tl_progname, r - tl_progname);
    tl_progdir[r - tl_progname] = 0;
    tl_progname = r + 1;
  } else {
    tl_progdir = ".";
  }
  if ( ! (tl_libdir = getenv("TL_LIBDIR")) ) {
    tl_libdir = malloc(strlen(tl_progdir) + sizeof("/../lib"));
    strcat(strcpy(tl_libdir, tl_progdir), "/../lib");
  }
  GC_INIT();
  tl_init_th();
}

tl tl_allocate(tl type, size_t size)
{
  tl *o = GC_malloc(sizeof(tl) + size);
  *(o ++) = type;
  memset(o, 0, size);
  return o;
}

tl tl_set_runtime(tl rt) { TL_RT tl old = tl_rt; tl_rt = rt; return old; }
tl tl_runtime() { TL_RT return tl_rt; }

tl tl_m_type(tl name);
tl tl_m_symbol(void *x);
tl tl_cons(tl a, tl d);

tl tl_m_runtime(tl parent)
{ TL_RT
  tl tl_rt_save = tl_rt;
  size_t size = sizeof(tl) * (128 + 256 /* characters */);
  tl_rt = tl_allocate(0, size);
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
#define tl_t_closure tl_(12)
#define tl_t_thread tl_(13)
#define tl_t_evlist tl_(14)
#define tl_t_if2 tl_(15)
#define tl_t_evcom3 tl_(16)
#define tl_t_define tl_(17)
#define tl_t_setE tl_(18)
#define tl_t_begin tl_(19)
#define tl_t_form tl_(20)
#define tl_t_cell tl_(21)
#define tl_t_env tl_(22)
#define tl_t_boolean tl_(29) // FIXME

#define tl_v tl_(30)
#define tl_symbol_list tl_(31)
#define tl_in_error tl_(32)
#define tl_eos tl_(33)
#define tl_result tl_(34)
#define tl_runtime_parent tl_(35)

#define tl_s_quote tl_(40)
#define tl_s_if tl_(41)
#define tl_s_lambda tl_(42)
#define tl_s_let tl_(43)
#define tl_s_tl_object_write tl_(44)
#define tl_s_tl_macro_expand tl_(45)

#define tl_s_cons tl_(47)
#define tl_s_car tl_(48)
#define tl_s_cdr tl_(49)
#define tl_s_t tl_(50)
#define tl_s_DOT tl_(51)
#define tl_s_quasiquote tl_(52)
#define tl_s_unquote_splicing tl_(53)
#define tl_s_unquote tl_(54)

#define tl_s_begin tl_(56)
#define tl_s_define tl_(57)
#define tl_s_setE tl_(58)
#define tl_s__env tl_(59)
#define tl_s__depth tl_(60)
#define tl_s__debug tl_(61)
#define tl_s_list_TO_vector tl_(62)
#define tl_s_tl__error tl_(63)
#define tl_s_tl_string_escape tl_(64)
#define tl_s_tl_string_unescape tl_(65)

#define tl_p_apply tl_(80)
#define tl_p__catch tl_(81)
#define tl_p__throw tl_(82)

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
  tl_t_boolean = tl_m_type("boolean");
  tl_t_fixnum = tl_m_type("fixnum");
  tl_t_character = tl_m_type("character");
  tl_t_string = tl_m_type("string");
  tl_t_symbol = tl_m_type("symbol");
  tl_t_null   = tl_m_type("null");
  tl_t_pair   = tl_m_type("pair");
  tl_t_prim   = tl_m_type("prim");
  tl_t_eos    = tl_m_type("eos");
  tl_t_environment = tl_m_type("environment");
  tl_t_closure = tl_m_type("closure");
  tl_t_form   = tl_m_type("form");
  tl_t_thread = tl_m_type("thread");

  tl_t_cell   = tl_m_type("cell");
  tl_t_env   = tl_m_type("env");

  tl_t_if2 = tl_m_type("if2");
  tl_t_evcom3 = tl_m_type("evcom3");
  tl_t_define = tl_m_type("define");
  tl_t_setE = tl_m_type("set!");
  tl_t_evlist = tl_m_type("evlist");

  tl_symbol_list = tl_cons(tl_nil, tl_nil);
  tl_s_quote = tl_m_symbol("quote");
  tl_s_quasiquote = tl_m_symbol("quasiquote");
  tl_s_unquote_splicing = tl_m_symbol("unquote-splicing");
  tl_s_unquote = tl_m_symbol("unquote");
  tl_s_DOT = tl_m_symbol(".");
  tl_s_begin = tl_m_symbol("begin");
  tl_s_define = tl_m_symbol("define");
  tl_s_setE = tl_m_symbol("set!");
  tl_s_if = tl_m_symbol("if");
  tl_s_lambda = tl_m_symbol("lambda");
  tl_s_let = tl_m_symbol("let");
  tl_s_tl_object_write = tl_m_symbol("tl_object_write");
  tl_s_tl_macro_expand = tl_m_symbol("tl_macro_expand");
  tl_s_cons = tl_m_symbol("cons");
  tl_s_car = tl_m_symbol("car");
  tl_s_cdr = tl_m_symbol("cdr");
  tl_s_t = tl_m_symbol("t");
  tl_s__env = tl_m_symbol("&env");
  tl_s__depth = tl_m_symbol("&depth");
  tl_s__debug = tl_m_symbol("&debug");
  tl_s_list_TO_vector = tl_m_symbol("list->vector");
  tl_s_tl__error = tl_m_symbol("tl__error");
  tl_s_tl_string_escape = tl_m_symbol("tl_string_escape");
  tl_s_tl_string_unescape = tl_m_symbol("tl_string_unescape");

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

tl tl_c(int c) { TL_RT return _tl_c(c); }
#define tl_c(c)_tl_c(c)

int tl_C(tl o) { return _tl_C(o); }
#define tl_C(o)_tl_C(o)

tl tl_get_env() { TL_RT return tl_env; }

tl tl_type(tl o) { TL_RT return _tl_type(o); }

tl tl_m_type(tl name)
{ TL_RT
  tl *o = tl_allocate(tl_t_type, sizeof(tl) * 8);
  // Note: this layout is the same as an environment cons.
  o[0] = o[1] = tl_nil; // ((names . values ) . parent)
  o[4] = name;
#define tl_type_name(x) ((char*) tl_iv(x, 4))
  return o;
}

tl tl_set_type(tl o, tl t) { tl_t_(o) = t; return o; }

tl tl_write(tl o, tl p);
tl tl_m_string(void *x, size_t l);
tl tl_call(tl s, int n, ...);

tl tl__error_abort(tl msg, tl obj)
{
  abort(); return 0;
}
tl tl__error(tl msg, tl obj)
{
  fprintf(stderr, "\nERROR: %s", (char*) tl_iv(msg, 0));
  fprintf(stderr, " : type:%s object-word:@%p object:", tl_type_name(tl_type(obj)), obj);
  tl_write(obj, stderr);
  fprintf(stderr, "\n");
  return tl__error_abort(msg, obj);
}
tl tl_error(tl msg, tl obj, ...)
{ TL_RT
  char buf[1024];
  va_list vap;
  va_start(vap, obj);
  vsnprintf(buf, sizeof(buf), msg, vap);
  va_end(vap);
  return tl_call(tl_s_tl__error, 2, tl_m_string(GC_strdup(buf), strlen(buf)), obj);
}

tl tl_get(tl o, tl i)       { return ((tl*) o)[tl_I(i)]; }
tl tl_set(tl o, tl i, tl v) { return ((tl*) o)[tl_I(i)] = v; }

tl tl_m_string(void *x, size_t l)
{ TL_RT
  tl *o = tl_allocate(tl_t_string, sizeof(o) * 2);
  o[0] = x;
  o[1] = (tl) (tlw) l;
  return o;
}
#define tl_S(o) (*(void**) (o))
#define tl_Sl(o) ((tlw*) (o))[1]

tl tl_type_cons(tl t, tl a, tl d)
{
  tl o = tl_allocate(t, sizeof(tl) * 2);
#define car_(o) ((tl*) (o))[0]
#define cdr_(o) ((tl*) (o))[1]
#define car(o)car_(o)
#define cdr(o)cdr_(o)
  car(o) = a;
  cdr(o) = d;
  return o;
}

tl tl_cons(tl a, tl d) { TL_RT return tl_type_cons(tl_t_pair, a, d); }
#define cons tl_cons

#define cadr(o) car(cdr(o))
#define cddr(o) cdr(cdr(o))
tl tl_car(tl o) { return car(o); }
tl tl_set_car(tl o, tl v) { return car(o) = v; }
tl tl_cdr(tl o) { return cdr(o); }
tl tl_set_cdr(tl o, tl v) { return cdr(o) = v; }

tl tl_va_restarg(va_list *vap)
{
  tl l = tl_nil, *lp = &l, x;
  while ( (x = va_arg(*vap, tl)) != tl_MARK ) {
    *lp = tl_cons(x, tl_nil);
    lp = &cdr_(*lp);
  }
  return l;
}

tl tl_make_symbol(void *name)
{ TL_RT
  tl *s = tl_allocate(tl_t_symbol, sizeof(tl) * 4); // name interned? keyword? spare
  name = name ?
    tl_m_string(GC_strdup(name), strlen(name)) : tl_f;
  s[0] = name;
  s[1] = tl_f;
  s[2] = tl_f;
  return s;
}

tl tl_m_symbol(void *x)
{ TL_RT
  tl l = car(tl_symbol_list);
  if ( ! strcmp(x, "\xCE\xBB") ) x = "lambda"; // UTF8 Lower-Case Lambda: λ
  while ( l != tl_nil ) {
    tl *s = car(l);
    if ( strcmp(tl_S(s[0]), x) == 0 )
      return s;
    l = cdr(l);
  }
  tl *s = tl_make_symbol(x);
  s[1] = tl_i(1); // interned
  s[2] = tl_b(*(char*)x == ':'); // keyword?
  car(tl_symbol_list) = cons(s, car(tl_symbol_list));
  return s;
}

tl tl_symbols() { TL_RT return car(tl_symbol_list); }

#define tl__s(S) tl_m_symbol(S)
#define _tl_s(N)tl_m_symbol(#N)
#define tl_s(N)_tl_s(N)

tl tl_string_TO_number(tl o, int radix)
{
  long long i = 0; char *endptr = 0;
  const char *str = tl_S(o), *strend = strchr(str, '\0');
  if ( radix < 2 ) radix = 10;
  i = strtoll(str, &endptr, radix);
  if ( endptr == strend ) {
    tl o = tl_i(i);
    if ( tl_I(o) == i ) return o;
  }
  return tl_f;
}

tl tl_fixnum_TO_string(tl o)
{
  char buf[64];
  snprintf(buf, sizeof(buf), "%lld", (long long) tl_I(o));
  return tl_m_string(GC_strdup(buf), strlen(buf));
}

tl tl_m_prim(void *f, const char *name)
{ TL_RT
  tl *o = tl_allocate(tl_t_prim, sizeof(tl) * 3);
  o[0] = f; o[1] = (tl) name; o[2] = tl_nil;
  return o;
}

tl tl_m_closure(void *f, void *e)
{ TL_RT
  tl *o = tl_allocate(tl_t_prim, sizeof(tl) * 3);
  o[0] = f; o[1] = (tl) ""; o[2] = e;
  return o;
}

tl tl_m_env(size_t size)
{ TL_RT
  tl *o = tl_allocate(tl_t_env, size);
  return o;
}

tl tl_m_cell(tl v)
{ TL_RT
  tl *o = tl_allocate(tl_t_cell, sizeof(tl) * 1);
  o[0] = v;
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

tl tl_object_write(tl o, tl p, tl op)
{
  fprintf(FP, "#<%s @%p>", tl_type_name(tl_type(o)), o);
  return p;
}

tl tl_string_display(tl o, tl p)
{
  return tl_port__write(p, o, tl_i(((tlw*) o)[1]));
}

tl tl_string_write(tl o, tl p)
{ TL_RT
  fwrite("\"", 1, 1, FP);
  o = tl_call(tl_s_tl_string_escape, 1, o);
  tl_string_display(o, p);
  fwrite("\"", 1, 1, FP);
  return p;
}

tl tl_fixnum_write(tl o, tl p)
{
  fprintf(FP, "%lld", (long long) tl_I(o));
  return p;
}

tl tl_symbol_write(tl *o, tl p)
{
  if ( o[0] == tl_f ) // unnamed?
    return tl_object_write(o, p, 0);
  if ( o[1] == tl_f ) fputs("#:", FP); // not interned?
  return tl_string_display(o[0], p);
}

tl tl_type_write(tl o, tl p)
{
  fprintf(FP, "#<%s @%p %s>", tl_type_name(tl_type(o)), o, tl_type_name(o));
  return p;
}

tl tl_prim_write(tl o, tl p)
{
  fprintf(FP, "#<%s @%p %s @%p>", tl_type_name(tl_type(o)), o, (char*) tl_iv(o, 1), tl_iv(o, 0));
  return p;
}

tl tl_closure_write(tl o, tl p)
{
  fprintf(FP, "#<%s @%p ", tl_type_name(tl_type(o)), o);
  tl_write(car(car(o)), p);
  fprintf(FP, " >");
  return p;
}

tl tl_write_2(tl o, tl p, tl op);
tl tl_pair_write_1(tl o, tl p, tl op)
{ TL_RT
  if ( ! o ) goto rtn;
 again:
  if ( tl_type(o) == tl_t_pair ) {
    tl_write_2(car(o), p, op);
    o = cdr(o);
    if ( ! o ) goto rtn;
    fwrite(" ", 1, 1, FP);
    goto again;
  }
  fwrite(". ", 2, 1, FP);
  tl_write_2(o, p, op);
 rtn:
  return p;
}
tl tl_pair_write(tl o, tl p, tl op)
{ TL_RT
  fwrite("(", 1, 1, FP);
  tl_pair_write_1(o, p, op);
  fwrite(")", 1, 1, FP);
  return p;
}
tl tl_thread_write(tl o, tl p)
{
  tl opts = tl_get(o, tl_i(3));
  fprintf(FP, "#<%s ", tl_type_name(tl_type(o)));
  if ( opts == tl_nil ) {
    fprintf(FP, "@%p", o);
  } else {
    tl_pair_write_1(opts, p, tl_nil);
  }
  fprintf(FP, ">");
  return p;
}

tl tl_write_2(tl o, tl p, tl op)
{ TL_RT
  tl t;
  if ( o == tl_nil )
    return tl_pair_write(o, p, op);
  if ( o == tl_f ) { fputs("#f", p); return p; }
  if ( o == tl_t ) { fputs("#t", p); return p; }
  if ( o == tl_v ) { fputs("#<void>", p); return p; }
  t = tl_type(o);
  if ( t == tl_t_fixnum )
    return tl_fixnum_write(o, p);
  if ( t == tl_t_string )
    return (op != tl_nil ? tl_string_write : tl_string_display)(o, p);
  if ( t == tl_t_symbol )
    return tl_symbol_write(o, p);
  if ( t == tl_t_character )
    { fprintf(FP, "#\\%c", tl_C(o)); return p; }
  if ( t == tl_t_pair )
    return tl_pair_write(o, p, op);
  if ( t == tl_t_type )
    return tl_type_write(o, p);
  if ( t == tl_t_prim )
    return tl_prim_write(o, p);
  if ( t == tl_t_closure )
    return tl_closure_write(o, p);
  if ( t == tl_t_thread )
    return tl_thread_write(o, p);
  return tl_call(tl_s_tl_object_write, 3, o, p, op);
}
tl tl_display(tl o, tl p) { return tl_write_2(o, p, (tl) 0); }
tl tl_write(tl o, tl p) { return tl_write_2(o, p, (tl) 1); }
#undef FP

tl tl_bind(tl vars, tl args, tl env)
{ TL_RT
  return cons(tl_set_type(cons(vars, args), tl_t_environment), env);
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

tl tl_lookup(tl var, tl env)
{ TL_RT
  while ( env != tl_nil ) {
    tl vv = car(env);
    tl vars = car(vv), vals = cdr(vv);
    while ( vars != tl_nil ) {
      if ( vars == var )
        return cons(vals, tl_nil); // restarg hack.
      if ( tl_type(vars) != tl_t_pair ) break;
      if ( car(vars) == var )
        return vals;
      vars = cdr(vars);
      vals = vals == tl_nil ? vals : cdr(vals);
    }
    env = cdr(env);
  }
  return tl_nil;
}

tl tl_define_here(tl var, tl val, tl env)
{ TL_RT
  tl slot;
  if ( tl_type(var) != tl_t_symbol ) return tl_error("define: not a symbol", var);
  // if ( getenv("TL_DEFINE_DEBUG") ) { fprintf(stderr, ";; define %s @%p\n", tl_S(tl_get(var, 0)), val); }
  if ( (slot = tl_lookup(var, env)) != tl_nil )
    car(slot) = val;
  else
    tl_let(var, val, env);
  return var;
}

tl tl_define(tl var, tl val, tl env)
{
  while ( env != tl_nil && cdr(env) != tl_nil )
    env = cdr(env);
  return tl_define_here(var, val, env);
}

tl tl_eqQ(tl x, tl y)
{
  return tl_b(x == y);
}

tl tl_eqvQ(tl x, tl y)
{ TL_RT
  if ( tl_type(x) == tl_t_fixnum && tl_type(y) == tl_t_fixnum )
    return tl_b(tl_I(x) == tl_I(y));
  return tl_eqQ(x, y);
}

tl tl_value(tl var, tl env)
{
  tl slot = tl_lookup(var, env);
  if ( slot == tl_nil )
    return tl_error("unbound", var);
  return car(slot);
}

tl tl_setE(tl var, tl val, tl env)
{ TL_RT
  tl slot;
  if ( tl_type(var) != tl_t_symbol ) return tl_error("set!: not a symbol", var);
  slot = tl_lookup(var, env);
  if ( slot == tl_nil )
    return tl_error("unbound", var);
  return car(slot) = val;
}

static int _tl_eval_debug;
tl tl_eval_debug(tl val) { _tl_eval_debug = tl_B(val) ? 1 : 0; return val; }

tl tl_eval(tl exp, tl env)
{ TL_RT
#undef car
#undef cdr
#define car(o)((o) == tl_nil ? tl_nil : car_(o))
#define cdr(o)((o) == tl_nil ? tl_nil : cdr_(o))
#define nil tl_nil
  tl val = tl_nil, args = tl_nil, clink = tl_nil, argp = tl_nil;
#define pop(x)     x = car(clink); clink = cdr(clink)
#define tpush(t,x) clink = tl_type_cons(t, x, clink)
#define push(x)    clink = cons(x, clink)
#define L(N) N:
#define G(N) goto N;

  L(eval);
  if ( exp == tl_nil ) G(self);
  val = tl_type(exp);
  if ( val == tl_t_pair ) G(evexp);
  if ( val == tl_t_symbol ) {
    if ( tl_iv(exp, 2) != tl_f ) G(self); // keyword
    if ( exp == tl_s__env ) { val = env; G(rtn); }
    if ( exp == tl_s__depth ) { 
      int clink_depth = 0; tl v = clink;
      while ( v != tl_nil ) {
        ++ clink_depth; v = cdr(v);
      }
      val = tl_i(clink_depth); G(rtn);
    }
    val = tl_value(exp, env); 
    G(rtn);
  }

  L(self); val = exp; G(rtn);

  L(proc);
  val = tl_type_cons(tl_t_closure, cdr(exp), env); 
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
  if ( tl_B(val) )
    exp = car(exp);
  else
    exp = (exp = cdr(exp)) != tl_nil ? car(exp) : tl_v;
  G(eval);

  L(evexp);
  if ( _tl_eval_debug > 0 ) { _tl_eval_debug --; fprintf(stderr, "  ;=> "); tl_write(exp, stderr); fprintf(stderr, "\n"); _tl_eval_debug ++; }
  val = car(exp);
  if ( val == tl_s_quote ) { val = cadr(exp); G(rtn); }
  if ( val == tl_s_if ) G(if1);
  if ( val == tl_s_lambda ) G(proc);
  if ( val == tl_s_let ) { exp = cdr(exp); G(let); }
  if ( val == tl_s_define ) G(define);
  if ( val == tl_s_setE ) G(setE);
  if ( val == tl_s_begin ) { exp = cdr(exp); G(evlist); }

  // L(evcomb);
  args = argp = tl_nil;

  L(evcom1);
  if ( exp == tl_nil ) G(call);

  // L(evcom2);
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
    argp = cdr_(argp) = cons(val, tl_nil);
  else
    args = argp = cons(val, tl_nil);
  G(evcom1);

  L(let);
  args = argp = nil; val = car(exp);
  while ( val != nil ) {
    tl b = car(val);
    argp = cons(car(b), argp);
    args = cons(cadr(b), args);
    val = cdr(val);
  }
  val = exp;
  exp = cons(cons(tl_s_lambda, cons(argp, cdr(exp))), args);
  G(eval);

  L(call);
  val = car(args); // = ((formals . body) . env) or #<prim>
  args = cdr(args);
  L(apply);
  if ( tl_type(val) == tl_t_prim ) G(callprim);

  // L(callclosure);
  if ( tl_type(val) != tl_t_closure ) tl_error("Cannot apply", val);
  exp = car(val); // = (formals . body)
  env = tl_bind(car(exp), args, cdr(val));
  exp = cdr(exp); // body
  val = tl_v;

  L(evlist);
  if ( exp == tl_nil ) G(rtn);
  val = cdr(exp);
  exp = car(exp);
  push(env);
  tpush(tl_t_evlist, val);
  G(eval);

  L(evlist_); 
  pop(exp);
  pop(env);
  G(evlist);

  L(callprim);
  if ( val == tl_p_apply ) {
    val = car(args);
    args = cadr(args);
    G(apply);
  }
  if ( val == tl_p__catch ) {
    tl *c = car(args);
    int result;
    c[1] = GC_malloc(sizeof(jmp_buf));
    c[2] = c[3] = c[4] = c[5] = tl_f; // live, result-ok, result, setjmp-result
    c[6] = tl_f;
    c[7] = cadr(args); c[8] = car(cddr(args));
    c[9] = exp; c[10] = env; c[11] = val; c[12] = args; c[13] = argp;
    if ( (result = setjmp(*(jmp_buf*) c[1])) == 0 ) {
      val = c[7];
      args = cons(c, nil);
      G(apply);
    }
    c[1] = tl_nil;
    c[2] = tl_f; // dead
    c[5] = tl_i(result);
    exp = c[9]; env = c[10]; val = c[11]; args = c[12]; argp = c[13];
    pop(exp); // evcom2
    pop(argp);
    pop(args);
    pop(env);
    val = c[3] != tl_f ? c[4] : c[5];
    if ( c[8] == tl_f ) G(rtn);
    args = cons(c, cons(val, nil));
    val = c[8];
    G(apply);
  }
  if ( val == tl_p__throw ) {
    tl *c = car(args);
    c[3] = tl_t;
    c[4] = cadr(args);
    longjmp(*(jmp_buf*) c[1], 1);
    abort();
  }
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
  else if ( cdr(cdr(cdr(cddr(args)))) == tl_nil )
    val = tl_FP(val,tl,(tl,tl,tl,tl,tl))(car(args), cadr(args), car(cddr(args)), car(cdr(cddr(args))), car(cdr(cdr(cddr(args)))));
  else
    tl_error("too many args", val);
  G(rtn);

  L(define);
  val = cadr(exp);
  if ( tl_type(val) == tl_t_pair ) {
    exp = cons(tl_s_define, cons(car(val), cons(cons(tl_s_lambda, cons(cdr(val), cddr(exp))), nil)));
    G(eval);
  }
  push(env); tpush(tl_t_define, val);
  exp = cadr(cdr(exp));
  G(eval);

  L(define_);
  pop(exp); pop(env);
  tl_define(exp, val, env);
  val = exp;
  G(rtn);

  L(setE);
  push(env); tpush(tl_t_setE, cadr(exp));
  exp = cadr(cdr(exp));
  G(eval);

  L(setE_);
  pop(exp); pop(env);
  tl_setE(exp, val, env);
  G(rtn);

  L(rtn);
  if ( clink == tl_nil )
    return val;
  if ( tl_t_(clink) == tl_t_if2 )
    G(if2);
  if ( tl_t_(clink) == tl_t_evcom3 )
    G(evcom3);
  if ( tl_t_(clink) == tl_t_evlist )
    G(evlist_);
  if ( tl_t_(clink) == tl_t_define )
    G(define_);
  if ( tl_t_(clink) == tl_t_setE )
    G(setE_);
  if ( tl_t_(clink) == tl_t_form )
    { pop(exp); G(eval); }
  tl_error("tl_eval: invalid clink", clink); abort();
#undef car
#undef cdr
#undef nil
#define car(o)car_(o)
#define cdr(o)cdr_(o)
}

tl tl_macro_expand(tl exp, tl env) { return exp; }

tl tl_eval_top_level(tl exp, tl env)
{ TL_RT
  exp = tl_call(tl_s_tl_macro_expand, 2, exp, env);
  return tl_eval(exp, env);
}

tl tl_identity(tl x) { return x; }

tl tl_quote(tl x)
{ TL_RT
  return cons(tl_s_quote, cons(x, tl_nil));
}

tl tl_apply(tl f, tl args)
{ TL_RT
  return tl_eval(cons(tl_p_apply, cons(tl_quote(f), cons(tl_quote(args), tl_nil))), tl_env);
}

tl tl_apply_2(tl obj, tl closure)
{ TL_RT
  tl_apply(closure, cons(obj, tl_nil));
  return tl_v;
}

tl tl_call(tl s, int n, ...)
{ TL_RT
  tl args = tl_nil, *lp = &args;
  va_list vap;
  va_start(vap, n);
  while ( n -- > 0 )
    lp = &cdr(*lp = cons(va_arg(vap, tl), tl_nil));
  va_end(vap);
  if ( tl_type(s) != tl_t_symbol ) s = tl_quote(s);
  return tl_eval(cons(tl_p_apply, cons(s, cons(tl_quote(args), tl_nil))), tl_env);
}

tl tl_eval_print(tl expr, tl env, tl out)
{ TL_RT
  if ( out && getenv("TL_REPL_VERBOSE") ) { tl_write(expr, stdout); fprintf(stdout, " => \n"); }
  tl val = tl_eval_top_level(expr, env);
  if ( out && val != tl_v ) { tl_write(val, stdout); fprintf(stdout, "\n"); }
  return val;
}

tl tl_stdenv(tl env);

#ifdef tl_PTHREAD
tl tl_m_thread(pthread_t pt, tl rt, tl env)
{ TL_RT
  tl *o = tl_allocate(tl_t_thread, sizeof(*o) * 16);
  memset(o, 0, sizeof(*o) * 16);
  o[0] = rt;
  o[1] = (tl) pt;
  o[2] = env;
  return o;
}

static void *tl_pthread_start(void *data)
{ TL_RT
  tl *pt = data, proc;

  ASSERT_ZERO(pthread_setspecific(tl_rt_thread_key, pt));
  tl_rt = pt[0];
  pt[1] = (tl) pthread_self();
  tl_env = pt[2];
  proc = pt[10];
  pt[10] = 0;        // proc is "running".
  pt[5] = tl_apply(proc, tl_nil);
  pt[6] = tl_t;      // result is ready.
  return tl_result; // pthread_exit(tl_result);
}

tl tl_pthread_create(tl proc, tl opts)
{ TL_RT
  pthread_t new_thread = 0;
  tl env;
  int result = 0;
  tl *pt;
  tl tl_rt_save = tl_rt;       // save current runtime.
  tl rt = tl_m_runtime(tl_rt); // create new runtime.
  tl_rt = rt;                  // use new runtime.
  env = tl_env;
  tl_rt = tl_rt_save;          // restore current runtime

  pt = tl_m_thread(0, rt, env); // new thread object.
  pt[2] = env;                  // new environment for thread.
  pt[3] = opts;                 // thread opts.
  pt[5] = tl_nil; pt[6] = tl_f; // result.
  pt[10] = proc;                // pass proc to tl_pthread_start.

  ASSERT_ZERO(result = pthread_create(&new_thread, 0, tl_pthread_start, pt));
  // wait for thread to start.
  while ( ! ((pthread_t) pt[1] == new_thread && pt[10] == 0) ) ;

  return pt;
}

tl tl_pthread_self()
{ TL_RT
  tl *tp = tl_rt_thread();
  if ( ! tp[-1] ) tp[-1] = tl_t_thread;
  if ( ! tp[1] ) tp[1] = tl_rt;
  return tp;
}

tl tl_pthread_join(tl t)
{
  void *value = 0;
  int result;
  ASSERT_ZERO(result = pthread_join((pthread_t) tl_iv(t, 1), &value));
  assert(tl_iv(t, 6) == tl_t);
  return tl_iv(t, 5);
}
#endif /* tl_PTHREAD */

tl tl_read(tl stream);

tl tl_repl(tl env, tl in, tl out, tl prompt)
{ TL_RT
  tl expr, result = tl_eos;
 again:
  if ( prompt ) fputs("> ", (FILE*)prompt);
  if ( (expr = tl_read(in)) != tl_eos ) {
    result = tl_eval_print(expr, env, out);
    tl_define_here(tl__s("*repl-expr*"), expr, env);
    tl_define_here(tl__s("*repl-result*"), result, env);
    goto again;
  }
  return result;
}

#define TYPE(T,N)
#define ITYPE(T,N)                                                      \
  TYPE(T,N)                                                             \
  tl tl_##N##_get(tl ptr) { return (tl) (tlw) *(T*)ptr; }      \
  tl tl_##N##_set(tl ptr, tl word) { return (tl) (tlw) (*((T*)ptr) = (T)(tlw)word); }
#define FTYPE(T,N)
#include "tltypes.h"
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

tl tl_load(tl env, const char *name)
{ TL_RT
  FILE *fp;
  char buf[1024];
  if ( name[0] != '/' ) {
    snprintf(buf, sizeof(buf), "%s/%s", tl_libdir, name);
    name = buf;
  }
  if ( (fp = fopen(name, "r")) ) {
    tl result = tl_repl(env, fp, getenv("TL_BOOT_DEBUG") ? stderr : 0, 0); 
    fclose(fp);
    return result;
  } else
    return tl_error("Cannot load %s", tl_rt, name);
}

static tl tl_memcmp(tl a, tl b, tl as, tl bs)
{
  int cmp = memcmp(a, b, tl_I(as) < tl_I(bs) ? tl_I(as) : tl_I(bs));
  return tl_i(cmp ? (cmp < 0 ? -1 : 1) : (tl_I(as) == tl_I(bs) ? 0 : (tl_I(as) < tl_I(bs) ? -1 : 1)));
}

tl tl_stdenv(tl env)
{ TL_RT
  tl _v;
  tl_env = env = tl_let(tl__s("tl_rt"), tl_rt, env);
#define Ds(N,V) tl_define_here(tl__s(N), _v = (tl) (V), env)
#define D(N,V) tl_define_here(tl_s(N), _v = (tl) (V), env)
#define DD(N) D(N,N)
  Ds("tl_v", tl_v);
#define V(N) D(N,tl_##N)
  V(eos);
  D(_stdin,stdin); D(_stdout,stdout); D(_stderr,stderr);
  DD(tl_stdin); DD(tl_stdout); DD(tl_stderr);
  DD(tl_progpath); DD(tl_progname); DD(tl_progdir); DD(tl_libdir);
#define Pf(N, F) D(N, tl_m_prim((F), #N))
#define P(N) Pf(N, N)
  P(tl_allocate);
  P(tl_m_runtime); P(tl_runtime); P(tl_set_runtime); P(tl_get_env);
  P(tl_m_type); P(tl_type); P(tl_set_type);
  P(tl_i); P(tl_I); P(tl_c); P(tl_C); P(tl_b); P(tl_B);
  P(tl_t_); P(tl_iv); P(tl_closure_env);
  P(tl_get); P(tl_set);
  P(tl_eqQ); P(tl_eqvQ);
  P(tl_type_cons); P(tl_cons);
  P(tl_car); P(tl_cdr); P(tl_set_car); P(tl_set_cdr);
  P(tl_string_TO_number); P(tl_fixnum_TO_string);
  P(tl_m_symbol); P(tl_make_symbol); P(tl_symbol_write);
  P(tl_eval); P(tl_eval_debug); P(tl_macro_expand); P(tl_eval_top_level); P(tl_repl); P(tl_load);
  P(tl_error); P(tl__error);
  P(tl_define); P(tl_define_here); P(tl_let); P(tl_setE); P(tl_lookup);
  P(tl_apply); tl_p_apply = _v; P(tl_apply_2);
  Pf(tl_catch, tl_identity); tl_p__catch = _v; Pf(tl_throw, tl_identity); tl_p__throw = _v;
  P(tl_symbols);
  P(fopen); P(fclose); P(fflush); P(fprintf); P(fputs); P(fputc); P(fgetc); P(fseek);
  P(access); P(fdopen); P(fileno); P(isatty), P(ttyname); // P(ttyslot);
  P(tl_read); P(tl_write_2); P(tl_object_write);
  P(GC_malloc); P(GC_realloc); P(GC_gcollect); P(GC_register_finalizer); P(GC_invoke_finalizers); P(GC_strdup);
  P(GC_malloc_atomic); P(GC_general_register_disappearing_link);
  P(strlen); P(strcpy); P(memset); P(memcpy); P(tl_memcmp);
  P(isalpha); P(isdigit); P(islower); P(isupper); P(isspace);
  Pf(tl_string_unescape, tl_identity); Pf(tl_string_escape, tl_identity);
  P(exit); P(abort); P(getenv); P(setenv); P(system);
  P(sleep); P(usleep);
  P(fork); P(getpid); P(getppid); P(execl); P(execle); P(execv); P(execvp);
#ifdef tl_PTHREAD
  P(tl_pthread_create); P(tl_pthread_self); P(tl_pthread_join);
  P(pthread_create); P(pthread_exit);
  P(pthread_getspecific); P(pthread_setspecific); P(pthread_key_create); P(pthread_key_delete);
  // P(pthread_cleanup_pop); P(pthread_cleanup_push);
  P(pthread_self); P(pthread_detach); P(pthread_equal);
  P(pthread_join); P(pthread_cancel);
  P(pthread_mutex_init); P(pthread_mutex_destroy); P(pthread_mutex_lock); P(pthread_mutex_unlock); P(pthread_mutex_trylock);
  P(pthread_mutexattr_init); P(pthread_mutexattr_destroy);
#ifndef __linux__
  P(pthread_mutexattr_getprotocol); P(pthread_mutexattr_setprotocol);
  P(pthread_mutexattr_gettype); P(pthread_mutexattr_settype);
  P(pthread_mutexattr_getprioceiling); P(pthread_mutexattr_setprioceiling);
#endif
  P(pthread_condattr_init); P(pthread_condattr_destroy);
  P(pthread_cond_init); P(pthread_cond_destroy);
  P(pthread_cond_signal); P(pthread_cond_broadcast);
  P(pthread_cond_wait); P(pthread_cond_timedwait);
  P(nanosleep);
#endif
#define TYPE(T,N) D(tl_##N##_sizeof,tl_i(sizeof(T)));
#define ITYPE(T,N) TYPE(T,N); P(tl_##N##_get); P(tl_##N##_set);
#define FTYPE(T,N)
#include "tltypes.h"
#define BOP(O,N) P(tl_fixnum_##N); P(tl_word_##N);
#define UOP(O,N) BOP(O,N)
#define ROP(O,N) BOP(O,N)
#include "cops.h"
  {
    const char *boot_scm = getenv("TL_BOOT_SCM");
    if ( ! (boot_scm && *boot_scm ) ) boot_scm = "tl/boot.scm";
    tl_load(env, boot_scm);
  }
  return env;
}

#ifndef _tl_main
#define _tl_main(argc, argv) tl_call(tl_s(tl_main), 2, (tlsw) argc, (tl) argv)
#endif

int main(int argc, char **argv)
{ 
  tl_init(argc, argv);
  {TL_RT
  tl_rt = tl_m_runtime(0);
  tl_env = tl_stdenv(tl_nil);
  _tl_main(argc, argv);
  tl_env = tl_nil;
  GC_gcollect();
  GC_invoke_finalizers();
  return 0;
  }
}

#define VALUE tl
#define READ_DECL tl tl_read(tl stream)
#define READ_STATE TL_RT
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
#define E tl_eos
#define BRACKET_LISTS 1
#define SET_CDR(C,R) cdr(C) = (R)
#define MAKE_CHAR(I) tl_c(I)
#define LIST_2_VECTOR(X) tl_call(tl_s_list_TO_vector, 1, (X))
#define STRING(S,L) tl_call(tl_s_tl_string_unescape, 1, tl_m_string((S), (L)))
#define SYMBOL_DOT tl_s_DOT
#define SYMBOL(N) tl_s_##N
#define STRING_2_NUMBER(s, radix) tl_string_TO_number(s, radix)
#define STRING_2_SYMBOL(s) tl_m_symbol(tl_S(s))
#define ERROR(msg,args...) tl_error(msg, tl_s(read), ##args)
#define MALLOC(S) GC_malloc_atomic(S)
#define REALLOC(P,S) GC_realloc(P,S)
#define FREE(P) GC_free(P)
#include "lispread/lispread.c"
