#from asyncore import write
#from datetime import datetime as dt
#from distutils.log import Log
#from fileinput import close
#from time import strftime
#from unittest import result
#from zlib import DEF_MEM_LEVEL
from bs4 import BeautifulSoup
#import re

src_arvore=open('/tmp/automations/src_arvore.txt')
soup = BeautifulSoup(src_arvore, 'html.parser')
src_arvore.close()
str_doc_list = soup.find_all ("span")#(class_="infraArvore") #(id='anchor95913497')
src_arvore=open('/tmp/automations/src_arvore.txt', "w")
src_arvore.write(str(str_doc_list))
src_arvore.close()


    
