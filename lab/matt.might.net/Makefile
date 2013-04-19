CFLAGS += -O3 -g

all : t t.csi.c t.tl.c

t : t.c

t.csi.c : t.scm scheme-to-c.scm
	csi -s scheme-to-c.scm < t.scm | tee $@
	cp $@ t.c

t.tl.c : ../../bin/tl ../../lib/tl/*.scm t.scm scheme-to-c.scm
	../../bin/tl scheme-to-c.scm < t.scm | tee $@
	cp $@ t.c

t.c : t.csi.c t.tl.c

t.s : t.c scheme.h
	$(CC) $(CFLAGS) -S -o - $(@:.s=.c) | ../../tool/asm-source > $@

../../bin/tl : ../../tl.c
	$(MAKE) -C ../..

clean:
	rm -f t t.c t.csi.c t.tl.c t.s
