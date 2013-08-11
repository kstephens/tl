ROOT_DIR=../../..#
export TL_LIBDIR=$(ROOT_DIR)/lib
CFLAGS += -O3 -g -I$(ROOT_DIR) -I$(ROOT_DIR)/local/include
T_SCM_FILES := $(shell ls t/t*.scm)
T_TL_FILES := $(shell ls t/t*.tl)
T_C_FILES := \
  $(T_SCM_FILES:%.scm=%.scm.csi.t.c) \
  $(T_SCM_FILES:%.scm=%.scm.tl.t.c) \
  $(T_TL_FILES:%.tl=%.tl.t.c)
T_FILES := $(T_C_FILES:%.c=%)
C_DIFF_FILES := $(T_SCM_FILES:%.scm=%.c.diff)
T_OUT_FILES := $(T_FILES:%=%.out)

all : $(T_FILES) $(T_OUT_FILES)

diff-files : $(C_DIFF_FILES)

% : %.c
	$(CC) $(CFLAGS) -o $@ $@.c -L$(ROOT_DIR)/local/lib -lgc

%.c.s : %.c
	$(CC) $(CFLAGS) -S -o $@ $*.c

%.out : %
	./$< > $@
	@if [ -e $<.exp ] ;\
	then \
	  diff $@ $<.exp ;\
	else \
	  cp $@ $<.exp ;\
	fi

%.scm.csi.t.c : %.scm
	csi -nq -I $(ROOT_DIR)/lib -s compile-stdin.scm < $< | ./filter-c-code.rb > $@

%.scm.tl.t.c : %.scm
	$(ROOT_DIR)/bin/tl compile-stdin.scm < $< | ./filter-c-code.rb > $@

%.tl.t.c : %.tl tl-to-c.scm
	$(ROOT_DIR)/bin/tl tl-compile-stdin.scm < $< > $@

%.c.diff : %.csi.c %.tl.c
	-diff -u $^ > $@
	@cat $@

%.out.diff : %.csi.t.out %.tl.t.out
	-diff -u $^ > $@
	@cat $@

clean:
	rm -f t/*.t t/*.c t/*.c.diff t/*.t.out
	rm -rf t/*.dSYM

.PRECIOUS: $(T_C_FILES) $(C_DIFF_FILES)

