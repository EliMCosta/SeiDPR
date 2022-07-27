import keyring
import getpass

sei_pass = str(getpass.getpass('Informe sua senha para entrar no SEI:'))
keyring.set_password("SEI", "USER", sei_pass)

summarize_key = str(getpass.getpass('Informe sua chave de API para o serviço de resumo de texto:'))
keyring.set_password("SUMARIZE_SERVICE", "USER", summarize_key)

task_register_key = str(getpass.getpass('Informe sua chave de API para registrar tarefas'))
keyring.set_password("TASK_SYSTEM", "USER", task_register_key)
