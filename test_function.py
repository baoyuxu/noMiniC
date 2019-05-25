#!/usr/bin/python

import os
import signal
import subprocess

func_str = "int func(int a) { ++a; return a; }"

start_str = "int main()\n \
            {\n \
                print_int(func("

str_end =       ")); \n \
                return 0;\n \
            }\n"

def run(statement):
        p = subprocess.Popen('./noMiniC -o - && clang output.o Xlib.o -o out && ./out', shell=True, stdin = subprocess.PIPE, stdout=subprocess.PIPE,encoding='UTF-8', preexec_fn=os.setsid)
        p.stdin.write(func_str+start_str+statement+str_end)
        p.stdin.close()
        out = p.stdout.readline()
        return out

def test_function():
    assert run('10') == '11'
    assert run('0') == '1'
    assert run('1') == '2'
    assert run('-1') == '0'


