from datetime import datetime as dt
from bs4 import BeautifulSoup
import re
import os
import json

Dir_tmp = '/tmp'

dir_path = os.path.dirname(os.path.realpath(__file__))
print('Lendo arquivos temporários...')
NaoVis = open(Dir_tmp+'/recdistproc/NaoVis.txt')

soup = BeautifulSoup(NaoVis, 'html.parser')

naovis_list = soup.find_all("a", class_="processoVisualizado")

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
      {'IDUltimoDocumentoAssinadoNoUltimoSetorRemetente': ''},
      {'DataAssinaturaDoUltimoDocumentoAssinadoNoSetorReceptor': ''},
      {'NumeroProtocoloUltimoDocumentoAssinadoNoSetorReceptor': ''},
      {'TipoUltimoDocumentoAssinadoNoSetorReceptor': ''},
      {'InformacaoSobreAssinaturaDoUltimoDocumentoAssinadoNoUltimoSetorRemetente': ''},
      {'TrechoInicialUltimoDocumentoAssinadoNoUltimoSetorRemetente': ''},
      {'DeclaracaoAcercaMencaoUnidadeAtualNoUltimoDocumentoAssinadoPeloUltimoRemetente': ''},
      {'InformacaoAssinaturaDoUltimoDocumentoAssinadoNoSetorReceptor': ''},
      {'TrechoInicialDoUltimoDocumentoAssinadoNoSetorReceptor': ''},
      {'IDUltimoSignatarioAPartirNoSetorReceptorPertecenteAUnidadeAtual': ''},
      {'Prioridade': ''},
      {'Atribuicao': ''}
    ]
  }
  print('Serializando dados...')
  json_object = json.dumps(data)
  with open(dir_path+'/F1_Receber_Distribuir_Processos/1_Processos_Nao_Visualizados/'+strdt_now+'.json', 'w') as outfile:
    outfile.write(json_object)
  print('Arquivo de processo criado: '+strdt_now+'.json.')
NaoVis.close()
print('Processamento inicial terminado.')




