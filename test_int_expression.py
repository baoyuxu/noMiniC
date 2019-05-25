#!/usr/bin/python
import os
import signal
import subprocess

start_str = "int main()\n \
            {\n \
            print_int("
after_str = ");\n \
            return 0;\n \
            }\n"

def run(expr):
        p = subprocess.Popen('./noMiniC -o - && clang output.o Xlib.o -o out && ./out', shell=True, stdin = subprocess.PIPE, stdout=subprocess.PIPE,encoding='UTF-8', preexec_fn=os.setsid)
        p.stdin.write(start_str+expr+after_str)
        p.stdin.close()
        out = p.stdout.readline()
        return out

def test_unary_expression():
    assert run('+1') == '1'
    assert run('-1') == '-1'
    assert run('~1') == '-2'
    assert run('!1') == '0'

def test_multiplicative_expression():
    assert run('1*1') == '1'
    assert run('1*2') == '2'
    assert run('1*0') == '0'
    assert run('1/2') == '0'
    assert run('1/1') == '1'
    assert run('1%1') == '0'
    assert run('1%2') == '1'

def test_additive_expression():
    assert run('1+1')  ==  '2'
    assert run('-1+2') ==  '1'
    assert run('1+0')  ==  '1'
    assert run('1-2')  ==  '-1'
    assert run('1-1')  ==  '0'
    assert run('1-0')  ==  '1'

def test_shift_expression():
    assert run('1<<1')   ==  '2'
    assert run('1<<2')   ==  '4'
    assert run('1<<0')   ==  '1'
    assert run('8>>2')   ==  '2'
    assert run('2>>1')   ==  '1'
    assert run('1>>0')   ==  '1'

def test_relational_expression():
    assert run('1<1' )  ==  '0'
    assert run('1<2' )  ==  '1'
    assert run('1<0' )  ==  '0'
    assert run('8>2' )  ==  '1'
    assert run('2>3' )  ==  '0'
    assert run('1>0' )  ==  '1'
    assert run('1<=0')  ==  '0'
    assert run('1<=1')  ==  '1'
    assert run('1<=2')  ==  '1'
    assert run('1>=0')  ==  '1'
    assert run('1>=1')  ==  '1'
    assert run('1>=2')  ==  '0'
    assert run('1>=3')  ==  '0'

def test_equality_expression():
    assert run('1==1') ==  '1'
    assert run('1==2') ==  '0'
    assert run('1==0') ==  '0'
    assert run('8==2') ==  '0'
    assert run('2==3') ==  '0'
    assert run('1==0') ==  '0'
    assert run('1!=0') ==  '1'
    assert run('1!=1') ==  '0'
    assert run('1!=2') ==  '1'
    assert run('1!=0') ==  '1'

def test_and_expression():
    assert run('1&1')  ==  '1'
    assert run('1&2')  ==  '0'
    assert run('8&2')  ==  '0'
    assert run('2&3')  ==  '2'
    assert run('1&0')  ==  '0'

def test_exclusive_or_expression():
    assert run('1^1') == '0'
    assert run('1^2') == '3'
    assert run('8^2') == '10'
    assert run('2^3') == '1'
    assert run('1^0') == '1'

def test_inclusive_or_expression():
    assert run('1|1') == '1'
    assert run('1|0') == '1'
    assert run('8|2') == '10'
    assert run('2|3') == '3'
    assert run('0|0') == '0'


def test_logical_and_expression():
    assert run('1&&1') == '1'
    assert run('1&&0') == '0'
    assert run('8&&2') == '1'
    assert run('2&&3') == '1'
    assert run('0&&0') == '0'


def test_logical_or_expression():
    assert run('1||1') == '1'
    assert run('1||0') == '1'
    assert run('8||2') == '1'
    assert run('2||3') == '1'
    assert run('0||0') == '0'

