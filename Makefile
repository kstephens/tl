UNAME_S:=$(shell uname -s 2>/dev/null)#

CC=clang
ifeq "$(UNAME_S)" "Linux"
CC=gcc
endif

ifndef NO_OPTIMIZE
CFLAGS += -O3
endif

ifeq "$(UNAME_S)" "Darwin"
CFLAGS += -I/opt/local/include #
LDFLAGS += -L/opt/local/lib #
endif

CFLAGS += -g #

ifndef NO_GC
EARLY_TARGETS += gc/lib/libgc.a
CFLAGS += -Igc/include
LDFLAGS += -Lgc/lib 
endif
LDFLAGS += -lgc #

ifndef NO_PTHREADS
CFLAGS += -pthread -Dtl_PTHREAD=1
LDFLAGS += -lpthread
endif

all : $(EARLY_TARGETS) tl

tl : tl.c

tl-prof : tl.c Makefile
	$(CC) --verbose $(CFLAGS) -Dtl_NO_DEBUG=1 -o $@ tl.c $(LDFLAGS) -pg

tl.s : tl.c ./clang-source
	$(CC) $(CFLAGS) -Dtl_NO_DEBUG=1 -S -o - tl.c | ./clang-source > $@ 

run : tl
	rlwrap ./tl

debug : tl
	gdb --args tl

clean :
	rm -f tl tl-pt tl-prof

test : tl
	set -xe; for f in t/*.scm; do \
	  ./tl < $$f ;\
	done

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

