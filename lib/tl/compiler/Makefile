CFLAGS += -O3 -g
T_SCM_FILES := $(shell ls t*.scm)
T_C_FILES := $(T_SCM_FILES:%.scm=%.csi.c) $(T_SCM_FILES:%.scm=%.tl.c)
T_FILES := $(T_C_FILES:%.c=%.t)
C_DIFF_FILES := $(T_SCM_FILES:%.scm=%.c.diff)
T_OUT_FILES := $(T_FILES:%=%.out)

all : $(C_DIFF_FILES) $(T_FILES) $(T_OUT_FILES)

%.t : %.c
	$(CC) $(CFLAGS) -o $@ $*.c

%.out : %
	./$< > $@
	@if [ -e $<.exp ] ;\
	then \
	  diff $@ $<.exp ;\
	else \
	  cp $@ $<.exp ;\
	fi

%.csi.c : %.scm
	csi -nq -I ../../lib -s compile-stdin.scm < $*.scm | ./filter-c-code.rb > $@

%.tl.c : %.scm
	../../bin/tl compile-stdin.scm < $*.scm | ./filter-c-code.rb > $@

%.c.diff : %.csi.c %.tl.c
	-diff -u $^ > $@
	@cat $@

%.out.diff : %.csi.t.out %.tl.t.out
	-diff -u $^ > $@
	@cat $@

clean:
	rm -f *.t *.c *.c.diff *.t.out

.PRECIOUS: $(T_C_FILES) $(C_DIFF_FILES)
