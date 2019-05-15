
def test_logical_or_expression():
    expr_ans_dict ={
            '1||1\n'    :   'i32 1',
            '1||0\n'    :   'i32 1',
            '8||2\n'    :   'i32 1',
            '2||3\n'    :   'i32 1',
            '0||0\n'    :   'i32 0'
        }
    for (key, value) in expr_ans_dict.items():
        p = subprocess.Popen('./noMiniC -', shell=True, stdin = subprocess.PIPE, stdout = subprocess.PIPE,encoding='UTF-8', preexec_fn=os.setsid)
        p.stdin.write(key)
        p.stdin.close()
        assert p.stdout.readline() == value

