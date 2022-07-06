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
#Library    ProcessaDocs.py

*** Variables ***
#Nomes de diretórios
${Dir_Dados}    ${CURDIR}/data
${Dir_NaoVisualizados}    ${Dir_Dados}/1_Processos_Nao_Visualizados
${Dir_Visualizados}    ${Dir_Dados}/2_Processos_Visualizados
${Dir_Registrados}    ${Dir_Dados}/3_Processos_Registrados
${Dir_tmp}    ${Dir_Dados}/tmp
*** Keywords ***
Entrar no SEI
    [Timeout]    10 seconds
    #Carregar as variáveis do arquivo de configuração
    &{config_data}=    Load JSON from file    ${CURDIR}/config/config.json
    ${Browser_as_list}=    Get values from JSON    ${config_data}    $.env[*].browser
    ${URL_SEI_as_list}=    Get values from JSON    ${config_data}    $.sei[*].url
    ${orgao_as_list}=    Get values from JSON    ${config_data}    $.sei[*].orgao
    ${unidade_as_list}=    Get values from JSON    ${config_data}    $.sei[*].unidade
    ${login_sei_as_list}=    Get values from JSON    ${config_data}    $.sei[*].usuario
    ${Browser}=    Get From List    ${Browser_as_list}    0
    ${URL_SEI}=    Get From List    ${URL_SEI_as_list}    0
    ${orgao}=    Get From List    ${orgao_as_list}    0
    ${unidade}=    Get From List    ${unidade_as_list}    0
    ${login_sei}=    Get From List    ${login_sei_as_list}    0
    #Carregar senha
    ${senha_sei}    senha_sei
    #Abrir página e logar
    Open Browser   ${URL_SEI}    browser=${Browser}
    Wait Until Page Contains    GOVERNO DO DISTRITO FEDERAL    timeout=5s
    Input Text    txtUsuario    ${login_sei}
    Input Text    pwdSenha    ${senha_sei}
    Select From List By Label    selOrgao    ${orgao}
    Click Button When Visible    sbmLogin
Ir para o SEI e autenticar
    [Timeout]    10 seconds
    ${senha_sei}    senha_sei
    Go To   ${URL_SEI}
    Wait Until Page Contains    GOVERNO DO DISTRITO FEDERAL    timeout=5s
    Input Text    txtUsuario    ${login_sei}
    Input Text    pwdSenha    ${senha_sei}
    Select From List By Label    selOrgao    ${orgao}
    Click Button When Visible    sbmLogin
Gerar não visualizados SEI
    Wait Until Page Contains Element    //*[@id="main-menu"]/li[1]/a
    RPA.Browser.Selenium.Click Element    //*[@id="main-menu"]/li[1]/a
    ${Source}    Get Source
    RPA.FileSystem.Create File    ${Dir_tmp}/NaoVis.txt    ${Source}    overwrite=True
    #Gerar arquivo com informações básicas para cada processo não visualizado
    Run Process    python3    ${CURDIR}/src/NaoVis.py

*** Tasks ***

#****************************************** CICLO 1 *******************************************************************

################################################ FASE 1 ################################################################

Criar diretórios
    Log    Diretório atual: ${CURDIR}    console=True
    OperatingSystem.Create Directory    ${Dir_Dados}
    OperatingSystem.Create Directory    ${Dir_NaoVisualizados}
    OperatingSystem.Create Directory    ${Dir_Visualizados}
    OperatingSystem.Create Directory    ${Dir_Registrados}
    OperatingSystem.Create Directory    ${Dir_tmp}
    OperatingSystem.Create Directory    ${CURDIR}/results
