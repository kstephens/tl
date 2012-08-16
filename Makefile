ifndef NO_OPTIMIZE
CFLAGS += -O3
endif
CFLAGS += -g -I/opt/local/include
LDFLAGS += -L/opt/local/lib -lgc

CFLAGS += -Dtl_PTHREAD=1
LDFLAGS += -lpthread

all : tl tl-pt

tl : tl.c

tl.s : tl.c
	$(CC) $(CFLAGS) -S -o $@ tl.c

tl-pt : CFLAGS += -Dtl_PTHREAD=1
tl-pt : LDFLAGS += -lpthread
tl-pt : tl.c

debug : tl
	gdb --args tl

clean :
	rm -f tl tl-pt
