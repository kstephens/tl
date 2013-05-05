CFLAGS += -O3 -g
T_SCM_FILES := $(shell ls t*.scm)
T_C_FILES := $(T_SCM_FILES:%.scm=%.csi.c) $(T_SCM_FILES:%.scm=%.tl.c)
T_FILES := $(T_C_FILES:%.c=%.t)
C_DIFF_FILES := $(T_SCM_FILES:%.scm=%.c.diff)

all : $(C_DIFF_FILES) $(T_FILES)

%.t : %.c
	$(CC) $(CFLAGS) -o $@ $*.c

%.csi.c : %.scm
	csi -nq -I ../../lib -s compile-stdin.scm < $*.scm | ./filter-c-code.rb > $@

%.tl.c : %.scm
	../../bin/tl compile-stdin.scm < $*.scm  | ./filter-c-code.rb > $@

%.c.diff : %.csi.c %.tl.c
	-diff -u $^ > $@
	@cat $@

clean:
	rm -f *.t *.c *.c.diff

.PRECIOUS: $(T_C_FILES) $(C_DIFF_FILES)

