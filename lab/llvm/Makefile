
LLVM_CONFIG:=llvm-config-mp-3.3

CPPFLAGS:=$(CPPFLAGS) $(shell $(LLVM_CONFIG) --cxxflags)
LDFLAGS:=$(LDFLAGS) $(shell $(LLVM_CONFIG) --ldflags --libs engine bitreader scalaropts interpreter core jit linker)

CPPFLAGS += -I/opt/local/include
LDFLAGS += -L/opt/local/lib

T_T_C := $(shell ls *.t.c)
T_T += $(T_T_C:%.t.c=%.t)
T_T_CC := $(shell ls *.t.cc)
T_T += $(T_T_CC:%.t.cc=%.t)

all : $(T_T)

llvm.t : llvm.t.cc

llvm_w.o: llvm_w.cc
llvm_w_t.o: llvm_w_t.c

llvm_w.t: llvm_w.t.cc llvm_w_t.o llvm_w.o

