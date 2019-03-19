# This Makefile is designed to be simple and readable.  It does not
# aim at portability.  It requires GNU Make.

BISON=bison
CXX=g++
FLEX=flex
CXXFLAG=`llvm-config --cxxflags --ldflags --system-libs --libs core mcjit native` -std=c++14 -Wunknown-warning-option 
CXXFLAGS=`llvm-config --cxxflags` -Wall -fexceptions -O2 -std=c++14 -Wno-unknown-warning-option -Wno-unused-function
LINKFLAGS=`llvm-config --ldflags --libs` -lpthread -lncurses -std=c++14
BISONFLAGS=-Wno-other
HEADERS=constant.hh expression.hh common.hh

all: noMiniC

%.cc %.hh: %.yy
	$(BISON) $(BISONFLAGS) -o $*.cc $<

%.cc: %.ll
	$(FLEX) -o $@ $<

%.o: %.cc
	$(CXX) $(CXXFLAGS) -c -o $@ $<

noMiniC: driver.o parser.o scanner.o test.o
	$(CXX) $(LINKFLAGS) -o $@ $^

scanner.cc: scanner.ll $(HEADERS)
parser.cc: parser.yy $(HEADERS)
parser.o: parser.hh $(HEADERS)
scanner.o: parser.hh $(HEADERS)

clean:
	rm -f noMiniC *.o parser.hh parser.cc scanner.cc location.hh parser.tab.cc parser.tab.hh
