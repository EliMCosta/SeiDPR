#Funções de tratamento do histórico
def UltimoSetorRemetenteDoProcesso():
    import os
    dir_path = os.path.dirname(os.path.realpath(__file__))
    var1 = dir_path.split('/src')
    Dir_tmp = var1[0] + '/data/tmp'
    UnidadeAtual = "TERRACAP/PRESI/ASINF"
    with open(Dir_tmp+'/hist.txt') as f:
        lines = f.readlines()
        for index, line in enumerate(lines):
            if ("Processo remetido pela unidade") in line:
                if UnidadeAtual in line:
                    list_string = line.split("remetido pela unidade ")
                    var1 = list_string[1]
                    list_string = var1.split("\n")
                    UltimoSetorRemetente = list_string[0]
                    if ("Processo remetido pela unidade " + UnidadeAtual) in line:
                        UltimoSetorRemetente = ""
                    else:
                        UltimoSetorRemetente = UltimoSetorRemetente
                        break
                else:
                    UltimoSetorRemetente = ""
            else:
                UltimoSetorRemetente = ""

    return UltimoSetorRemetente

def DadosUltimoDocumentoAssinadoSetorRemetente():
    import os
    dir_path = os.path.dirname(os.path.realpath(__file__))
    var1 = dir_path.split('/src')
    Dir_tmp = var1[0] + '/data/tmp'
    UnidadeAtual = "TERRACAP/PRESI/ASINF"
    with open(Dir_tmp+'/hist.txt') as f:
        lines = f.readlines()
        for index, line in enumerate(lines):
            if ("Processo remetido pela unidade") in line:
                if UnidadeAtual in line:
                    list_string = line.split("remetido pela unidade ")
                    var1 = list_string[1]
                    list_string = var1.split("\n")
                    UltimoSetorRemetente = list_string[0]
                    if ("Processo remetido pela unidade " + UnidadeAtual) in line:
                        UltimoSetorRemetente = ""
                    else:
                        UltimoSetorRemetente = UltimoSetorRemetente
                        break
                else:
                    UltimoSetorRemetente = ""
            else:
                UltimoSetorRemetente = ""
        for index, line in enumerate(lines):
            if (UltimoSetorRemetente != "") and (UltimoSetorRemetente in line) and ("Assinado Documento" in line):

                list_string = line.split(" ")
                DataUltimoDocumentoAssinadoSetorRemetente = list_string[0]

                list_string = line.split("Assinado Documento ")
                var1 = list_string[1]
                list_string = var1.split(" (")
                UltimoDocumentoAssinadoSetorRemetente = list_string[0]

                list_string = line.split(" (")
                var1 = list_string[1]
                list_string = var1.split(") ")
                TipoUltimoDocumentoAssinadoSetorRemetente = list_string[0]

                if DataUltimoDocumentoAssinadoSetorRemetente != "":
                    break
            else:
                DataUltimoDocumentoAssinadoSetorRemetente = ""

    DadosUltimoDocumentoAssinadoSetorRemetente = [DataUltimoDocumentoAssinadoSetorRemetente, UltimoDocumentoAssinadoSetorRemetente, TipoUltimoDocumentoAssinadoSetorRemetente]

    return DadosUltimoDocumentoAssinadoSetorRemetente

def DadosUltimoDocumentoAssinadoSetorAtual():
    import os
    dir_path = os.path.dirname(os.path.realpath(__file__))
    var1 = dir_path.split('/src')
    Dir_tmp = var1[0] + '/data/tmp'
    UnidadeAtual = "TERRACAP/PRESI/ASINF"
    with open(Dir_tmp+'/hist.txt') as f:
        lines = f.readlines()
        for index, line in enumerate(lines):
            if (UnidadeAtual in line) and ("Assinado Documento" in line):

                list_string = line.split(" ")
                DataUltimoDocumentoAssinadoSetorAtual = list_string[0]

                list_string = line.split("Assinado Documento ")
                var1 = list_string[1]
                list_string = var1.split(" (")
                UltimoDocumentoAssinadoSetorAtual = list_string[0]

                list_string = line.split(" (")
                var1 = list_string[1]
                list_string = var1.split(") ")
                TipoUltimoDocumentoAssinadoSetorAtual = list_string[0]

                if DataUltimoDocumentoAssinadoSetorAtual != "":
                    break
            else:
                DataUltimoDocumentoAssinadoSetorAtual = ""

    DadosUltimoDocumentoAssinadoSetorAtual = [DataUltimoDocumentoAssinadoSetorAtual, UltimoDocumentoAssinadoSetorAtual, TipoUltimoDocumentoAssinadoSetorAtual]

    return DadosUltimoDocumentoAssinadoSetorAtual
