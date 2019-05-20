#!/usr/bin/python

import os
import signal
import subprocess

start_str = "int main()\n \
            {\n \
                int a=0; \n \
                int sum = 0; \n \
                while( \n"

str1 =          ") \n \
                { \n "

str2 =          "} \n \
            print_int(sum); \n \
            return 0;\n \
            }\n"

def run(statement, cond):
        p = subprocess.Popen('./noMiniC -o - && clang output.o Xlib.o -o out && ./out', shell=True, stdin = subprocess.PIPE, stdout=subprocess.PIPE,encoding='UTF-8', preexec_fn=os.setsid)
        p.stdin.write(start_str+cond+str1+statement+str2)
        p.stdin.close()
        p.stdout.readline()
        out = p.stdout.readline()
        return out

def test_while():
    assert run('++sum; ++a;', "a<10") == '10'
    assert run('++sum; ++a;', "a>10") == '0'
    assert run('if(a<5) ++sum; else ; ++a;', "a<10") == '5'
    assert run('++sum; ++a;', "0") == '0'


