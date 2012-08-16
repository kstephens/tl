ifndef NO_OPTIMIZE
CFLAGS += -O3
endif

#EARLY_TARGETS += gc/libgc.a
#CFLAGS += -Igc/include
#LDFLAGS += -Lgc/lib 

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

bdwgc/Makefile :
	git clone git://github.com/ivmai/libatomic_ops.git
	git clone git://github.com/ivmai/bdwgc.git
	ln -s ../libatomic_ops bdwgc/libatomic_ops
	set -ex ;\
	cd bdwgc ;\
	autoreconf -vif ;\
	automake --add-missing ;

gc/libgc.a : bdwgc/Makefile
	mkdir -p gc
	set -ex ;\
	cd bdwgc ;\
	./configure --enable-thread=pthreads --enable-static --prefix=$$(cd .. && /bin/pwd)/gc;\
	make clean ;\
	make ;\
	make install

