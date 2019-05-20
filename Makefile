# This Makefile is designed to be simple and readable.  It does not
# aim at portability.  It requires GNU Make.

BISON=bison
CXX=clang++
FLEX=flex
CXXFLAG=`llvm-config --cxxflags --ldflags --system-libs --libs core mcjit native` -g -std=c++17 -Wunknown-warning-option 
CXXFLAGS=`llvm-config --cxxflags` -Wall -fexceptions -O2 -std=c++17 -g -Wno-unknown-warning-option -Wno-unused-function
LINKFLAGS=`llvm-config --ldflags --libs` -lpthread -lncurses -std=c++17
BISONFLAGS=-Wno-other
HEADERS=constant.hh expression.hh common.hh safe_enum.hh driver.hh

all: noMiniC Xlib.o

%.cc %.hh: %.yy
	$(BISON) $(BISONFLAGS) -o $*.cc $<

%.cc: %.ll
	$(FLEX) -o $@ $<

%.o: %.cc
	$(CXX) $(CXXFLAGS) -c -o $@ $<

noMiniC: driver.o parser.o scanner.o main.o
	$(CXX) $(LINKFLAGS) -o $@ $^

Xlib.o : Xlib.c
	clang -std=c11 -O2 -c -Wall -o Xlib.o Xlib.c

scanner.cc: scanner.ll $(HEADERS)
parser.cc: parser.yy $(HEADERS)
parser.o: parser.hh $(HEADERS)
scanner.o: parser.hh $(HEADERS)
main.o : parser.hh 

test : test_int_expression test_double_expression test_if test_while test_function 
test_int_expression : all 
	pytest -v test_int_expression.py
test_double_expression : all 
	pytest -v test_double_expression.py
test_if : all 
	pytest -v test_if.py
test_while : all
	pytest -v test_while.py
test_function : all
	pytest -v test_function.py

clean:
	rm -f noMiniC *.o parser.hh parser.cc scanner.cc location.hh parser.tab.* out
	
