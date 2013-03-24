
LLVM_CONFIG:=llvm-config-mp-3.3

CPPFLAGS:=$(CPPFLAGS) $(shell $(LLVM_CONFIG) --cxxflags)
LDFLAGS:=$(LDFLAGS) $(shell $(LLVM_CONFIG) --ldflags --libs engine bitreader scalaropts interpreter core jit linker)

CPPFLAGS += -I/opt/local/include
LDFLAGS += -L/opt/local/lib

T_T_CC := $(shell ls *.t.cc)
T_T = $(T_T_CC:%.t.cc=%.t)

all : $(T_T)

llvm.t : llvm.t.cc

llvm_wrapper.t: llvm_wrapper.t.cc
