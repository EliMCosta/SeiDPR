from datetime import datetime as dt
from time import strftime
from unittest import result
from zlib import DEF_MEM_LEVEL
from bs4 import BeautifulSoup
import re

NaoVis=open('/tmp/automations/NaoVis.txt')

soup = BeautifulSoup(NaoVis, 'html.parser')

naovis_list = soup.find_all("a", class_="processoVisualizado")

for s in naovis_list:
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

  p_doc=open('/home/eli/Robots/F1_Receber_Distribuir_Processos/1_Processos_Nao_Visualizados/'+strdt_now+'.csv', 'w')
  p_doc.write(num_proc+';'+id_proc+';'+tip_proc+';'+spec_proc)
  p_doc.close()
  
NaoVis.close()
  




