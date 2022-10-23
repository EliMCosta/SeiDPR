from datetime import datetime as dt
from bs4 import BeautifulSoup
import re
import os
import json

dir_path = os.path.dirname(os.path.realpath(__file__))
var1 = dir_path.split('/src')
Dir_tmp = var1[0]+'/data/tmp'
Dir_NaoVisualisados = var1[0]+'/data/1_Processos_Nao_Visualizados/'

#Ler lista de processos###################
with open(var1[0] + '/config' + '/restrict_process_to.txt') as r:
  text_restrict_process_to = r.read()
##########################################

print('Lendo arquivos temporários...')
NaoVis = open(Dir_tmp+'/NaoVis.txt')

soup = BeautifulSoup(NaoVis, 'html.parser')

naovis_list = soup.find_all("a", class_="processoNaoVisualizado")
#naovis_list = soup.find_all("a", class_="processoVisualizado")

for s in naovis_list:
  print('Processando dados de arquivo temporário...')
  strdt_now=dt.now().strftime("%Y%m%d%H%M%S%f")
  s=str(s)

  result=re.search('id_procedimento=(.*)&amp;infra_sistema=', s)
  id_proc=result.group(1)
  
  result=re.search('onmouseover="return infraTooltipMostrar(.*);', s)
  spectip_proc=result.group(1)
  ls_spectip=spectip_proc.split("'")
  spec_proc=ls_spectip[1]
  tip_proc=ls_spectip[3]

  result=re.search('>(.*)</a>', s)
  num_proc=result.group(1)

  isProcessOnList = num_proc in text_restrict_process_to

  if isProcessOnList == True:
    dtnow = str(dt.now())
    data = {'MetaData':
      [
        {'IdTarefaRecebimentoDoProcesso': strdt_now},
        {'DatetimeCriacaoTarefaRecebimento': dtnow}
      ],
      'ProcessData':
      [
        {'IdProcedimentoDoProcesso': id_proc},
        {'NumeroDoProcessoSei': num_proc},
        {'TipoDoProcesso': tip_proc},
        {'EspecificacaoDoProcesso': spec_proc},
        {'BoolProcessoRestrito': ''},
        {'BoolInformacaoPessoal': ''},
        {'MotivacaoProcessoRestrito': ''},
        {'RetornoProgramado': ''},
        {'GrupoAcompanhamentoEspecial': ''},
        {'GrupoMarcador': ''},
        {'UnidadesComProcessoAbertoNoMomentoDaCriacaoDaTarefa': ''},
        {'UltimoSetorRemetenteDoProcesso': ''},
        {'NumeroProtocoloUltimoDocumentoAssinadoNoUltimoSetorRemetente': ''},
        {'DataDoUltimoDocumentoAssinadoNoUltimoSetorRemetente': ''},
        {'TipoUltimoDocumentoAssinadoNoUltimoSetorRemetente': ''},
        {'DataAssinaturaDoUltimoDocumentoAssinadoNoSetorReceptor': ''},
        {'NumeroProtocoloUltimoDocumentoAssinadoNoSetorReceptor': ''},
        {'TipoUltimoDocumentoAssinadoNoSetorReceptor': ''},
        {'IDUltimoDocumentoAssinadoNoUltimoSetorRemetente': ''},
        {'InformacaoSobreAssinaturaDoUltimoDocumentoAssinadoNoUltimoSetorRemetente': ''},
        {'TextoUltimoDocumentoAssinadoNoUltimoSetorRemetente': ''},
        {'IDUltimoDocumentoAssinadoNoUltimoSetorReceptor': ''},
        {'InformacaoAssinaturaDoUltimoDocumentoAssinadoNoSetorReceptor': ''},
        {'TextoDoUltimoDocumentoAssinadoNoSetorReceptor': ''}
      ],
      'ProcessAnalytics':
      [
        {'SinteseTextoUltimoDocumentoAssinadoNoUltimoSetorRemetente': ''},
        {'SinteseTextoUltimoDocumentoAssinadoNoSetorAtual': ''},
        {'Prioridade': ''},
        {'Atribuicao': ''}
      ]
    }
    print('Serializando dados...')
    json_object = json.dumps(data)
    with open(Dir_NaoVisualisados+strdt_now+'.json', 'w') as outfile:
      outfile.write(json_object)
    print('Arquivo de processo criado: '+strdt_now+'.json.')
  else:
    print('Processo fora da lista.')

NaoVis.close()
print('Processamento inicial terminado.')




