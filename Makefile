CFLAGS += -g

all : tl

tl : tl.c

debug : tl
	gdb --args tl

clean :
	rm -f tl
