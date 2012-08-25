ifndef NO_OPTIMIZE
CFLAGS += -O3
endif
CC=clang

EARLY_TARGETS += gc/lib/libgc.a
CFLAGS += -Igc/include
LDFLAGS += -Lgc/lib 

CFLAGS += -g -I/opt/local/include
LDFLAGS += -L/opt/local/lib -lgc

ifndef NO_PTHREADS
CFLAGS += -pthread -Dtl_PTHREAD=1
LDFLAGS += -lpthread
endif

all : $(EARLY_TARGETS) tl

tl : tl.c

tl.s : tl.c
	$(CC) $(CFLAGS) -S -o $@ tl.c

run : tl
	rlwrap ./tl

debug : tl
	gdb --args tl

clean :
	rm -f tl tl-pt

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

