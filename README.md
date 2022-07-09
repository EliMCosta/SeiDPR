# SeiDPR - Dados de Processos Recebidos SEI
Pacote de software para serviço de monitoramento e recuperação de dados de novos processos recebidos no Sistema Eletrônico de Informações, para atualização de base de dados e integração com sistemas de gestão de tarefas e equipes. Construído com base no SEI-GDF.

## Requisitos de sistema
### _Ambiente de servidor (CLI)_
+ Sistema operacional Linux (Debian, Ubuntu etc.)
+ Python 3
+ Navegador Google Chrome
+ 1 vCPU
+ 1 GB RAM

### _Ambiente desktop (GUI)_
+ Sistema operacional Linux (Debian, Ubuntu etc.)
+ Python 3
+ Navegador Google Chrome
+ 1 vCPU
+ 2 GB RAM

## Download e configuração
>É possível baixar a última versão diretamente do repositório acessando https://github.com/EliMCosta/SeiDPR.git.
+ Verifique se o seu sistema cumpre os requisitos necessários;
+ Faça o download a partir do repositório e extraia numa pasta de sua preferência (Ex.: /home/user);
+ Entre na pasta do projeto e dê as permissões necessárias para a execução dos arquivos *.sh;
+ Abra o arquivo _[Pasta Principal] > config > config.json_ e atualize os dados necessários;
+ Execute o arquivo _conf.sh_ (pelo terminal, ou por meio do botão direito do mouse no caso de desktop) e entre com os dados solicitados no terminal;

## Execução
Para que o serviço inicie, basta executar o arquivo _init-dpr.sh_ dentro da _[Pasta Principal]_.
