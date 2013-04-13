CFLAGS += -O3 -g

all : t t.c

t : t.c
t.c : t.scm scheme-to-c.scm
	csi -s scheme-to-c.scm < t.scm | tee $@
t.s : t.c scheme.h
	$(CC) $(CFLAGS) -S -o - $(@:.s=.c) | ../../tool/asm-source > $@
clean:
	rm -f t t.c t.s
