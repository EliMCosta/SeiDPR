############################################# Recuperar dados da árvore ################################################
def isRestrict():
    from bs4 import BeautifulSoup
    import os
    dir_path = os.path.dirname(os.path.realpath(__file__))
    var1 = dir_path.split('/src')
    Dir_tmp = var1[0] + '/data/tmp'
    src_arvore = open(Dir_tmp+'/src_arvore.txt')
    soup = BeautifulSoup(src_arvore, 'html.parser')
    object_list = soup.find("div", {"id":"topmenu"})
    strObject = str(object_list)
    isRestrict='Acesso Restrito' in strObject
    del object_list
    del strObject
    src_arvore.close()
    return isRestrict

def isPersonalInfo():
    from bs4 import BeautifulSoup
    import os
    dir_path = os.path.dirname(os.path.realpath(__file__))
    var1 = dir_path.split('/src')
    Dir_tmp = var1[0] + '/data/tmp'
    src_arvore = open(Dir_tmp+'/src_arvore.txt')
    soup = BeautifulSoup(src_arvore, 'html.parser')
    object_list = soup.find("div", {"id":"topmenu"})
    strObject = str(object_list)
    isPersonalInfo ='Informação Pessoal' in strObject
    del object_list
    del strObject
    src_arvore.close()
    return isPersonalInfo

def isRetornoProgramado():
    from bs4 import BeautifulSoup
    import os
    dir_path = os.path.dirname(os.path.realpath(__file__))
    var1 = dir_path.split('/src')
    Dir_tmp = var1[0] + '/data/tmp'
    src_arvore = open(Dir_tmp+'/src_arvore.txt')
    soup = BeautifulSoup(src_arvore, 'html.parser')
    object_list = soup.find("div", {"id":"topmenu"})
    strObject = str(object_list)
    isRetornoProgramado ='Retorno Programado' in strObject
    del object_list
    del strObject
    src_arvore.close()
    return isRetornoProgramado

def dateRetornoProgramado():
    from bs4 import BeautifulSoup
    import os
    dir_path = os.path.dirname(os.path.realpath(__file__))
    var1 = dir_path.split('/src')
    Dir_tmp = var1[0] + '/data/tmp'
    src_arvore = open(Dir_tmp+'/src_arvore.txt')
    soup = BeautifulSoup(src_arvore, 'html.parser')
    object_list = soup.find("div", {"id":"topmenu"})
    strObject = str(object_list)
    isRetornoProgramado ='Retorno Programado' in strObject
    if isRetornoProgramado == True:
        var1 = strObject.split('title="Retorno Programado')
        var2 = var1[1].split('"/></a>')
        RetornoProgramado = var2[0]
    else:
        RetornoProgramado ='NULL'
    del object_list
    del strObject
    src_arvore.close()
    return RetornoProgramado

def restrictMotivation():
    from bs4 import BeautifulSoup
    import os
    dir_path = os.path.dirname(os.path.realpath(__file__))
    var1 = dir_path.split('/src')
    Dir_tmp = var1[0] + '/data/tmp'
    src_arvore = open(Dir_tmp+'/src_arvore.txt')
    soup = BeautifulSoup(src_arvore, 'html.parser')
    object_list = soup.find("div", {"id":"topmenu"})
    strObject = str(object_list)
    isRestrict='Acesso Restrito' in strObject
    if isRestrict == True:
        var1 = strObject.split('title="Acesso Restrito')
        var2 = var1[1].split('"/></a>')
        restrictMotivation = var2[0]
    else:
        restrictMotivation ='NULL'
    del object_list
    del strObject
    src_arvore.close()
    return restrictMotivation

def acompEspGroup():
    from bs4 import BeautifulSoup
    import os
    dir_path = os.path.dirname(os.path.realpath(__file__))
    var1 = dir_path.split('/src')
    Dir_tmp = var1[0] + '/data/tmp'
    src_arvore = open(Dir_tmp+'/src_arvore.txt')
    soup = BeautifulSoup(src_arvore, 'html.parser')
    object_list = soup.find("div", {"id":"topmenu"})
    strObject = str(object_list)
    inAcompEsp ='title="Acompanhamento Especial' in strObject
    if inAcompEsp == True:
        var1 = strObject.split('title="Acompanhamento Especial')
        var2 = var1[1].split('"/></a>')
        acompEspGroup = var2[0]
    else:
        acompEspGroup ='NULL'
    del object_list
    del strObject
    del inAcompEsp
    src_arvore.close()
    return acompEspGroup

def marcadorGroup():
    from bs4 import BeautifulSoup
    import os
    dir_path = os.path.dirname(os.path.realpath(__file__))
    var1 = dir_path.split('/src')
    Dir_tmp = var1[0] + '/data/tmp'
    src_arvore = open(Dir_tmp+'/src_arvore.txt')
    soup = BeautifulSoup(src_arvore, 'html.parser')
    object_list = soup.find("div", {"id":"topmenu"})
    strObject = str(object_list)
    inMarcador ='title="Marcador' in strObject
    if inMarcador == True:
        var1 = strObject.split('title="Marcador')
        var2 = var1[1].split('"/></a>')
        marcadorGroup = var2[0]
    else:
        marcadorGroup = 'NULL'
    del object_list
    del strObject
    del inMarcador
    src_arvore.close()
    return marcadorGroup

def set_infoadicionais():
    from bs4 import BeautifulSoup
    import os
    dir_path = os.path.dirname(os.path.realpath(__file__))
    var1 = dir_path.split('/src')
    Dir_tmp = var1[0] + '/data/tmp'
    src_arvore = open(Dir_tmp+'/src_arvore.txt')
    soup = BeautifulSoup(src_arvore, 'html.parser')
    object_list = soup.find()
    strObject=str(object_list)
    isthereInfoAdicionais ='Nos[0].html = ' in strObject
    if isthereInfoAdicionais == True:
        var1 = strObject.split('Nos[0].html =')
        var2 = var1[1].split(';Nos[1]')
        info_adicionais = var2[0]
        var1 = info_adicionais.split('</a><br /><a alt=')
        set_infoadicionais = set()
        for string in var1:
            istheretitle = 'title="' in string
            if istheretitle == True:
                var3 = string.split('title="')
                var3_ = var3[1]
                var4 = var3_.split('" class="ancoraSigla">')
                nome_extenso = var4[0]
                var4_ = var4[1]
                var5 = var4_.split('</a>')
                sigla = var5[0]
                isthereatribuido = 'atribuído para' in string
                if isthereatribuido == True:
                    var6 = string.split('(atribuído para <a alt="')
                    var6_ = var6[1]
                    var7 = var6_.split('" title="')
                    atribuido = var7[0]
                else:
                    atribuido = 'sem atribuição'
                set_infoadicionais.add(nome_extenso+' - '+sigla+' ('+atribuido+')')
            else:
                set_infoadicionais = 'NULL'
    else:
        set_infoadicionais = 'NULL'
    src_arvore.close()
    del object_list
    del strObject
    del info_adicionais
    return set_infoadicionais
