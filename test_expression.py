#!/usr/bin/python
import os
import signal
import subprocess

def run(expr):
        p = subprocess.Popen('./noMiniC -', shell=True, stdin = subprocess.PIPE, stdout = subprocess.PIPE,encoding='UTF-8', preexec_fn=os.setsid)
        p.stdin.write(expr)
        p.stdin.close()
        out = p.stdout.readline()
        os.killpg(os.getpgid(p.pid), signal.SIGTERM)
        return out

def test_unary_expression():
    assert run('+1\n') == 'i32 1'
    assert run('-1\n') == 'i32 -1'
    assert run('~1\n') == 'i32 -2'
    assert run('!1\n') == 'i32 0'

def test_multiplicative_expression():
    assert run('1*1\n') == 'i32 1'
    assert run('1*2\n') == 'i32 2'
    assert run('1*0\n') == 'i32 0'
    assert run('1/2\n') == 'i32 0'
    assert run('1/1\n') == 'i32 1'
    assert run('1/0\n') == 'i32 undef'
    assert run('1%1\n') == 'i32 0'
    assert run('1%2\n') == 'i32 1'

def test_additive_expression():
    assert run('1+1\n')  ==  'i32 2'
    assert run('-1+2\n') ==  'i32 1'
    assert run('1+0\n')  ==  'i32 1'
    assert run('1-2\n')  ==  'i32 -1'
    assert run('1-1\n')  ==  'i32 0'
    assert run('1-0\n')  ==  'i32 1'

def test_shift_expression():
    assert run('1<<1\n')   ==  'i32 2'
    assert run('1<<2\n')   ==  'i32 4'
    assert run('1<<0\n')   ==  'i32 1'
    assert run('8>>2\n')   ==  'i32 2'
    assert run('2>>1\n')   ==  'i32 1'
    assert run('1>>0\n')   ==  'i32 1'

def test_relational_expression():
    assert run('1<1\n' )  ==  'i32 0'
    assert run('1<2\n' )  ==  'i32 1'
    assert run('1<0\n' )  ==  'i32 0'
    assert run('8>2\n' )  ==  'i32 1'
    assert run('2>3\n' )  ==  'i32 0'
    assert run('1>0\n' )  ==  'i32 1'
    assert run('1<=0\n')  ==   'i32 0'
    assert run('1<=1\n')  ==   'i32 1'
    assert run('1<=2\n')  ==   'i32 1'
    assert run('1>=0\n')  ==   'i32 1'
    assert run('1>=1\n')  ==   'i32 1'
    assert run('1>=2\n')  ==   'i32 0'
    assert run('1>=3\n')  ==   'i32 0'

def test_equality_expression():
    assert run('1==1\n') ==  'i32 1'
    assert run('1==2\n') ==  'i32 0'
    assert run('1==0\n') ==  'i32 0'
    assert run('8==2\n') ==  'i32 0'
    assert run('2==3\n') ==  'i32 0'
    assert run('1==0\n') ==  'i32 0'
    assert run('1!=0\n') ==  'i32 1'
    assert run('1!=1\n') ==  'i32 0'
    assert run('1!=2\n') ==  'i32 1'
    assert run('1!=0\n') ==  'i32 1'

def test_and_expression():
    assert run('1&1\n')  ==  'i32 1'
    assert run('1&2\n')  ==  'i32 0'
    assert run('8&2\n')  ==  'i32 0'
    assert run('2&3\n')  ==  'i32 2'
    assert run('1&0\n')  ==  'i32 0'

def test_exclusive_or_expression():
    assert run('1^1\n') == 'i32 0'
    assert run('1^2\n') == 'i32 3'
    assert run('8^2\n') == 'i32 10'
    assert run('2^3\n') == 'i32 1'
    assert run('1^0\n') == 'i32 1'

def test_inclusive_or_expression():
    assert run('1|1\n') == 'i32 1'
    assert run('1|0\n') == 'i32 1'
    assert run('8|2\n') == 'i32 10'
    assert run('2|3\n') == 'i32 3'
    assert run('0|0\n') == 'i32 0'


def test_logical_and_expression():
    assert run('1&&1\n') == 'i32 1'
    assert run('1&&0\n') == 'i32 0'
    assert run('8&&2\n') == 'i32 1'
    assert run('2&&3\n') == 'i32 1'
    assert run('0&&0\n') == 'i32 0'


def test_logical_or_expression():
    assert run('1||1\n') == 'i32 1'
    assert run('1||0\n') == 'i32 1'
    assert run('8||2\n') == 'i32 1'
    assert run('2||3\n') == 'i32 1'
    assert run('0||0\n') == 'i32 0'

