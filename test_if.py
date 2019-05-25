#!/usr/bin/python
import os
import signal
import subprocess

start_str = "int main()\n \
            {\n \
                int a=1; \n \
                if( \n"

str1 =          ") \n \
                { \n "

str2 =          "} \n \
                else \n \
                { \n "

str3 =          "} \n \
            return 0;\n \
            }\n"

def run(truestatement, falsestatemrnt, cond):
        p = subprocess.Popen('./noMiniC -o - && clang output.o Xlib.o -o out && ./out', shell=True, stdin = subprocess.PIPE, stdout=subprocess.PIPE,encoding='UTF-8', preexec_fn=os.setsid)
        p.stdin.write(start_str+cond+str1+truestatement+str2+falsestatemrnt+str3)
        p.stdin.close()
        out = p.stdout.readline()
        return out

def test_if_true():
    assert run('print_int(1);', ";", "1") == '1'
    assert run('print_int(1);', ";", "1+1") == '1'
    assert run('print_int(1);', ";", "a") == '1'
    assert run('print_int(1);', ";", "1==1") == '1'
    assert run('print_int(1);', ";", "1<<1") == '1'

def test_if_false():
    assert run(';', 'print_int(1);', "0") == '1'
    assert run(';', 'print_int(1);', "1-1") == '1'
    assert run(';', 'print_int(1);', "a==0") == '1'
    assert run(';', 'print_int(1);', "!a") == '1'

