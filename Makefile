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
CFLAGS += $(CC_OPTIMIZE)#
endif

ifeq "$(UNAME_S)" "Darwin"
CFLAGS += -I/opt/local/include #
LDFLAGS += -L/opt/local/lib #
endif

CFLAGS += -g #

ifdef WITH_PROF
tl=tl-prof#
NO_PTHEADS=1
NO_DEBUG=1
CFLAGS += -pg -Dtl_NO_DEBUG=1 #
LDFLAGS += -pg
endif

ifdef NO_GC
tl=tl-no-gc#
#CC=gcc
NO_PTHREADS=1
CFLAGS += -Dtl_NO_GC=1
else
ifneq "$(BUILD_GC)" "0"
EARLY_TARGETS += gc/lib/libgc.a
CFLAGS += -Igc/include
LDFLAGS += -Lgc/lib 
endif
LDFLAGS += -lgc #
endif

ifndef NO_PTHREADS
ifneq "$(UNAME_O)" "Cygwin"
CFLAGS += -pthread
endif
CFLAGS += -Dtl_PTHREAD=1
LDFLAGS += -lpthread
endif

ifdef v
all : v
endif

all : $(EARLY_TARGETS) $(tl)

v :
	echo "$(v)=$($v)"

$(tl) : tl.c lispread.c lib/tl/*.scm t/*.scm
	$(CC) $(CFLAGS) -o $@ tl.c $(LDFLAGS)
	cp -p $@ bin/$@

$(tl)-no-gc : tl.c Makefile
	$(MAKE) NO_GC=1

$(tl)-prof : tl.c Makefile
	$(MAKE) WITH_PROF=1

tl.s : tl.c tool/asm-source
	$(CC) $(CFLAGS) -Dtl_NO_DEBUG=1 -S -o - tl.c | tool/asm-source > $@ 

test-forever :
	TL_BOOT_DEBUG=1 tool/test-forever './tl < t/file-test.scm'

run : tl
	rlwrap ./tl

debug : tl
	gdb --args tl

profile : tl-prof
	./tl-prof < t/test.scm
	gprof -l ./tl-prof | less

clean :
	rm -f tl tl-pt tl-prof tl-no-gc
	rm -rf *.dSYM/ *.exe

test : tl
	set -xe; for f in t/*.scm; do \
	  ./tl < $$f || gdb --args ./tl "< $$f" || true ;\
	done

code-stats :
	tool/code-stats *.[hc] lib

bdwgc/.git/config : # Makefile
	git clone git://github.com/ivmai/bdwgc.git
	cd bdwgc;         git checkout 798e5fa71391800b89dee216c3fd7017c1f354e6
	git clone git://github.com/ivmai/libatomic_ops.git
	cd libatomic_ops; git checkout 7b6b6925359baac3c3535dae37996b10ec18d260
	ln -s ../libatomic_ops bdwgc/libatomic_ops
	set -ex ;\
	cd bdwgc ;\
	autoreconf -vif ;\
	automake --add-missing

bdwgc/Makefile : bdwgc/.git/config bdwgc/configure # Makefile
	set -ex ;\
	cd bdwgc ;\
	./configure --enable-gc-assertions --enable-gc-debug --enable-handle-fork --enable-large-config --enable-parallel-mark --enable-thread=pthreads --enable-static --prefix=$$(cd .. && /bin/pwd)/gc

gc/lib/libgc.a : bdwgc/Makefile
	mkdir -p gc
	set -ex ;\
	cd bdwgc ;\
	make clean ;\
	make ;\
	make install

