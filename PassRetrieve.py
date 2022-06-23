import keyring
def senha_sei():
    pass_sei=keyring.get_password("SYS_TER", "m27740")
    return(pass_sei)