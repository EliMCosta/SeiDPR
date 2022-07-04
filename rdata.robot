*** Settings ***
Documentation    Automação para recuperar e salvar dados de processos SEI recebidos na unidade
Library    RPA.Browser.Selenium
Library    RPA.Desktop
Library    Process
Library    PassRetrieve.py
Library    RPA.FileSystem
Library    OperatingSystem
Library    String
Library    Collections
Library    RPA.JSON
Library    DateTime
Library    TrataInfoArvore.py
Library    TrataHist.py

*** Variables ***
${Browser}    chrome
${URL_SEI}    https://sei.df.gov.br
${login_sei}    92100027740
${value_Orgao}    21
${unidade}    TERRACAP/PRESI/ASINF
${pag_hist}    0
${Dir_NaoVisualizados}    ${CURDIR}/F1_Receber_Distribuir_Processos/1_Processos_Nao_Visualizados
${Dir_Visualizados}    ${CURDIR}/F1_Receber_Distribuir_Processos/2_Processos_Visualizados
${Dir_Registrados}    ${CURDIR}/F1_Receber_Distribuir_Processos/3_Processos_Registrados
${Dir_tmp}    /tmp

*** Keywords ***
Entrar no SEI
    ${senha_sei}    senha_sei
    Open Browser   ${URL_SEI}    browser=${Browser}
    Wait Until Page Contains    GOVERNO DO DISTRITO FEDERAL    timeout=5s
    Input Text    txtUsuario    ${login_sei}
    Input Text    pwdSenha    ${senha_sei}
    Select From List By Value    selOrgao    ${value_Orgao}
    Click Button When Visible    sbmLogin
Ir para o SEI e autenticar
    ${senha_sei}    senha_sei
    Go To   ${URL_SEI}
    Wait Until Page Contains    GOVERNO DO DISTRITO FEDERAL    timeout=5s
    Sleep   1s
    Input Text    txtUsuario    ${login_sei}
    Sleep   1s
    Input Text    pwdSenha    ${senha_sei}
    Sleep   1s
    Select From List By Value    selOrgao    ${value_Orgao}
    Sleep   1s
    Click Button When Visible    sbmLogin
Gerar não visualizados SEI
    RPA.Browser.Selenium.Click Element    //*[@id="main-menu"]/li[1]/a
    ${Source}    Get Source
    RPA.FileSystem.Create File    ${Dir_tmp}/recdistproc/NaoVis.txt    ${Source}    overwrite=True
    #Gerar arquivo com informações básicas para cada processo não visualizado
    Run Process    python3    ${CURDIR}/NaoVis.py

*** Tasks ***

#****************************************** CICLO 1 *******************************************************************

################################################ FASE 1 ################################################################

Criar diretórios
    Log    Diretório atual: ${CURDIR}    console=True
    OperatingSystem.Create Directory    ${Dir_tmp}/recdistproc
Autenticar no SEI
    Log    Autenticando no SEI...    console=True
    Run Keyword   Entrar no SEI
    Sleep   5s
    #Wait Until Page Contains    Controle de Processos    timeout=5
    ${pag_contem_controledeprocessos}    Does Page Contain    Controle de Processos
    IF    ${pag_contem_controledeprocessos} == ${True}
        Log    Login realizado com sucesso.    console=True
    ELSE
        Fatal Error    Falha no login.
    END
    ${windowhandles}=    Get Window Handles
    Switch Window    ${windowhandles}[1]
    Close Window
    Switch Window    ${windowhandles}[0]
Monitorar SEI
    Log    Verificando se há processos novos recebidos...    console=True
    Gerar não visualizados SEI        #Arquivos *.csv de processos não visualizados no diretório
    OperatingSystem.Remove File    ${Dir_tmp}/recdistproc/NaoVis.txt
    ${ListNaoVis}    OperatingSystem.List Files In Directory    ${Dir_NaoVisualizados}
    ${isEmpty}    Run Keyword And Return Status    Should Be Empty    ${ListNaoVis}
    IF    ${isEmpty} == True
        Log    Nenhum novo processo recebido.    console=True
    ELSE
        Log    Novo(s) processo(s) recebido(s):    console=True
        Log    ${ListNaoVis}    console=True
    END
    Log    ...fim da verificação.    console=True

