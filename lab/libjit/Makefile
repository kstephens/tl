
CPPFLAGS += -I/opt/local/include
LDFLAGS += -L/opt/local/lib -L/opt/local/lib/x86_64

CCFLAGS:=$(CCFLAGS) -I.
CPPFLAGS:=$(CPPFLAGS) -I.
LDFLAGS:=$(LDFLAGS) -ljit # -ljitdynamic

T_T_C := $(shell ls *.t.c 2>/dev/null)
T_T += $(T_T_C:%.t.c=%.t)
T_T_CC := $(shell ls *.t.cc 2>/dev/null)
T_T += $(T_T_CC:%.t.cc=%.t)

all : $(T_T)

libjit.t : libjit.t.c

clean:
	rm -f *.o *.t
	rm -rf *.dSYM
