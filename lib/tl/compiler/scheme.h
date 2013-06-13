struct Int ;
struct Boolean ;
struct Closure ;
union Value ;

enum Tag { VOID, INT, BOOLEAN, STRING, CLOSURE, CELL, ENV } ;

typedef union Value (*Lambda)()  ;

struct Int {
  enum Tag t ;
  int value ;
} ;

struct Boolean {
  enum Tag t ;
  unsigned int value ;
} ;

struct String {
  enum Tag t ;
  char *value ;
  size_t length;
} ;

struct Closure {
  enum Tag t ;
  Lambda lam ;
  void* env ;
} ;

struct Env {
  enum Tag t ;
  void* env ;
} ;

struct Cell {
  enum Tag t ;
  union Value* addr ; 
} ;

union Value {
  enum Tag t ;
  struct Int z ;
  struct Boolean b ;
  struct String s;
  struct Closure clo ;
  struct Env env ;
  struct Cell cell ;
} ;

typedef union Value Value ;

static Value MakeClosure(Lambda lam, Value env) {
  Value v ;
  v.clo.t = CLOSURE ;
  v.clo.lam = lam ;
  v.clo.env = env.env.env ;
  return v ;
}

static Value MakeInt(int n) {
  Value v ;
  v.z.t = INT ;
  v.z.value = n ;
  return v ;
}

static Value MakeBoolean(unsigned int b) {
  Value v ;
  v.b.t = BOOLEAN ;
  v.b.value = b ;
  return v ;
}

static Value MakeString(char *p, size_t len) {
  Value v ;
  v.s.t = STRING ;
  v.s.value = memcpy(malloc(len + 1), p, len) ;
  v.s.length = len ;
  return v ;
}

static Value MakePrimitive(Lambda prim) {
  Value v ;
  v.clo.t = CLOSURE ;
  v.clo.lam = prim ;
  v.clo.env = NULL ;
  return v ;
}

static Value MakeEnv(void* env) {
  Value v ;
  v.env.t = ENV ;
  v.env.env = env ;
  return v ;
}


static Value NewCell(Value initialValue) {
  Value v ;
  v.cell.t = CELL ;
  v.cell.addr = malloc(sizeof(Value)) ;
  *v.cell.addr = initialValue ;
  return v ;
}


static Value __sum ;
static Value __difference ;
static Value __product ;
static Value __display ;
static Value __numEqual ;
