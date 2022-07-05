import keyring
import getpass

sei_pass = str(getpass.getpass('Informe sua senha para entrar no SEI:'))
keyring.set_password("SYS_TER", "m27740", sei_pass)