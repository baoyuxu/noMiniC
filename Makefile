# This Makefile is designed to be simple and readable.  It does not
# aim at portability.  It requires GNU Make.

BISON=bison
CXX=clang++
FLEX=flex
CXXFLAG=`llvm-config --cxxflags --ldflags --system-libs --libs core mcjit native` -g -std=c++17 -Wunknown-warning-option 
CXXFLAGS=`llvm-config --cxxflags` -Wall -fexceptions -O2 -g -std=c++17 -Wno-unknown-warning-option -Wno-unused-function
LINKFLAGS=`llvm-config --ldflags --libs` -lpthread -g -lncurses -std=c++17
BISONFLAGS=-Wno-other
HEADERS=constant.hh expression.hh common.hh safe_enum.hh driver.hh

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

test_all : test_defination test_expression 
test_expression : noMiniC
	pytest -v test_expression.py
test_defination : noMiniC
	pytest -v test_defination.py

clean:
	rm -f *.o parser.hh parser.cc scanner.cc location.hh parser.tab.*
cleanall:
	rm -f noMiniC *.o parser.hh parser.cc scanner.cc location.hh parser.tab.*
	
