#!/usr/bin/python
import os
import signal
import subprocess

start_str = "int main()\n \
            {\n \
            print_double("
after_str = ");\n \
            return 0;\n \
            }\n"

def run(expr):
        p = subprocess.Popen('./noMiniC -o - && clang output.o Xlib.o -o out && ./out', shell=True, stdin = subprocess.PIPE, stdout=subprocess.PIPE,encoding='UTF-8', preexec_fn=os.setsid)
        p.stdin.write(start_str+expr+after_str)
        p.stdin.close()
        p.stdout.readline()
        out = p.stdout.readline()
        return out

def test_unary_expression():
    assert run('+1.00') == '1.00'
    assert run('-1.00') == '-1.00'

def test_multiplicative_expression():
    assert run('1.00*1.00') == '1.00'
    assert run('1.00*2.00') == '2.00'
    assert run('1.00*0.00') == '0.00'
    assert run('1.00/2.00') == '0.50'
    assert run('1.00/1.00') == '1.00'

def test_additive_expression():
    assert run('1.00+1.00')  ==  '2.00'
    assert run('-1.00+2.00') ==  '1.00'
    assert run('1.00+0.00')  ==  '1.00'
    assert run('1.00-2.00')  ==  '-1.00'
    assert run('1.00-1.00')  ==  '0.00'
    assert run('1.00-0.00')  ==  '1.00'

