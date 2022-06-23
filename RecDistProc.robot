*** Settings ***
Documentation    Robô para receber e distribuir processos SEI
Library    RPA.Browser.Selenium
Library    RPA.Desktop
Library    Process
Library    PassRetrieve.py
Library    RPA.FileSystem
Library    OperatingSystem
Library    String
Library    Collections

*** Variables ***
${Browser}    chrome
${URL_SEI}    https://sei.df.gov.br
${login_sei}    92100027740
${value_Orgao}    21
${unidade}    TERRACAP/PRESI/ASINF
${pag_hist}    0
${Dir_NaoVisualizados}    /home/eli/Documents/Robots/F1_Receber_Distribuir_Processos/1_Processos_Nao_Visualizados

*** Keywords ***
Entrar no SEI
    ${senha_sei}    senha_sei
    Open Browser   ${URL_SEI}    browser=${Browser}
    Wait Until Page Contains    GOVERNO DO DISTRITO FEDERAL    timeout=5
    Input Text    txtUsuario    ${login_sei}
    Input Text    pwdSenha    ${senha_sei}
    Select From List By Value    selOrgao    ${value_Orgao}
    Click Button When Visible    sbmLogin
Gerar não visualizados SEI
    RPA.Browser.Selenium.Click Element    //*[@id="main-menu"]/li[1]/a
    ${Source}    Get Source
    RPA.FileSystem.Create File    /tmp/automations/NaoVis.txt    ${Source}    overwrite=True
    #Gerar arquivo *.csv com informações básicas para cada processo não visualizado
    Run Process    python3    /home/eli/Robots/robotenv/NaoVis.py

*** Tasks ***
Criar diretórios
    OperatingSystem.Create Directory    /tmp/automations
Autenticar no SEI
    Wait Until Keyword Succeeds    3x    5s    Entrar no SEI
    Wait Until Page Contains    Controle de Processos    timeout=5
    ${windowhandles}=    Get Window Handles
    Switch Window    ${windowhandles}[1]
    Close Window
    Switch Window    ${windowhandles}[0]
Monitorar SEI
    Log    Verificando se há processos novos recebidos...    console=True   
    Gerar não visualizados SEI        #Arquivos *.csv de processos não visualizados no diretório
    ${ListNaoVis}    OperatingSystem.List Files In Directory    ${Dir_NaoVisualizados}
    ${isEmpty}    Run Keyword And Return Status    Should Be Empty    ${ListNaoVis}
    IF    ${isEmpty} == True
        Log    Nenhum novo processo recebido.    console=True
    ELSE
        Log    Novo(s) processo(s) recebido(s):    console=True
        Log    ${ListNaoVis}    console=True
    END
    Log    ...fim da verificação    console=True
Visualizar processos e extrair informações adicionais
    #Ler lista de processos não visualizados
    ${ListNaoVis}    OperatingSystem.List Files In Directory    ${Dir_NaoVisualizados}
    #Extrair informações de cada processo
    FOR    ${file}    IN    @{ListNaoVis}
        #Buscar dados básicos do processo administrativo atual
        ${content_file}    Get File    path=${Dir_NaoVisualizados}/${file}
        @{words}=    Split String    ${content_file}    ;
        ${num_proc}=    Get From List    ${words}    0        #NOT  NULL
        ${id_proc}=    Get From List    ${words}    1        #NOT  NULL
        ${tipo_proc}=    Get From List    ${words}    2        #NOT  NULL
        ${espec_proc}=    Get From List    ${words}    3
        #Ir para o processo atual
        Go To    https://sei.df.gov.br/sei/controlador.php?acao=procedimento_trabalhar&id_procedimento=${id_proc}
        
        ##################################### Histórico de andamento ###########################################
        #Clicar em "Consultar andamento" e consultar histórico completo
        Sleep    500ms
        Select Frame    id=ifrArvore   
        RPA.Browser.Selenium.Click Element    //*[@id="divConsultarAndamento"]/a/span
        Wait Until Page Contains    Ver    timeout= 5
        ${pag_contem_completo}    Does Page Contain    completo  
        IF    ${pag_contem_completo} == ${True}
            #Seleciona a opção pelo histórico completo
            Unselect Frame
            Select Frame    id=ifrVisualizacao
            RPA.Browser.Selenium.Click Element   //*[@id="ancTipoHistorico"]
        END
        #Seleciona a tabela do histórico e copia para arquivo temporário
        Unselect Frame
        Select Frame    id=ifrVisualizacao
        ${hist_andamento}    Get Text    //body
        RPA.FileSystem.Create File    /tmp/automations/hist.txt    ${hist_andamento}    overwrite=True

        #Verificar o número de páginas do histórico do processo - Qd o processo é novo não tem elemento da lista


        
        ##################################### Árvore de documentos ############################################# 
        
        #Recuperar o fonte da árvore do processo
        Unselect Frame
        Select Frame    id=ifrArvore
        ${src_arvore}    Get Source
        RPA.FileSystem.Create File    /tmp/automations/src_arvore.txt    ${src_arvore}    overwrite=True
        #Processar o fonte da árvore do processo
        Run Process    python3    /home/eli/Robots/robotenv/TrataInfoArvore.py


        Exit For Loop    #temporário
    END
    Close All Browsers

