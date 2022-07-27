import keyring

def senha_sei():
    pass_sei = keyring.get_password("SEI", "USER")
    return pass_sei

def chave_api_resumo():
    chave_api_resumo = keyring.get_password("SUMARIZE_SERVICE", "USER")
    return chave_api_resumo

def chave_api_tarefas():
    chave_api_tarefas = keyring.get_password("TASK_SYSTEM", "USER")
    return chave_api_tarefas
