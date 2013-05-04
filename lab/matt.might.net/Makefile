CFLAGS += -O3 -g
T_SCM_FILES := $(shell ls t*.scm)
T_C_FILES := $(T_SCM_FILES:%.scm=%.csi.c) $(T_SCM_FILES:%.scm=%.tl.c)
T_FILES := $(T_C_FILES:%.c=%.t)

all : $(T_FILES)

%.t : %.c
	$(CC) $(CFLAGS) -o $@ $*.c

%.csi.c : %.scm
	csi -nq -I ../../lib -s compile-stdin.scm < $*.scm | ./filter-c-code.rb | tee $@

%.tl.c : %.scm
	../../bin/tl compile-stdin.scm < $*.scm  | ./filter-c-code.rb | tee $@

clean:
	rm -f *.t *.c
