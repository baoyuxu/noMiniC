# This Makefile is designed to be simple and readable.  It does not
# aim at portability.  It requires GNU Make.

BISON=bison
CXX=clang++
FLEX=flex
CXXFLAG=-std=c++14 -Wunknown-warning-option `llvm-config --cxxflags --ldflags --system-libs --libs core mcjit native`
CXXFLAGS=-O3 -std=c++14 -Wno-unknown-warning-option `llvm-config --cxxflags`
LINKFLAGS=-std=c++14 `llvm-config --ldflags --libs` -lpthread -lncurses

all: noMiniC

%.cc %.hh: %.yy
	$(BISON) -o $*.cc $<

%.cc: %.ll
	$(FLEX) -o $@ $<

%.o: %.cc
	$(CXX) $(CXXFLAGS) -c -o $@ $<

noMiniC: driver.o parser.o scanner.o
	$(CXX) $(LINKFLAGS) -o $@ $^

parser.o: parser.hh constant.hh
scanner.o: parser.hh constant.hh

clean:
	rm -f noMiniC *.o parser.hh parser.cc scanner.cc location.hh
