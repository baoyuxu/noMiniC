# This Makefile is designed to be simple and readable.  It does not
# aim at portability.  It requires GNU Make.

BISON=bison
CXX=clang++
FLEX=flex
CXXFLAG=`llvm-config --cxxflags --ldflags --system-libs --libs core mcjit native` -std=c++14 -Wunknown-warning-option 
CXXFLAGS=`llvm-config --cxxflags` -fexceptions -O3 -std=c++14 -Wno-unknown-warning-option
LINKFLAGS=`llvm-config --ldflags --libs` -lpthread -lncurses -std=c++14
BISONFLAG=-Wno-other

all: noMiniC

%.cc %.hh: %.yy
	$(BISON) $(BISONFLAGS) -o $*.cc $<

%.cc: %.ll
	$(FLEX) -o $@ $<

%.o: %.cc
	$(CXX) $(CXXFLAGS) -c -o $@ $<

noMiniC: driver.o parser.o scanner.o test.o
	$(CXX) $(LINKFLAGS) -o $@ $^

scanner.cc: scanner.ll constant.hh
parser.cc: parser.yy constant.hh
parser.o: parser.hh constant.hh
scanner.o: parser.hh constant.hh

clean:
	rm -f noMiniC *.o parser.hh parser.cc scanner.cc location.hh
