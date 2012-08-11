#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef void *tl;
tl tl_t_type, tl_t_void, tl_t_fixnum, tl_t_string, tl_t_symbol, tl_t_cons, tl_t_port;
tl tl_v, tl_symtab;
tl tl_s_quote, tl_s_if, tl_s__if2, tl_s__unbound, tl_s__closure, tl_s__evcom3;
tl tl_s_cons, tl_s_car, tl_s_cdr;
#define TLA tl tl_rt,
#define TL tl_rt,
#define tl_nil ((tl) 0)
tl tl_error(TLA tl string, tl obj)
{
  fprintf(stderr, "\nERROR: %s: %p\n", string, obj);
  abort(); return 0;
}
tl tl_allocate(TLA tl type, size_t size)
{
  tl o = malloc(size + sizeof(type));
  o += sizeof(type);
#define tl_t(o) ((tl*)(o))[-1]
  tl_t(o) = type;
  return o;
}
tl tl_make_type(TLA tl x)
{
  return tl_allocate(TL tl_t_type, sizeof(x));
}
tl tl_make_fixnum(TLA ssize_t x)
{
  tl o = tl_allocate(TL tl_t_fixnum, sizeof(x));
  *(ssize_t*) o = x;
  return o;
}
#define tl_i(o) tl_make_fixnum(TL o)
#define tl_I(o) (*(ssize_t*) (o))
tl tl_make_string(TLA void *x, size_t l)
{
  tl o = tl_allocate(TL tl_t_string, sizeof(x) + sizeof(l));
  *(void**) o = x;
  return o;
}
#define tl_S(o) (*(void**) (o))
tl tl_make_cons(TLA tl a, tl d)
{
  tl o = tl_allocate(TL tl_t_cons, sizeof(tl) * 2);
#define car(o) ((tl*) (o))[0]
#define cdr(o) ((tl*) (o))[1]
  car(o) = a;
  cdr(o) = d;
  return o;
}
#define cons(a, r) tl_make_cons(TL a, r)
tl tl_make_symbol(TLA void *x)
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
  tl_symbol_name(o) = tl_make_string(TL strdup(x), strlen(x));
  tl_symtab = tl_make_cons(TL o, tl_symtab);
  return o;
}
tl tl_make_port(TLA FILE *x)
{
  tl o = tl_allocate(TL tl_t_port, sizeof(x));
  *(FILE**) o = x;
  return o;
}
tl tl_port__write(TLA tl o, tl s, tl l)
{
  fwrite(tl_S(s), tl_I(l), 1, (*(FILE**) o));
  return tl_v;
}
tl tl_port__read(TLA tl o, tl s, tl l)
{
  ssize_t c = fread(tl_S(s), tl_I(l), 1, (*(FILE**) o));
  return tl_i((long) c);
}
tl tl_write(TLA tl o, tl p);
tl tl_string__display(TLA tl o, tl p)
{
  return tl_port__write(TL p, o, tl_i(strlen(tl_S(o))));
}
#define fp *(FILE**)p
tl tl_string__write(TLA tl o, tl p)
{
  fwrite("\"", 1, 1, fp);
  tl_string__display(TL o, p);
  fwrite("\"", 1, 1, fp);
  return p;
}
tl tl_symbol__write(TLA tl o, tl p)
{
  return tl_string__display(TL tl_symbol_name(o), p);
}
tl tl_cons__write(TLA tl o, tl p)
{
  fwrite("(", 1, 1, fp);
  if ( ! o ) goto rtn;
 again:
  if ( tl_t(o) == tl_t_cons ) {
    tl_write(TL car(o), p);
    o = cdr(o);
    if ( ! o ) goto rtn;
    fwrite(" ", 1, 1, fp);
    goto again;
  }
  fwrite(". ", 2, 1, fp);
  tl_write(TL o, p);
 rtn:
  fwrite(")", 1, 1, fp);
  return p;
}
tl tl_write(TLA tl o, tl p)
{
  if ( o == tl_nil )
    return tl_cons__write(TL o, p);
  if ( tl_t(o) == tl_t_string )
    return tl_string__write(TL o, p);
  if ( tl_t(o) == tl_t_symbol )
    return tl_symbol__write(TL o, p);
  if ( tl_t(o) == tl_t_cons )
    return tl_cons__write(TL o, p);
  return tl_error(TL "write", o);
}
tl tl_lookup1(TLA tl name, tl vars, tl vals, tl env);
tl tl_lookup(TLA tl name, tl env)
{
  if ( ! env )
    return tl_s__unbound;
#define caar(x) car(car(x))
#define cdar(x) cdr(car(x))
  return tl_lookup1(TL name, caar(env), cdar(env), env);
}
tl tl_lookup1(TLA tl name, tl vars, tl vals, tl env)
{
 again:
  if ( ! vars )
    return tl_lookup(TL name, cdr(env));
  if ( name == car(vars) )
    return vals;
  vars = cdr(vars);
  vals = cdr(vals);
  goto again;
}
tl tl_bind(TLA tl vars, tl args, tl env)
{
  // if ( length(vars) != length(args) ) error
  return cons(cons(vars, args), env);
}
tl tl_value1(TLA tl name, tl slot)
{
  if ( slot == tl_s__unbound )
    return tl_error(TL "unbound", name);
  return car(slot);
}
tl tl_value(TLA tl name, tl env)
{
  return tl_value1(TL name, tl_lookup(TL name, env));
}
tl tl_evaluator(TLA tl exp, tl env)
{
  tl val = tl_nil, args = tl_nil, clink = tl_nil;
#define clink_pop(x)  x = car(clink); clink = cdr(clink)
#define clink_push(x) clink = cons(x, clink)
 eval:
  // if ( tl_t(exp) == tl_t_fixnum ) goto self;
  // if ( tl_t(exp) == tl_t_string ) goto self;
  if ( tl_t(exp) == tl_t_cons ) goto evcomb;
  if ( tl_t(exp) == tl_t_symbol ) {
    val = tl_lookup(TL exp, env); goto rtn;
  }
 self:
  val = exp; goto rtn;
 proc:
  val = cons(tl_s__closure, cons(exp, env)); goto rtn;
 if1:
  val = cdr(exp);
  clink_push(env);
  clink_push(cons(tl_s__if2, val));
  exp = car(exp); goto eval;
 if2:
  clink_pop(exp);
  clink_pop(env);
  if ( ! val )
    exp = cdr(exp);
  else
    exp = car(exp);
  goto eval;
 evcomb:
  args = tl_nil;
 evcom1:
  if ( car(exp) == tl_s_quote ) {
    val = car(cdr(exp)); goto rtn;
  }
  if ( car(exp) == tl_s_if ) goto if1;
  goto call;
  if ( car(exp) == tl_s_cons )
    goto cons;
  if ( car(exp) == tl_s_car )
    goto car;
  if ( car(exp) == tl_s_cdr )
    goto cdr;
  //
 evcom2:
  clink_push(env);
  clink_push(args);
  val = cdr(exp);
  clink = cons(tl_s__evcom3, cons(val, clink));
  exp = car(exp); goto eval;
 evcom3:
  clink_pop(exp);
  clink_pop(args);
  clink_pop(env);
  args = cons(val, args); goto evcom1;
 call:
  exp = car(val);
  val = cdr(val);
  env = cons(args, val); goto eval;
 cons:
  args = cdr(args);
  args = car(args);
  val = cons(args, val); goto rtn;
 car:
  val = car(val); goto rtn;
 cdr:
  val = cdr(val); goto rtn;
  /* ... */
 rtn:
  if ( clink == tl_nil )
    return val;
  if ( car(clink) == tl_s__if2 )
    goto if2;
  if ( car(clink) == tl_s__evcom3 )
    goto evcom3;
  if ( car(clink) == tl_s_cons )
    goto cons;
  if ( car(clink) == tl_s_car )
    goto car;
  if ( car(clink) == tl_s_cdr )
    goto cdr;
  abort();
}
int main(int argc, char **argv)
{
  tl tl_rt = 0;
  tl tl_stdin = tl_make_port(TL stdin);
  tl tl_stdout = tl_make_port(TL stdout);
  tl tl_stderr = tl_make_port(TL stderr);
  tl_t_fixnum = tl_make_type(TL "fixnum");
  tl_t_string = tl_make_type(TL "string");
  tl_t_symbol = tl_make_type(TL "symbol");
  tl_t_cons   = tl_make_type(TL "cons");
  tl_s_if = tl_make_symbol(TL "if");
  tl_s_quote = tl_make_symbol(TL "quote");
  tl_s__if2 = tl_make_symbol(TL "&if");
  tl_s__unbound = tl_make_symbol(TL "&unbound");
  tl_s__closure = tl_make_symbol(TL "&closure");
  tl_s__evcom3 = tl_make_symbol(TL "&evcom3");
  tl_s_cons = tl_make_symbol(TL "cons");
  tl_s_car = tl_make_symbol(TL "car");
  tl_s_cdr = tl_make_symbol(TL "cdr");

  tl a, b;
  a = tl_make_symbol(TL "a");
  b = tl_make_symbol(TL "b");

  tl expr, val;

  expr = 
    cons(tl_s_quote, cons(a, tl_nil));
  tl_write(TL expr, tl_stdout); fprintf(stdout, " => \n");
  val = tl_evaluator(TL expr, tl_nil);
  tl_write(TL val, tl_stdout); fprintf(stdout, "\n");

  expr = cons(tl_s_cons, 
              cons(
                   cons(tl_s_quote, cons(a, tl_nil)),
                   cons(
                        cons(tl_s_quote, cons(b, tl_nil)),
                        tl_nil)));
  tl_write(TL expr, tl_stdout); fprintf(stdout, "\n");
  tl_evaluator(TL expr, tl_nil);
  return 0;
}


