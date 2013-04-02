UNAME_S:=$(shell uname -s 2>/dev/null)#
UNAME_O:=$(shell uname -o 2>/dev/null)#

CC=clang
#CC=gcc
CC_OPTIMIZE=-O3 #
BUILD_GC=1
tl=tl

ifeq "$(UNAME_S)" "Linux"
CC=gcc
#NO_OPTIMIZE=1
BUILD_GC=0
#NO_PTHREADS=1
endif

ifeq "$(UNAME_O)" "Cygwin"
CC=gcc
BUILD_GC=0
# NO_PTHREADS=1
endif

ifndef NO_OPTIMIZE
CFLAGS += $(CC_OPTIMIZE) #
endif

CFLAGS += -g #
CFLAGS += -Wall #

ifdef NO_GC
tl=tl-no-gc#
#CC=gcc
NO_PTHREADS=1
CFLAGS += -Dtl_NO_GC=1
else
ifneq "$(BUILD_GC)" "0"
EARLY_TARGETS += local/lib/libgc.a #
CFLAGS += -Ilocal/include #
LDFLAGS += -Llocal/lib #
endif
LDFLAGS += -lgc #
endif

ifdef WITH_PROF
tl=tl-prof#
NO_PTHEADS=1
NO_DEBUG=1
CFLAGS += -pg -Dtl_NO_DEBUG=1 #
LDFLAGS += -pg
endif

LDFLAGS += -ljit

ifeq "$(UNAME_S)" "Darwin"
CFLAGS += -I/opt/local/include #
LDFLAGS += -L/opt/local/lib #
LDFLAGS += -L/opt/local/lib/X86_64 #
endif

ifndef NO_PTHREADS
ifneq "$(UNAME_O)" "Cygwin"
CFLAGS += -pthread
endif
CFLAGS += -Dtl_PTHREAD=1 #
LDFLAGS += -lpthread #
endif

ifdef v
all : v
endif

all : $(EARLY_TARGETS) bin/$(tl)

v :
	echo "$(v)=$($v)"

lispread/lispread.c :
	git submodule add --force http://github.com/kstephens/lispread.git lispread

JIT_C = jit*.c jit*.h

$(tl) : tl.c lispread/lispread.c $(JIT_C)
	$(CC) $(CFLAGS) -o $@ tl.c $(LDFLAGS)

$(tl)-no-gc : tl.c Makefile
	$(MAKE) NO_GC=1

$(tl)-prof : tl.c Makefile
	$(MAKE) WITH_PROF=1

bin/$(tl) : $(tl)
	cp -p $< $@

tl.s : tl.c tool/asm-source
	$(CC) $(CFLAGS) -Dtl_NO_DEBUG=1 -S -o - tl.c | tool/asm-source > $@ 

test-forever :
	TL_BOOT_DEBUG=1 tool/test-forever './tl < t/file-test.scm'

run : bin/$(tl)
	bin/tlsh

debug : bin/$(tl)
	gdb --args bin/$(tl)

profile : tl-prof
	./tl-prof < t/test.scm
	gprof -l ./tl-prof | less

clean :
	rm -f tl tl-pt tl-prof tl-no-gc
	rm -rf *.dSYM/ *.exe

test : bin/$(tl)
	set -xe; for f in t/*.scm; do \
	  ./bin/tl $$f || gdb --args ./tl "< $$f" || true ;\
	done

code-stats :
	tool/code-stats *.[hc] lib

ifneq "$(BUILD_GC)" "0"
include Makefile.gc
endif

