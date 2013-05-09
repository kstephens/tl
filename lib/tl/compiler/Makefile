ROOT_DIR=../../..#
export TL_LIBDIR=$(ROOT_DIR)/lib
CFLAGS += -g -I$(ROOT_DIR) -I$(ROOT_DIR)/local/include
T_SCM_FILES := $(shell ls t/t*.scm)
T_TL_FILES := $(shell ls t/t*.tl)
T_C_FILES := \
  $(T_SCM_FILES:%.scm=%.scm.csi.c) \
  $(T_SCM_FILES:%.scm=%.scm.tl.c) \
  $(T_TL_FILES:%.tl=%.tl.c)
T_FILES := $(T_C_FILES:%.c=%.t)
C_DIFF_FILES := $(T_SCM_FILES:%.scm=%.c.diff)
T_OUT_FILES := $(T_FILES:%=%.out)

all : $(T_FILES) $(T_OUT_FILES)

diff-files : $(C_DIFF_FILES)

%.t : %.c
	$(CC) $(CFLAGS) -o $@ $*.c -L$(ROOT_DIR)/local/lib -lgc

%.out : %
	./$< > $@
	@if [ -e $<.exp ] ;\
	then \
	  diff $@ $<.exp ;\
	else \
	  cp $@ $<.exp ;\
	fi

%.scm.csi.c : %.scm
	csi -nq -I $(ROOT_DIR)/lib -s compile-stdin.scm < $< | ./filter-c-code.rb > $@

%.scm.tl.c : %.scm
	$(ROOT_DIR)/bin/tl compile-stdin.scm < $< | ./filter-c-code.rb > $@

%.tl.c : %.tl
	$(ROOT_DIR)/bin/tl tl-compile-stdin.scm < $< | ./filter-c-code.rb > $@

%.c.diff : %.csi.c %.tl.c
	-diff -u $^ > $@
	@cat $@

%.out.diff : %.csi.t.out %.tl.t.out
	-diff -u $^ > $@
	@cat $@

clean:
	rm -f t/*.t t/*.c t/*.c.diff t/*.t.out
	rm -rf t/g*.dSYM

.PRECIOUS: $(T_C_FILES) $(C_DIFF_FILES)