############################################### FASE 2 #################################################################

Visualizar processos e extrair informações adicionais
    #Ler lista de processos não visualizados
    ${ListNaoVis}    OperatingSystem.List Files In Directory    ${Dir_NaoVisualizados}
    Log    Iniciando a visualização de processos...    console=True
    #Extrair informações de cada processo
    FOR    ${file}    IN    @{ListNaoVis}
        #Buscar dados básicos do processo administrativo atual
        Log    Processando ${file}...   console=True
        ${date}=    Get Current Date
        &{all_data}=    Load JSON from file    ${Dir_NaoVisualizados}/${file}
        ${id_recproc_task_as_list}=    Get values from JSON    ${all_data}    $.MetaData[*].IdTarefaRecebimentoDoProcesso     #NOT  NULL
        ${num_proc_as_list}=    Get values from JSON    ${all_data}    $.ProcessData[*].NumeroDoProcessoSei     #NOT  NULL
        ${id_proc_as_list}=    Get values from JSON    ${all_data}    $.ProcessData[*].IdProcedimentoDoProcesso     #NOT  NULL
        ${tip_proc_as_list}=    Get values from JSON    ${all_data}    $.ProcessData[*].TipoDoProcesso     #NOT  NULL
        ${spec_proc_as_list}=    Get values from JSON    ${all_data}    $.ProcessData[*].EspecificacaoDoProcesso
        ${id_recproc_task}=    Get From List    ${id_recproc_task_as_list}    0
        ${id_proc}=    Get From List    ${id_proc_as_list}    0
        ${num_proc}=    Get From List    ${num_proc_as_list}    0
        ${tip_proc}=    Get From List    ${tip_proc_as_list}    0
        ${spec_proc}=    Get From List    ${spec_proc_as_list}    0
        #Ir para o processo atual
        Go To    https://sei.df.gov.br/sei/controlador.php?acao=procedimento_trabalhar&id_procedimento=${id_proc}

        ##################################### Obter dados brutos da primeira página do histórico de andamento ##########
        #Clicar em "Consultar andamento", histórico completo
        Sleep    500ms
        Select Frame    id=ifrArvore
        Wait Until Page Contains Element    //*[@id="divConsultarAndamento"]/a/span    timeout= 5
        RPA.Browser.Selenium.Click Element    //*[@id="divConsultarAndamento"]/a/span

        #Seleciona a tabela do histórico e copia para arquivo temporário
        Unselect Frame
        Select Frame    id=ifrVisualizacao
        ${hist_andamento}    Get Text    //body
        RPA.FileSystem.Create File    ${Dir_tmp}/recdistproc/hist.txt    ${hist_andamento}    overwrite=True

        # Histórico de andamento armazenado no arquivo temporário ${Dir_tmp}/recdistproc/hist.txt

        ##################################### Capturar fonte da árvore do processo ###################################

        #Recuperar o fonte da árvore do processo
        Sleep    500ms
        Unselect Frame
        Select Frame    id=ifrArvore
        Sleep    50ms
        ${src_arvore}    Get Source
        RPA.FileSystem.Create File    ${Dir_tmp}/recdistproc/src_arvore.txt    ${src_arvore}    overwrite=True

        # Dados brutos da árvore do processo armazanados no arquivo temporário ${Dir_tmp}/recdistproc/src_arvore.txt

        ##################################### Processar e recuperar dados da árvore do processo ########################

        ${isRestrict}    isRestrict
        #Log    isRestrict: ${isRestrict}   console=True
        ${isPersonalInfo}    isPersonalInfo
        #Log    isPersonalInfo: ${isPersonalInfo}   console=True
        ${restrictMotivation}    restrictMotivation
        #Log    restrictMotivation: ${restrictMotivation}   console=True
        ${retornoProgramado}    dateRetornoProgramado
        #Log    restrictMotivation: ${restrictMotivation}   console=True
        ${acompEspGroup}    acompEspGroup
        #Log    acompEspGroup: ${acompEspGroup}   console=True
        ${marcadorGroup}    marcadorGroup
        #Log    marcadorGroup: ${marcadorGroup}   console=True
        ${set_infoadicionais}    set_infoadicionais
        #Log    set_infoadicionais: ${set_infoadicionais}   console=True
        OperatingSystem.Remove File    ${Dir_tmp}/recdistproc/src_arvore.txt

        ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].BoolProcessoRestrito    ${isRestrict}
        ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].BoolInformacaoPessoal    ${isPersonalInfo}
        ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].MotivacaoProcessoRestrito    ${restrictMotivation}
        ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].RetornoProgramado    ${retornoProgramado}
        ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].GrupoAcompanhamentoEspecial    ${acompEspGroup}
        ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].GrupoMarcador    ${marcadorGroup}
        ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].UnidadesComProcessoAbertoNoMomentoDaCriacaoDaTarefa    ${set_infoadicionais}
        Save JSON to file    ${all_data}    ${Dir_NaoVisualizados}/${file}

        ################################ Processar e recuperar dados do histórico do andamento do processo #########
        #Último setor remetente
        Wait Until Page Contains    Ver    timeout= 5
        ${pag_contem_resumido}    Does Page Contain    resumido
        IF    ${pag_contem_resumido} == ${True}
            #Seleciona a opção pelo histórico resumido
            Unselect Frame
            Select Frame    id=ifrVisualizacao
            RPA.Browser.Selenium.Click Element   //*[@id="ancTipoHistorico"]
        END

        FOR    ${index}    IN RANGE    100
            Unselect Frame
            Select Frame    id=ifrVisualizacao
            Wait Until Page Contains    Ver    timeout= 5
            ${hist_andamento}    Get Text    //body
            RPA.FileSystem.Create File    ${Dir_tmp}/recdistproc/hist.txt    ${hist_andamento}    overwrite=True
            ${ultimo_setor_remetente}    UltimoSetorRemetenteDoProcesso
            ${isEmpty}    Run Keyword And Return Status    Should Be Empty    ${ultimo_setor_remetente}
            IF    ${isEmpty} == True
                ${existe_prox_pag_hist}    Does Page Contain Element    //*[@id="lnkInfraProximaPaginaSuperior"]
                IF    ${existe_prox_pag_hist} == True
                    RPA.Browser.Selenium.Click Element    //*[@id="lnkInfraProximaPaginaSuperior"]
                    ${hist_andamento}    Get Text    //body
                    RPA.FileSystem.Create File    ${Dir_tmp}/recdistproc/hist.txt    ${hist_andamento}    overwrite=True
                    ${ultimo_setor_remetente}    UltimoSetorRemetenteDoProcesso
                ELSE
                    ${ultimo_setor_remetente}    Set Variable    NOT FOUND
                END
            ELSE
                Exit For Loop
            END
            ${existe_prox_pag_hist}    Does Page Contain Element    //*[@id="lnkInfraProximaPaginaSuperior"]
        END
        ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].UltimoSetorRemetenteDoProcesso    ${ultimo_setor_remetente}
        Save JSON to file    ${all_data}    ${Dir_NaoVisualizados}/${file}


        #Dados último documento último setor remetente

        FOR    ${index}    IN RANGE    100
            Unselect Frame
            Select Frame    id=ifrVisualizacao
            Wait Until Page Contains    Ver    timeout= 5
            ${hist_andamento}    Get Text    //body
            RPA.FileSystem.Create File    ${Dir_tmp}/recdistproc/hist.txt    ${hist_andamento}    overwrite=True
            ${dados_last_doc_rem}    DadosUltimoDocumentoAssinadoSetorRemetente
            ${isEmpty}    Run Keyword And Return Status    Should Be Empty    ${dados_last_doc_rem}
            IF    ${isEmpty} == True
                ${existe_prox_pag_hist}    Does Page Contain Element    //*[@id="lnkInfraProximaPaginaSuperior"]
                IF    ${existe_prox_pag_hist} == True
                    RPA.Browser.Selenium.Click Element    //*[@id="lnkInfraProximaPaginaSuperior"]
                    ${hist_andamento}    Get Text    //body
                    RPA.FileSystem.Create File    ${Dir_tmp}/recdistproc/hist.txt    ${hist_andamento}    overwrite=True
                    ${dados_last_doc_rem}    DadosUltimoDocumentoAssinadoSetorRemetente
                ELSE
                    IF    ${dados_last_doc_rem} == ""
                        ${dados_last_doc_rem}    Set Variable    NOT FOUND
                    ELSE
                        #Nothing to do
                    END
                END
            ELSE
                Exit For Loop
            END
        END

        ${date_last_doc_last_rem}=    Set Variable    ${dados_last_doc_rem}[0]
        ${last_doc_last_rem}=    Set Variable    ${dados_last_doc_rem}[1]
        ${type_doc_last_rem}=    Set Variable    ${dados_last_doc_rem}[2]


        ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].DataDoUltimoDocumentoAssinadoNoUltimoSetorRemetente    ${date_last_doc_last_rem}
        ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].IDUltimoDocumentoAssinadoNoUltimoSetorRemetente    ${last_doc_last_rem}
        ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].TipoUltimoDocumentoAssinadoNoUltimoSetorRemetente    ${type_doc_last_rem}
        Save JSON to file    ${all_data}    ${Dir_NaoVisualizados}/${file}



        # Ir para o último documento antes do envio pelo último setor remetente
        Unselect Frame
        Input Text    //*[@id="txtPesquisaRapida"]    ${last_doc_last_rem}
        RPA.Browser.Selenium.Press Keys    //*[@id="txtPesquisaRapida"]    ENTER
        Sleep    5s


        #OperatingSystem.Remove File    ${Dir_tmp}/recdistproc/hist.txt
        Exit For Loop    #temporário
    END
    Go To    https://sei.df.gov.br/sei

    Close All Browsers


