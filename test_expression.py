#!/usr/bin/python
import os
import signal
import subprocess

def test_unary_expression():
    expr_ans_dict ={
            '+1'    :   'i32 1',
            '-1'    :   'i32 -1',
            '~1'    :   'i32 -2',
            '!1'    :   'i32 0'
        }
    for (key, value) in expr_ans_dict.items():
        p = subprocess.Popen('./noMiniC -', shell=True, stdin = subprocess.PIPE, stdout = subprocess.PIPE,encoding='UTF-8', preexec_fn=os.setsid)
        p.stdin.write(key)
        p.stdin.close()
        assert p.stdout.readline() == value
        os.killpg(os.getpgid(p.pid), signal.SIGTERM)

def test_multiplicative_expression():
    expr_ans_dict ={
            '1*1\n'    :   'i32 1',
            '1*2\n'    :   'i32 2',
            '1*0\n'    :   'i32 0',
            '1/2\n'    :   'i32 0',
            '1/1\n'    :   'i32 1',
            '1/0\n'    :   'i32 undef',
            '1%1\n'    :   'i32 0',
            '1%2\n'    :   'i32 1'
        }
    for (key, value) in expr_ans_dict.items():
        p = subprocess.Popen('./noMiniC -', shell=True, stdin = subprocess.PIPE, stdout = subprocess.PIPE,encoding='UTF-8', preexec_fn=os.setsid)
        p.stdin.write(key)
        p.stdin.close()
        assert p.stdout.readline() == value
        os.killpg(os.getpgid(p.pid), signal.SIGTERM)

def test_additive_expression():
    expr_ans_dict ={
            '1+1\n'    :   'i32 2',
            '-1+2\n'    :   'i32 1',
            '1+0\n'    :   'i32 1',
            '1-2\n'    :   'i32 -1',
            '1-1\n'    :   'i32 0',
            '1-0\n'    :   'i32 1'
        }
    for (key, value) in expr_ans_dict.items():
        p = subprocess.Popen('./noMiniC -', shell=True, stdin = subprocess.PIPE, stdout = subprocess.PIPE,encoding='UTF-8', preexec_fn=os.setsid)
        p.stdin.write(key)
        p.stdin.close()
        assert p.stdout.readline() == value
        os.killpg(os.getpgid(p.pid), signal.SIGTERM)

def test_shift_expression():
    expr_ans_dict ={
            '1<<1\n'    :   'i32 2',
            '1<<2\n'    :   'i32 4',
            '1<<0\n'    :   'i32 1',
            '8>>2\n'    :   'i32 2',
            '2>>1\n'    :   'i32 1',
            '1>>0\n'    :   'i32 1'
        }
    for (key, value) in expr_ans_dict.items():
        p = subprocess.Popen('./noMiniC -', shell=True, stdin = subprocess.PIPE, stdout = subprocess.PIPE,encoding='UTF-8', preexec_fn=os.setsid)
        p.stdin.write(key)
        p.stdin.close()
        assert p.stdout.readline() == value
        os.killpg(os.getpgid(p.pid), signal.SIGTERM)

def test_relational_expression():
    expr_ans_dict ={
            '1<1\n'    :   'i32 0',
            '1<2\n'    :   'i32 1',
            '1<0\n'    :   'i32 0',
            '8>2\n'    :   'i32 1',
            '2>3\n'    :   'i32 0',
            '1>0\n'    :   'i32 1',
            '1<=0\n'    :   'i32 0',
            '1<=1\n'    :   'i32 1',
            '1<=2\n'    :   'i32 1',
            '1>=0\n'    :   'i32 1',
            '1>=1\n'    :   'i32 1',
            '1>=2\n'    :   'i32 0',
            '1>=3\n'    :   'i32 0'
        }
    for (key, value) in expr_ans_dict.items():
        p = subprocess.Popen('./noMiniC -', shell=True, stdin = subprocess.PIPE, stdout = subprocess.PIPE,encoding='UTF-8', preexec_fn=os.setsid)
        p.stdin.write(key)
        p.stdin.close()
        assert p.stdout.readline() == value
        os.killpg(os.getpgid(p.pid), signal.SIGTERM)

