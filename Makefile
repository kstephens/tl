#CFLAGS += -O3
CFLAGS += -g -I/opt/local/include
LDFLAGS += -L/opt/local/lib -lgc

all : tl

tl : tl.c

tl.s : tl.c
	$(CC) $(CFLAGS) -S -o $@ tl.c

debug : tl
	gdb --args tl

clean :
	rm -f tl
