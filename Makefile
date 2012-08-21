ifndef NO_OPTIMIZE
# CFLAGS += -O3
endif

EARLY_TARGETS += gc/lib/libgc.a
CFLAGS += -Igc/include
LDFLAGS += -Lgc/lib 

CFLAGS += -g -I/opt/local/include
LDFLAGS += -L/opt/local/lib -lgc

ifndef NO_PTHREADS
CFLAGS += -Dtl_PTHREAD=1
LDFLAGS += -lpthread
endif

all : $(EARLY_TARGETS) tl

tl : tl.c

tl.s : tl.c
	$(CC) $(CFLAGS) -S -o $@ tl.c

debug : tl
	gdb --args tl

clean :
	rm -f tl tl-pt

bdwgc/.git/config : # Makefile
	git clone git://github.com/ivmai/libatomic_ops.git
	git clone git://github.com/ivmai/bdwgc.git
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