#Aguardar próximo ciclo
#    Log    Aguardando próximo ciclo...    console=True
#    Sleep    10s

#****************************************** CICLO 2 *******************************************************************

################################################ FASE 1 ################################################################

#Criar diretórios
#    Log    Diretório atual: ${CURDIR}    console=True
#    OperatingSystem.Create Directory    ${Dir_tmp}/recdistproc
#Assegurar autenticação no SEI
#    Go To   ${URL_SEI}/sei
#    ${isAuthenticated}    Run Keyword And Return Status    Page Should Contain   Controle de Processos
#    IF    ${isAuthenticated} == True
#        Log    Usuário já autenticado.    console=True
#    ELSE
#        Log    Usuário não autenticado.    console=True
#        Log    Autenticando no SEI...    console=True
#        Run Keyword   Ir para o SEI e autenticar
#        Sleep 5s
#        ${isAuthenticated}    Run Keyword And Return Status    Page Should Contain   Controle de Processos
#        IF    ${isAuthenticated} == True
#            ${windowhandles}=    Get Window Handles
#            Switch Window    ${windowhandles}[1]
#            Close Window
#            Switch Window    ${windowhandles}[0]
#        ELSE
#            Log    Erro na autenticação.    console=True
#        END
#    END
#
#    #Remove Files    ${Dir_tmp}/recdistproc/hist.txt
#
#    #Remove Directory    ${Dir_tmp}/recdistproc
#    Close All Browsers