Autenticar no SEI
    [Timeout]    15 seconds
    Log    Autenticando no SEI...    console=True
    Run Keyword   Entrar no SEI
    Wait Until Page Contains    Controle de Processos    timeout=5
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
    Gerar não visualizados SEI
    OperatingSystem.Remove File    ${Dir_tmp}/NaoVis.txt
    ${ListNaoVis}    OperatingSystem.List Files In Directory    ${Dir_NaoVisualizados}
    ${isEmptyListNaoVis}    Run Keyword And Return Status    Should Be Empty    ${ListNaoVis}
    IF    ${isEmptyListNaoVis} == True
        Log    Nenhum novo processo recebido.    console=True
        Fatal Error    Fim da tarefa.
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
        RPA.FileSystem.Create File    ${Dir_tmp}/hist.txt    ${hist_andamento}    overwrite=True

        # Histórico de andamento armazenado no arquivo temporário ${Dir_tmp}/hist.txt

        ##################################### Capturar fonte da árvore do processo ###################################

        #Recuperar o fonte da árvore do processo
        Sleep    500ms
        Unselect Frame
        Select Frame    id=ifrArvore
        Sleep    50ms
        ${src_arvore}    Get Source
        RPA.FileSystem.Create File    ${Dir_tmp}/src_arvore.txt    ${src_arvore}    overwrite=True

        # Dados brutos da árvore do processo armazanados no arquivo temporário ${Dir_tmp}/src_arvore.txt

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
        OperatingSystem.Remove File    ${Dir_tmp}/src_arvore.txt

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
            Unselect Frame
            Select Frame    id=ifrVisualizacao
            RPA.Browser.Selenium.Click Element   //*[@id="ancTipoHistorico"]
        END

        FOR    ${index}    IN RANGE    100
            Unselect Frame
            Select Frame    id=ifrVisualizacao
            Wait Until Page Contains    Ver    timeout= 5
            ${hist_andamento}    Get Text    //body
            RPA.FileSystem.Create File    ${Dir_tmp}/hist.txt    ${hist_andamento}    overwrite=True
            ${ultimo_setor_remetente}    UltimoSetorRemetenteDoProcesso
            ${isEmpty}    Run Keyword And Return Status    Should Be Empty    ${ultimo_setor_remetente}
            IF    ${isEmpty} == True
                ${existe_prox_pag_hist}    Does Page Contain Element    //*[@id="lnkInfraProximaPaginaSuperior"]
                IF    ${existe_prox_pag_hist} == True
                    RPA.Browser.Selenium.Click Element    //*[@id="lnkInfraProximaPaginaSuperior"]
                    ${hist_andamento}    Get Text    //body
                    RPA.FileSystem.Create File    ${Dir_tmp}/hist.txt    ${hist_andamento}    overwrite=True
                    ${ultimo_setor_remetente}    UltimoSetorRemetenteDoProcesso
                ELSE
                    ${ultimo_setor_remetente}    Set Variable    NULL
                    Exit For Loop
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
            RPA.FileSystem.Create File    ${Dir_tmp}/hist.txt    ${hist_andamento}    overwrite=True
            ${dados_last_doc_rem}    DadosUltimoDocumentoAssinadoSetorRemetente
            ${isEmptydados_last_doc_rem}    Run Keyword And Return Status    Should Be Empty    ${dados_last_doc_rem}
            IF    ${isEmptydados_last_doc_rem} == True
                ${existe_prox_pag_hist}    Does Page Contain Element    //*[@id="lnkInfraProximaPaginaSuperior"]
                IF    ${existe_prox_pag_hist} == True
                    RPA.Browser.Selenium.Click Element    //*[@id="lnkInfraProximaPaginaSuperior"]
                    ${hist_andamento}    Get Text    //body
                    RPA.FileSystem.Create File    ${Dir_tmp}/hist.txt    ${hist_andamento}    overwrite=True
                    ${dados_last_doc_rem}    DadosUltimoDocumentoAssinadoSetorRemetente
                ELSE
                    ${dados_last_doc_rem}    Set Variable    NULL
                    Exit For Loop
                END
            ELSE
                Exit For Loop
            END
        END

        ${date_last_doc_last_rem}=    Set Variable    ${dados_last_doc_rem}[0]
        ${last_doc_last_rem}=    Set Variable    ${dados_last_doc_rem}[1]
        ${type_doc_last_rem}=    Set Variable    ${dados_last_doc_rem}[2]
        ${isEmptydate_last_doc_last_rem}    Run Keyword And Return Status    Should Be Empty    ${date_last_doc_last_rem}
        ${isEmptylast_doc_last_rem}    Run Keyword And Return Status    Should Be Empty    ${last_doc_last_rem}
        Log    Lastdocrem empty: ${isEmptylast_doc_last_rem}
        ${isEmptytype_doc_last_rem}    Run Keyword And Return Status    Should Be Empty    ${type_doc_last_rem}


        IF    ${isEmptydate_last_doc_last_rem} == True
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].DataDoUltimoDocumentoAssinadoNoUltimoSetorRemetente    NULL
        ELSE
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].DataDoUltimoDocumentoAssinadoNoUltimoSetorRemetente    ${date_last_doc_last_rem}
        END
        Save JSON to file    ${all_data}    ${Dir_NaoVisualizados}/${file}
        IF    ${isEmptylast_doc_last_rem} == True
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].NumeroProtocoloUltimoDocumentoAssinadoNoUltimoSetorRemetente    NULL
        ELSE
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].NumeroProtocoloUltimoDocumentoAssinadoNoUltimoSetorRemetente    ${last_doc_last_rem}
        END
        Save JSON to file    ${all_data}    ${Dir_NaoVisualizados}/${file}
        IF    ${isEmptytype_doc_last_rem} == True
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].TipoUltimoDocumentoAssinadoNoUltimoSetorRemetente    NULL
        ELSE
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].TipoUltimoDocumentoAssinadoNoUltimoSetorRemetente    ${type_doc_last_rem}
        END
        Save JSON to file    ${all_data}    ${Dir_NaoVisualizados}/${file}

        # Dados último documento assinado no setor atual

        FOR    ${index}    IN RANGE    100
            Unselect Frame
            Select Frame    id=ifrVisualizacao
            Wait Until Page Contains    Ver    timeout= 5
            ${hist_andamento}    Get Text    //body
            RPA.FileSystem.Create File    ${Dir_tmp}/hist.txt    ${hist_andamento}    overwrite=True
            ${dados_last_doc_atual}    DadosUltimoDocumentoAssinadoSetorAtual
            ${isEmptydados_last_doc_atual}    Run Keyword And Return Status    Should Be Empty    ${dados_last_doc_atual}
            IF    ${isEmptydados_last_doc_atual} == True
                ${existe_prox_pag_hist}    Does Page Contain Element    //*[@id="lnkInfraProximaPaginaSuperior"]
                IF    ${existe_prox_pag_hist} == True
                    RPA.Browser.Selenium.Click Element    //*[@id="lnkInfraProximaPaginaSuperior"]
                    ${hist_andamento}    Get Text    //body
                    RPA.FileSystem.Create File    ${Dir_tmp}/hist.txt    ${hist_andamento}    overwrite=True
                    ${dados_last_doc_atual}    DadosUltimoDocumentoAssinadoSetorAtual
                ELSE
                    ${dados_last_doc_atual}    Set Variable    NULL
                    Exit For Loop
                END
            ELSE
                Exit For Loop
            END
        END

        ${date_last_doc_atual}=    Set Variable    ${dados_last_doc_atual}[0]
        ${last_doc_atual}=    Set Variable    ${dados_last_doc_atual}[1]
        ${type_doc_atual}=    Set Variable    ${dados_last_doc_atual}[2]
        ${isEmptydate_last_doc_atual}    Run Keyword And Return Status    Should Be Empty    ${date_last_doc_atual}
        ${isEmptylast_doc_atual}    Run Keyword And Return Status    Should Be Empty    ${last_doc_atual}
        ${isEmptytype_doc_atual}    Run Keyword And Return Status    Should Be Empty    ${type_doc_atual}

        IF    ${isEmptydate_last_doc_atual} == True
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].DataAssinaturaDoUltimoDocumentoAssinadoNoSetorReceptor    NULL
        ELSE
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].DataAssinaturaDoUltimoDocumentoAssinadoNoSetorReceptor    ${date_last_doc_atual}
        END
        IF    ${isEmptylast_doc_atual} == True
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].NumeroProtocoloUltimoDocumentoAssinadoNoSetorReceptor    NULL
        ELSE
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].NumeroProtocoloUltimoDocumentoAssinadoNoSetorReceptor    ${last_doc_atual}
        END
        IF    ${isEmptytype_doc_atual} == True
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].TipoUltimoDocumentoAssinadoNoSetorReceptor    NULL
        ELSE
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].TipoUltimoDocumentoAssinadoNoSetorReceptor    ${type_doc_atual}
        END

        Save JSON to file    ${all_data}    ${Dir_NaoVisualizados}/${file}

        # Ir para o último documento do setor remetente
        IF    ${isEmptylast_doc_last_rem} == True
            ${text_last_doc_last_rem}=    Set Variable    NULL
            ${info_sign_last_doc_last_rem}=    Set Variable    NULL
            Log    Não foi encontrado documento assinado de origem da unidade que enviou o processo.   console=True
        ELSE
            Unselect Frame
            Input Text    //*[@id="txtPesquisaRapida"]    ${last_doc_last_rem}
            RPA.Browser.Selenium.Press Keys    //*[@id="txtPesquisaRapida"]    ENTER
            Sleep    500ms
            Unselect Frame
            Select Frame    id=ifrVisualizacao
            Select Frame    id=ifrArvoreHtml

            ${url_last_doc_last_rem}    Get Location
            @{var1}    Split String    ${url_last_doc_last_rem}    id_protocolo=
            ${var2}=    Set Variable    ${var1}[1]
            @{var3}    Split String    ${var2}    &infra_sistema
            ${id_last_doc_last_rem}=    Set Variable    ${var3}[0]
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].IDUltimoDocumentoAssinadoNoUltimoSetorRemetente    ${id_last_doc_last_rem}
            Save JSON to file    ${all_data}    ${Dir_NaoVisualizados}/${file}

            ${text_last_doc_last_rem}    Get Text    //body
            ${contain_doc_assinado}    Run Keyword And Return Status    Should Contain    ${text_last_doc_last_rem}    Documento assinado eletronicamente por
            IF    ${contain_doc_assinado} == True
                @{var1}    Split String    ${text_last_doc_last_rem}    \nDocumento assinado eletronicamente por
                ${text_last_doc_last_rem}=    Set Variable    ${var1}[0]
                ${var2}=    Set Variable    ${var1}[1]
                @{var3}    Split String    ${var2}    \nA autenticidade do documento pode ser conferida no site:
                ${info_sign_last_doc_last_rem}=    Set Variable    Documento assinado eletronicamente por${var3}[0]
            ELSE
                ${info_sign_last_doc_last_rem}=    Set Variable    NULL
            END
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].TextoUltimoDocumentoAssinadoNoUltimoSetorRemetente    ${text_last_doc_last_rem}
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].InformacaoSobreAssinaturaDoUltimoDocumentoAssinadoNoUltimoSetorRemetente    ${info_sign_last_doc_last_rem}
            Save JSON to file    ${all_data}    ${Dir_NaoVisualizados}/${file}



        END

        # Ir para o último documento do setor atual antes do envio pelo último setor remetente
        IF    ${isEmptylast_doc_atual} == True
            Log    Não foi encontrado documento assinado de origem da unidade atual.   console=True
        ELSE
            Unselect Frame
            Input Text    //*[@id="txtPesquisaRapida"]    ${last_doc_atual}
            RPA.Browser.Selenium.Press Keys    //*[@id="txtPesquisaRapida"]    ENTER
            Sleep    500ms
            Unselect Frame
            Select Frame    id=ifrVisualizacao
            Select Frame    id=ifrArvoreHtml

            ${url_last_doc_atual}    Get Location
            @{var1}    Split String    ${url_last_doc_atual}    id_protocolo=
            ${var2}=    Set Variable    ${var1}[1]
            @{var3}    Split String    ${var2}    &infra_sistema
            ${id_last_doc_atual}=    Set Variable    ${var3}[0]
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].IDUltimoDocumentoAssinadoNoUltimoSetorReceptor    ${id_last_doc_atual}
            Save JSON to file    ${all_data}    ${Dir_NaoVisualizados}/${file}

            ${text_last_doc_atual}    Get Text    //body
            ${contain_doc_assinado}    Run Keyword And Return Status    Should Contain    ${text_last_doc_atual}    Documento assinado eletronicamente por
            IF    ${contain_doc_assinado} == True
                @{var1}    Split String    ${text_last_doc_atual}    \nDocumento assinado eletronicamente por
                ${text_last_doc_atual}=    Set Variable    ${var1}[0]
                ${var2}=    Set Variable    ${var1}[1]
                @{var3}    Split String    ${var2}    \nA autenticidade do documento pode ser conferida no site:
                ${info_sign_last_doc_atual}=    Set Variable    Documento assinado eletronicamente por${var3}[0]
            ELSE
                ${info_sign_last_doc_atual}=    Set Variable    NULL
            END
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].TextoDoUltimoDocumentoAssinadoNoSetorReceptor    ${text_last_doc_atual}
            ${all_data}=    Update value to JSON    ${all_data}    $.ProcessData[*].InformacaoAssinaturaDoUltimoDocumentoAssinadoNoSetorReceptor    ${info_sign_last_doc_atual}
            Save JSON to file    ${all_data}    ${Dir_NaoVisualizados}/${file}
        END

        OperatingSystem.Remove File    ${Dir_tmp}/hist.txt
        Log    Arquivo processado.   console=True
        Exit For Loop    #temporário
    END
    Go To    https://sei.df.gov.br/sei

    Close All Browsers
